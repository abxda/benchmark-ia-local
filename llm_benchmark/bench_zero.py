# Fase 4b: benchmark agentico con Zero (zero exec headless) sobre llama-server local.
# Uso: python bench_zero.py <etiqueta>
# Mismo diseno que bench_cline.py: mismas tareas, mismos checkers, solo cambia el harness.
import json
import os
import subprocess
import sys
import time
from pathlib import Path

import bench
from bench_cline import agent_prompt, R_BIN, TASK_TIMEOUT

ZERO = os.environ.get("BENCH_ZERO", r"C:\Users\abel.coronado\AppData\Roaming\npm\zero.cmd")


def main():
    label = sys.argv[1]
    solo = sys.argv[2:]  # ids de tareas a correr; vacio = todas las que falten
    outfile = bench.RESULTS / f"{label.replace(':', '_')}_zero.json"
    if outfile.exists():
        out = json.loads(outfile.read_text(encoding="utf-8"))
    else:
        out = {"model": label, "profile": bench.PROFILE, "mode": "zero-agent", "tasks": {}}

    env = dict(os.environ)
    env["PATH"] = R_BIN + os.pathsep + env["PATH"]

    for task in bench.TASKS:
        if solo and task["id"] not in solo:
            continue
        if not solo and task["id"] in out["tasks"]:
            continue
        tid = task["id"]
        wd = bench._fresh_workdir(f"zero_{label.replace(':', '_')}_{tid}")
        t0 = time.time()
        try:
            p = subprocess.run(
                [ZERO, "exec", "--auto", "high", "--max-turns", "25",
                 "-C", str(wd), "--output-format", "text", agent_prompt(task)],
                cwd=wd, env=env, capture_output=True, text=True,
                timeout=TASK_TIMEOUT, encoding="utf-8", errors="replace",
            )
            tail = ((p.stdout or "") + (p.stderr or ""))[-1500:]
        except subprocess.TimeoutExpired:
            tail = "TIMEOUT del proceso zero"
        wall = round(time.time() - t0, 1)
        ok, why = task["check"](wd)
        out["tasks"][tid] = {"passed": ok, "detail": why, "wall_s": wall, "tail": tail}
        print(f"[{label}/zero] {tid}: {'PASS' if ok else 'FAIL'} ({why[:100]}) en {wall}s", flush=True)
        outfile.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"[{label}/zero] terminado -> {outfile}", flush=True)


if __name__ == "__main__":
    main()
