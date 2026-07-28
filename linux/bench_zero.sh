#!/usr/bin/env bash
# Corre la suite agentica Zero contra el llama-server local (puerto 8080).
# Uso: ./bench_zero.sh <etiqueta> [tarea...]
set -euo pipefail
source "$(dirname "$0")/perfil.env"
cd "$(dirname "$0")/../llm_benchmark"
exec "$VENV_PY" bench_zero.py "$@"
