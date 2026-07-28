#!/usr/bin/env bash
# Levanta llama-server (CUDA) en el puerto 8080 con alias 'local', thinking off.
# Uso: ./servidor.sh <ruta.gguf> [n_cpu_moe] [threads]
#   n_cpu_moe: capas MoE cuyos expertos van a CPU (default 24; subir si no cabe en 12 GB).
#   threads: hilos CPU para los expertos offloadeados (default 16; en el TR3990X 32 rinde
#            mejor; mas alla suele saturar el ancho de banda de memoria, no ayuda).
set -euo pipefail
source "$(dirname "$0")/perfil.env"

GGUF="${1:?uso: servidor.sh <ruta.gguf> [n_cpu_moe] [threads]}"
NCPUMOE="${2:-24}"
THREADS="${3:-16}"

# Mismo contrato que la maquina de referencia: puerto 8080, alias 'local', thinking off.
export LLAMA_ARG_CHAT_TEMPLATE_KWARGS='{"enable_thinking":false}'
exec "$LLAMA_BIN/llama-server" \
  -m "$GGUF" \
  --n-gpu-layers 999 \
  --n-cpu-moe "$NCPUMOE" \
  -c 32768 \
  --cache-reuse 256 \
  --port 8080 \
  -a local \
  --no-mmap \
  -t "$THREADS"
