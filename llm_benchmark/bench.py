# Benchmark de modelos locales (Ollama o llama-server) para programacion en Python y R.
# Uso: python bench.py <modelo> [--solo-velocidad] [--backend llama] [--port 8080]
#   Con --backend llama, <modelo> es solo una etiqueta; el servidor define el modelo.
# Resultados incrementales en results/<modelo>.json
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

import requests

OLLAMA = os.environ.get("BENCH_OLLAMA", "http://localhost:11434")
BASE = Path(__file__).parent
DATA = BASE / "data"
WORK = BASE / "work"
RSCRIPT = os.environ.get(
    "BENCH_RSCRIPT",
    r"C:\Users\abel.coronado\AppData\Local\Programs\R\R-4.6.1\bin\Rscript.exe",
)
# Identifica la maquina donde se corre: queda grabado en cada JSON de resultados
# para que las mediciones de equipos distintos nunca se confundan entre si.
PROFILE = os.environ.get("BENCH_PROFILE", "laptop-ref-ultra5-32gb-1dimm")
# Los resultados se separan por perfil en carpetas distintas. No basta con grabar el
# perfil dentro del JSON: dos maquinas que etiquetan igual un mismo modelo colisionan
# en el nombre de archivo, y en Windows (case-insensitive) basta con que difieran en
# mayusculas para que una sobrescriba a la otra al hacer git pull.
RESULTS = BASE / "results" / PROFILE
GEN_TIMEOUT = 900  # s por llamada de generacion
EXEC_TIMEOUT = 300  # s por ejecucion de script generado

RESULTS.mkdir(parents=True, exist_ok=True)


BACKEND = "ollama"
LLAMA_PORT = 8080


def generate_llama(model, prompt, num_predict=2048):
    """Llama a llama-server (API OpenAI) y devuelve (texto, metricas)."""
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0,
        "max_tokens": num_predict,
        "cache_prompt": False,
        "chat_template_kwargs": {"enable_thinking": False},
    }
    t0 = time.time()
    r = requests.post(f"http://localhost:{LLAMA_PORT}/v1/chat/completions",
                      json=payload, timeout=GEN_TIMEOUT)
    r.raise_for_status()
    d = r.json()
    wall = time.time() - t0
    tim = d.get("timings", {})
    usage = d.get("usage", {})
    m = {
        "wall_s": round(wall, 1),
        "prompt_tokens": tim.get("prompt_n") or usage.get("prompt_tokens"),
        "gen_tokens": tim.get("predicted_n") or usage.get("completion_tokens"),
        "prefill_tok_s": round(tim["prompt_per_second"], 2) if tim.get("prompt_per_second") else None,
        "decode_tok_s": round(tim["predicted_per_second"], 2) if tim.get("predicted_per_second") else None,
        "load_s": None,
    }
    return d["choices"][0]["message"]["content"], m


def generate(model, prompt, num_ctx=8192, num_predict=2048):
    """Llama a Ollama y devuelve (texto, metricas)."""
    if BACKEND == "llama":
        return generate_llama(model, prompt, num_predict)
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False,
        "think": False,
        "options": {"temperature": 0, "num_ctx": num_ctx, "num_predict": num_predict},
    }
    t0 = time.time()
    r = requests.post(f"{OLLAMA}/api/generate", json=payload, timeout=GEN_TIMEOUT)
    if r.status_code != 200:
        # algunos modelos no aceptan "think"
        payload.pop("think")
        r = requests.post(f"{OLLAMA}/api/generate", json=payload, timeout=GEN_TIMEOUT)
    r.raise_for_status()
    d = r.json()
    wall = time.time() - t0
    m = {
        "wall_s": round(wall, 1),
        "prompt_tokens": d.get("prompt_eval_count"),
        "gen_tokens": d.get("eval_count"),
        "prefill_tok_s": round(d["prompt_eval_count"] / d["prompt_eval_duration"] * 1e9, 2)
        if d.get("prompt_eval_duration") else None,
        "decode_tok_s": round(d["eval_count"] / d["eval_duration"] * 1e9, 2)
        if d.get("eval_duration") else None,
        "load_s": round(d.get("load_duration", 0) / 1e9, 1),
    }
    return d.get("response", ""), m


def extract_code(text, lang_hints):
    """Extrae el bloque de codigo mas largo del texto."""
    text = re.sub(r"<think>.*?</think>", "", text, flags=re.S)
    blocks = re.findall(r"```[a-zA-Z]*\n(.*?)```", text, flags=re.S)
    if blocks:
        return max(blocks, key=len)
    # sin fences: si parece codigo puro, usarlo tal cual
    if any(h in text for h in lang_hints):
        return text
    return None


# ---------------- Tareas ----------------

def _fresh_workdir(name):
    wd = WORK / name
    if wd.exists():
        shutil.rmtree(wd)
    wd.mkdir(parents=True)
    for f in DATA.iterdir():
        shutil.copy(f, wd / f.name)
    return wd


def run_script(wd, code, lang):
    if lang == "python":
        f = wd / "script.py"
        f.write_text(code, encoding="utf-8")
        cmd = [sys.executable, str(f)]
    else:
        f = wd / "script.R"
        f.write_text(code, encoding="utf-8")
        cmd = [RSCRIPT, str(f)]
    try:
        p = subprocess.run(cmd, cwd=wd, capture_output=True, text=True, timeout=EXEC_TIMEOUT)
        return p.returncode, (p.stdout + "\n" + p.stderr)[-2000:]
    except subprocess.TimeoutExpired:
        return -1, "TIMEOUT"


def check_excel(wd, fname):
    import pandas as pd
    fp = wd / fname
    if not fp.exists():
        return False, "archivo no existe"
    try:
        df = pd.read_excel(fp, sheet_name="Resumen")
    except Exception as e:
        return False, f"no se pudo leer hoja Resumen: {e}"
    cols = [c.lower().strip() for c in df.columns]
    if "region" not in cols or "ventas_totales" not in cols:
        return False, f"columnas incorrectas: {list(df.columns)}"
    ventas = pd.read_csv(wd / "ventas.csv")
    esperado = ventas.groupby("region")["ventas"].sum()
    df.columns = cols
    obtenido = df.set_index("region")["ventas_totales"]
    for reg, val in esperado.items():
        if reg not in obtenido.index or abs(float(obtenido[reg]) - val) > 0.5:
            return False, f"total incorrecto para {reg}"
    return True, "ok"


def check_files(wd, fnames, min_kb=5, must_contain=None):
    for fn in fnames:
        fp = wd / fn
        if not fp.exists():
            return False, f"{fn} no existe"
        if fp.stat().st_size < min_kb * 1024:
            return False, f"{fn} demasiado pequeno ({fp.stat().st_size} bytes)"
        if must_contain:
            content = fp.read_text(encoding="utf-8", errors="ignore").lower()
            if must_contain.lower() not in content:
                return False, f"{fn} no contiene '{must_contain}'"
    return True, "ok"


def check_forecast(wd, fname):
    import pandas as pd
    fp = wd / fname
    if not fp.exists():
        return False, "archivo no existe"
    df = pd.read_csv(fp)
    if len(df) != 12:
        return False, f"{len(df)} filas, se esperaban 12"
    numcols = df.select_dtypes("number").columns
    if len(numcols) == 0:
        return False, "sin columna numerica"
    vals = df[numcols[0]]
    serie = pd.read_csv(wd / "serie_mensual.csv")
    ref = serie["valor"].tail(12).mean()
    if not (0.3 * ref < vals.mean() < 3 * ref):
        return False, f"pronostico fuera de rango (media {vals.mean():.1f} vs ref {ref:.1f})"
    return True, "ok"


TASKS = [
    {
        "id": "excel_py", "lang": "python",
        "prompt": (
            "Escribe un script completo de Python (un solo bloque de codigo) que lea el archivo "
            "'ventas.csv' del directorio actual (columnas: region, mes, ventas) y cree un archivo "
            "Excel 'reporte.xlsx' con una hoja llamada 'Resumen' que contenga exactamente dos "
            "columnas: 'region' y 'ventas_totales' (suma de ventas por region, una fila por region). "
            "Usa pandas y openpyxl. Solo el codigo, sin explicaciones."
        ),
        "check": lambda wd: check_excel(wd, "reporte.xlsx"),
    },
    {
        "id": "excel_r", "lang": "r",
        "prompt": (
            "Escribe un script completo de R (un solo bloque de codigo) que lea el archivo "
            "'ventas.csv' del directorio actual (columnas: region, mes, ventas) y cree un archivo "
            "Excel 'reporte_r.xlsx' con una hoja llamada 'Resumen' que contenga exactamente dos "
            "columnas: 'region' y 'ventas_totales' (suma de ventas por region, una fila por region). "
            "Usa el paquete writexl (ya instalado; tambien estan openxlsx y readxl). "
            "Solo el codigo, sin explicaciones."
        ),
        "check": lambda wd: check_excel(wd, "reporte_r.xlsx"),
    },
    {
        "id": "dash_py", "lang": "python",
        "prompt": (
            "Escribe un script completo de Python (un solo bloque de codigo) que lea 'ventas.csv' "
            "(columnas: region, mes, ventas) y genere un dashboard en un solo archivo 'dashboard.html' "
            "usando plotly, con dos graficas: (1) barras de ventas totales por region y (2) linea de "
            "ventas totales por mes. Usa plotly.subplots.make_subplots y fig.write_html('dashboard.html', "
            "include_plotlyjs='cdn'). Solo el codigo, sin explicaciones."
        ),
        "check": lambda wd: check_files(wd, ["dashboard.html"], min_kb=3, must_contain="plotly"),
    },
    {
        "id": "dash_r", "lang": "r",
        "prompt": (
            "Escribe un script completo de R (un solo bloque de codigo) que lea 'ventas.csv' "
            "(columnas: region, mes, ventas) y genere dos imagenes PNG con ggplot2 (ya instalado): "
            "'dashboard_r_barras.png' con barras de ventas totales por region, y "
            "'dashboard_r_linea.png' con una linea de ventas totales por mes (agrupa y suma por mes; "
            "trata mes como texto y usa group=1 en la linea). Guarda con ggsave, ancho 8 y alto 5 pulgadas. "
            "Solo el codigo, sin explicaciones."
        ),
        "check": lambda wd: check_files(wd, ["dashboard_r_barras.png", "dashboard_r_linea.png"], min_kb=5),
    },
    {
        "id": "ts_py", "lang": "python",
        "prompt": (
            "Escribe un script completo de Python (un solo bloque de codigo) que lea 'serie_mensual.csv' "
            "(columnas: fecha, valor; 72 meses de una serie con tendencia y estacionalidad anual) y ajuste "
            "un modelo Holt-Winters aditivo con statsmodels (ExponentialSmoothing con trend='add', "
            "seasonal='add', seasonal_periods=12). Genera un pronostico de 12 meses y guardalo en "
            "'pronostico_py.csv' con columnas 'fecha' (meses siguientes en formato YYYY-MM-DD) y "
            "'pronostico'. Solo el codigo, sin explicaciones."
        ),
        "check": lambda wd: check_forecast(wd, "pronostico_py.csv"),
    },
    {
        "id": "ts_r", "lang": "r",
        "prompt": (
            "Escribe un script completo de R (un solo bloque de codigo) que lea 'serie_mensual.csv' "
            "(columnas: fecha, valor; 72 meses de una serie con tendencia y estacionalidad anual), "
            "convierta la serie a ts con frequency=12 y ajuste un modelo con auto.arima del paquete "
            "forecast (ya instalado). Genera un pronostico de 12 meses con forecast() y guardalo en "
            "'pronostico_r.csv' con columnas 'fecha' (meses siguientes en formato YYYY-MM-DD) y "
            "'pronostico' (la media puntual). Solo el codigo, sin explicaciones."
        ),
        "check": lambda wd: check_forecast(wd, "pronostico_r.csv"),
    },
]

SPEED_PROMPTS = {
    "corto": "Escribe una funcion de Python que calcule los primeros n numeros primos y explica brevemente su complejidad.",
    "largo": (
        "Analiza el siguiente codigo y describe que hace cada funcion, sus posibles errores y como mejorarlo:\n\n"
        + ("def procesa(df):\n    df['total'] = df['a'] + df['b']\n    for i in range(len(df)):\n"
           "        if df.loc[i, 'total'] > 100:\n            df.loc[i, 'flag'] = True\n    return df\n\n") * 40
    ),
}


def main():
    global BACKEND, LLAMA_PORT
    model = sys.argv[1]
    solo_velocidad = "--solo-velocidad" in sys.argv
    if "--backend" in sys.argv:
        BACKEND = sys.argv[sys.argv.index("--backend") + 1]
    if "--port" in sys.argv:
        LLAMA_PORT = int(sys.argv[sys.argv.index("--port") + 1])
    out = {"model": model, "profile": PROFILE, "speed": {}, "tasks": {}}
    outfile = RESULTS / f"{model.replace(':', '_').replace('/', '_')}.json"

    def save():
        outfile.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8")

    # --- velocidad ---
    for name, prompt in SPEED_PROMPTS.items():
        runs = []
        for i in range(2):
            _, m = generate(model, prompt, num_predict=512)
            runs.append(m)
            print(f"[{model}] velocidad {name} run{i+1}: decode {m['decode_tok_s']} tok/s, prefill {m['prefill_tok_s']} tok/s", flush=True)
        out["speed"][name] = runs
        save()

    if solo_velocidad:
        return

    # --- tareas ---
    for task in TASKS:
        tid = task["id"]
        wd = _fresh_workdir(f"{model.replace(':', '_')}_{tid}")
        hints = ["import ", "def "] if task["lang"] == "python" else ["library(", "<-"]
        text, m = generate(model, task["prompt"])
        code = extract_code(text, hints)
        rec = {"gen": m, "passed": False, "detail": ""}
        if code is None:
            rec["detail"] = "no se extrajo codigo"
        else:
            rc, log = run_script(wd, code, task["lang"])
            if rc != 0:
                rec["detail"] = f"error de ejecucion (rc={rc}): {log[-600:]}"
            else:
                ok, why = task["check"](wd)
                rec["passed"] = ok
                rec["detail"] = why
        out["tasks"][tid] = rec
        print(f"[{model}] {tid}: {'PASS' if rec['passed'] else 'FAIL'} ({rec['detail'][:120]}) gen={m['wall_s']}s @ {m['decode_tok_s']} tok/s", flush=True)
        save()

    print(f"[{model}] terminado -> {outfile}", flush=True)


if __name__ == "__main__":
    main()
