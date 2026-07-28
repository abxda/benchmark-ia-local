# Fase 4: benchmark agentico con Cline CLI (headless) sobre llama-server local.
# Uso: python bench_cline.py <etiqueta>
# El servidor (puerto 8080, alias 'local') define el modelo; la etiqueta solo nombra el resultado.
# Reutiliza tareas y checkers de bench.py; el agente escribe, ejecuta y auto-corrige.
import json
import os
import subprocess
import sys
import time
from pathlib import Path

import bench

CLINE = os.environ.get("BENCH_CLINE", r"C:\Users\abel.coronado\AppData\Roaming\npm\cline.cmd")
R_BIN = os.environ.get(
    "BENCH_R_BIN", r"C:\Users\abel.coronado\AppData\Local\Programs\R\R-4.6.1\bin"
)
TASK_TIMEOUT = 1800  # s por tarea agentica

AGENT_SUFFIX = (
    " Guarda el script como '{script}' en el directorio actual, EJECUTALO tu mismo, "
    "revisa el resultado y, si hay errores o el archivo de salida no cumple exactamente "
    "lo pedido, corrige el script y vuelve a ejecutarlo hasta que funcione."
)


def agent_prompt(task):
    script = "script.py" if task["lang"] == "python" else "script.R"
    # misma especificacion que la fase 1, sin la restriccion de "solo el codigo"
    spec = task["prompt"].replace(" Solo el codigo, sin explicaciones.", "")
    spec = spec.replace("(un solo bloque de codigo) ", "")
    return spec + AGENT_SUFFIX.format(script=script)


def main():
    label = sys.argv[1]
    solo = sys.argv[2:]  # ids de tareas a correr; vacio = todas las que falten
    outfile = bench.RESULTS / f"{label.replace(':', '_')}_cline.json"
    if outfile.exists():
        out = json.loads(outfile.read_text(encoding="utf-8"))
    else:
        out = {"model": label, "profile": bench.PROFILE, "mode": "cline-agent", "tasks": {}}

    env = dict(os.environ)
    env["PATH"] = R_BIN + os.pathsep + env["PATH"]

    for task in bench.TASKS:
        if solo and task["id"] not in solo:
            continue
        if not solo and task["id"] in out["tasks"]:
            continue
        tid = task["id"]
        wd = bench._fresh_workdir(f"cline_{label.replace(':', '_')}_{tid}")
        t0 = time.time()
        try:
            p = subprocess.run(
                [CLINE, "--auto-approve", "true", "--timeout", str(TASK_TIMEOUT),
                 "-c", str(wd), agent_prompt(task)],
                cwd=wd, env=env, capture_output=True, text=True,
                timeout=TASK_TIMEOUT + 120, encoding="utf-8", errors="replace",
            )
            tail = (p.stdout or "")[-1500:]
        except subprocess.TimeoutExpired:
            tail = "TIMEOUT del proceso cline"
        wall = round(time.time() - t0, 1)
        ok, why = task["check"](wd)
        out["tasks"][tid] = {"passed": ok, "detail": why, "wall_s": wall, "tail": tail}
        print(f"[{label}/cline] {tid}: {'PASS' if ok else 'FAIL'} ({why[:100]}) en {wall}s", flush=True)
        outfile.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"[{label}/cline] terminado -> {outfile}", flush=True)


if __name__ == "__main__":
    main()
