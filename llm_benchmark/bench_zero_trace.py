# Variante instrumentada de bench_zero.py para AUTOPSIA, no para puntuar.
#
# Contrato identico al oficial: importa las mismas TASKS, el mismo agent_prompt,
# el mismo checker y el mismo --auto high --max-turns 25. Lo unico que cambia es
# la OBSERVABILIDAD:
#   - --output-format stream-json: el JSONL trae los argumentos de cada tool call
#     (el 'text' de bench_zero.py muestra el resultado de bash pero NO el comando).
#   - --init-session-id: persiste la sesion para poder usar 'zero search/sessions'.
#   - guarda la salida COMPLETA por tarea; bench_zero.py solo conserva 1500 chars,
#     que fue justo por lo que se perdio la evidencia del borrado en ts_r.
#
# Los resultados se escriben con sufijo _zerotrace para no tocar el JSON oficial.
import hashlib
import json
import os
import subprocess
import sys
import time

import bench
from bench_cline import agent_prompt, R_BIN, TASK_TIMEOUT

ZERO = os.environ.get("BENCH_ZERO", "zero")


def main():
    label = sys.argv[1]
    solo = sys.argv[2:]
    outfile = bench.RESULTS / f"{label.replace(':', '_')}_zerotrace.json"
    logdir = bench.RESULTS / f"{label.replace(':', '_')}_traces"
    logdir.mkdir(parents=True, exist_ok=True)

    out = json.loads(outfile.read_text(encoding="utf-8")) if outfile.exists() else {
        "model": label, "profile": bench.PROFILE, "mode": "zero-agent-trace", "tasks": {}
    }

    env = dict(os.environ)
    env["PATH"] = R_BIN + os.pathsep + env["PATH"]

    for task in bench.TASKS:
        tid = task["id"]
        if solo and tid not in solo:
            continue
        if not solo and tid in out["tasks"]:
            continue
        wd = bench._fresh_workdir(f"zerotrace_{label.replace(':', '_')}_{tid}")
        # id de sesion determinista por (label, tarea): hex de 32, formato que acepta Zero
        sid = hashlib.sha256(f"{label}/{tid}".encode()).hexdigest()[:32]
        logfile = logdir / f"{tid}.jsonl"
        t0 = time.time()
        try:
            p = subprocess.run(
                [ZERO, "exec", "--auto", "high", "--max-turns", "25",
                 "-C", str(wd), "--output-format", "stream-json",
                 "--init-session-id", sid, agent_prompt(task)],
                cwd=wd, env=env, capture_output=True, text=True,
                timeout=TASK_TIMEOUT, encoding="utf-8", errors="replace",
            )
            full = (p.stdout or "") + (p.stderr or "")
        except subprocess.TimeoutExpired as e:
            full = f"TIMEOUT del proceso zero\n{e.stdout or ''}{e.stderr or ''}"
        logfile.write_text(full, encoding="utf-8")
        wall = round(time.time() - t0, 1)
        # Foto del workdir al terminar: para ver si el entregable existio y desaparecio.
        listing = sorted(f.name for f in wd.iterdir())
        ok, why = task["check"](wd)
        out["tasks"][tid] = {
            "passed": ok, "detail": why, "wall_s": wall,
            "session_id": sid, "trace": str(logfile), "workdir_final": listing,
        }
        print(f"[{label}/trace] {tid}: {'PASS' if ok else 'FAIL'} ({why[:80]}) en {wall}s "
              f"| archivos: {listing}", flush=True)
        outfile.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"[{label}/trace] terminado -> {outfile}", flush=True)


if __name__ == "__main__":
    main()
