# Adaptación Linux — perfil desktop-tr3990x-rtx3060-12gb-cuda

Puerto de pruebas ágil del benchmark en una máquina Linux con GPU modesta
(RTX 3060 12 GB). El rol de este perfil, según [ETHOS.md](../ETHOS.md), es
**explorar y acelerar**: iterar rápido sobre modelos pequeños y candidatos
nuevos. La recomendación del proyecto la sigue decidiendo el perfil de
referencia (`laptop-inegi-ultra5-32gb-1dimm`); lo que brille aquí se
re-valida después en la laptop, a su velocidad real.

## Máquina

| | |
|---|---|
| Perfil | `desktop-tr3990x-rtx3060-12gb-cuda` |
| CPU | AMD Ryzen Threadripper 3990X (64c/128t) |
| RAM | 256 GB DDR4 |
| GPU | NVIDIA RTX 3060 12 GB (CUDA 12.6, driver 595) |
| SO | Ubuntu 26.04 LTS |
| Stack | llama.cpp b10155 (CUDA, compilado local) · Zero 0.5.0 (npm, proveedor `local-llama` → 8080) · Python 3.13 (venv en `../.venv`) · R 4.5.2 (paquetes en `~/R/library`) |

El harness (`bench*.py`) no se tocó: toda la adaptación va por variables de
entorno (`perfil.env`), tal como lo prevé el diseño del repo.

## Uso

```bash
# 1. Servidor (terminal aparte o nohup). Para MoE que no cabe en 12 GB,
#    el segundo argumento manda expertos de N capas a CPU:
./servidor.sh ../llama_cpp/gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf 24

# 2. Suite agéntica Zero (la etiqueta nombra el JSON de results/):
./bench_zero.sh gemma-4-26B-A4B

# Un turno:
source perfil.env && cd ../llm_benchmark && $VENV_PY bench.py <etiqueta> --backend llama
```

## Notas de la puesta en marcha (2026-07-27)

- llama.cpp se compiló con CUDA usando g++ 13 de conda-forge como host
  compiler (`~/miniconda3/envs/gxx13`), porque nvcc 12.6 no acepta el
  gcc 15 del sistema y no hay binarios CUDA de Linux en los releases.
- Zero se configuró con `zero providers add custom-openai-compatible
  --name local-llama --base-url http://localhost:8080/v1 --model local`.
- La lección 7 del proyecto ("la iGPU no sirve") no aplica aquí: es una
  dGPU con CUDA. El humo con prompt largo (~2,900 tokens) se repitió de
  todas formas antes de correr la suite.
