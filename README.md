# IA local en hardware modesto

**¿Puede una laptop de oficina, sin GPU y sin conexión, sustituir a un asistente comercial de programación?**

Evaluación empírica y reproducible de modelos de lenguaje abiertos ejecutados localmente para tareas reales de práctica estadística en **Python y R** — automatización de Excel, dashboards y series de tiempo.

Máquina de referencia: **Intel Core Ultra 5 225H · 32 GB DDR5 en canal único · sin GPU dedicada · Windows 11 · llama.cpp solo CPU.**

---

## Resultado: sí, con reservas medidas

**6 de 6 tareas resueltas** en modo agéntico, con código que se ejecutó de verdad y cuyos resultados se validaron — sin licencias, sin conexión y sin que los datos salgan del equipo.

| Rol | Modelo | Q4 en disco | Resultado |
|---|---|---|---|
| **Interactivo** (IDE/chat, un turno) | Qwen3-Coder-30B-A3B · MoE 30B/3.3B act. | ~18 GB | **5/6** · 17.1 tok/s |
| **Lotes desatendidos** (agéntico) | gemma-4-26B-A4B-it · MoE 25.2B/3.8B act. | ~17 GB | **6/6** · 76 min |
| **Edge** (deja la laptop usable) | Gemma 4 E4B-it · denso ~4.5B ef. | ~5 GB | **6/6** · 2.45 h |

### Los seis hallazgos que cambian cómo se elige un modelo

1. **El MoE de 30B es a la vez el más capaz y el más rápido.** Con 3.3B parámetros activos decodifica a 15-17 tok/s: más rápido que los densos de 7-8B (5.5-7.4 tok/s) en una máquina limitada por ancho de banda de memoria. Contra la intuición, aquí el modelo grande es la opción ligera.
2. **El bucle agéntico compensa conocimiento, no velocidad.** Un modelo de 4B que lee su propio error y corrige pasó de 2/6 a 5/6. La pregunta al evaluar un candidato no es solo qué sabe, sino qué tan bien itera.
3. **"Menos bits" no es gratis.** La cuantización a 2 bits ahorra 6 GB y mantiene la velocidad, pero derrumba la calidad al nivel de un modelo 4-8× menor. Preferir siempre Q4 de un modelo que quepa, nunca Q2 de uno grande.
4. **El razonamiento local es un lujo impagable.** A ~15 tok/s, los presupuestos de pensamiento que dan a estos modelos su mejor puntaje equivalen a 8-15 minutos por tarea simple. Siempre `enable_thinking:false`.
5. **La iGPU no sirve para trabajo real.** SYCL degrada la decodificación y Vulkan pierde el dispositivo con prompts de ~2,900 tokens. El benchmark sintético habría llevado a recomendar Vulkan: medir con carga realista no es opcional.
6. **El bucle agéntico solo corrige lo que el intérprete reporta como error.** Un modelo que entrega un archivo con los datos correctos pero la hoja mal nombrada no falla en ejecución, así que el agente se declara exitoso — y su "corrección" puede ser quitar el requisito en vez de cumplirlo. Hay que validar el entregable, no el código de salida.

### Lo que todavía no funciona

- **R es la debilidad universal.** Todos los modelos fallan en R de un turno (el campeón: 2/3). El fallo recurrente es el mismo en todos: fechas sin cargar `lubridate`. El bucle agéntico lo corrige solo — por eso el 6/6 solo aparece en modo agéntico. El mejor resultado medido en series de tiempo en R es de Qwopus3.6-35B-A3B (10.2 min contra 18.3 del campeón de lotes), pero ese mismo modelo pierde la tarea de Excel en R y se queda en 5/6.
- **Los lotes desatendidos tardan horas**, no minutos. Sirven para dejar corriendo, no para iterar.
- **Los números anunciados no predicen nada aquí.** KAT-Coder-V2.5 (69.4% SWE-bench Verified reportado, contra ~52% del campeón) empató en calidad y perdió en velocidad.

Informe completo, matrices y autopsias de cada fallo: **[llm_benchmark/RESULTADOS.md](llm_benchmark/RESULTADOS.md)**.

---

## Antes de replicarlo en una máquina más potente

Lee **[ETHOS.md](ETHOS.md)**. El sujeto de estudio no es el modelo: es el modelo dentro de un presupuesto de hardware que no se puede ampliar. Al correr esto en una workstation, todo pasa la suite, las conclusiones se contaminan y el listón sube — sin que nadie lo decida.

Las reglas están ahí. La corta: **todo resultado lleva su perfil de hardware, y la máquina modesta es la que decide la recomendación.**

```bash
BENCH_PROFILE=workstation-rtx4090-64gb python bench.py <modelo>
```

---

## Mapa del repositorio

| Ruta | Qué contiene |
|---|---|
| [ETHOS.md](ETHOS.md) | **Leer antes de escalar**: el principio y las reglas que lo protegen |
| [llm_benchmark/SEGUIMIENTO.md](llm_benchmark/SEGUIMIENTO.md) | Estado actual, bitácora por fases, checklist para probar un modelo nuevo |
| [llm_benchmark/RESULTADOS.md](llm_benchmark/RESULTADOS.md) | Informe técnico completo (fases 1-6b) |
| [llm_benchmark/QUE_MONITOREAR.md](llm_benchmark/QUE_MONITOREAR.md) | Ficha del modelo hipotético que valdría la pena probar |
| [monitor/](monitor/) | Radar de lanzamientos: alcance, objetivo y referencia de comparación |
| [respuestadeep/](respuestadeep/) | Investigación externa previa — incluye el [informe compass](respuestadeep/informe-compass-estado-del-arte.md) que originó la hipótesis. Verificar siempre contra la fuente primaria: estos reportes ya atribuyeron mal evidencia de R |
| `llm_benchmark/bench*.py` | El harness |
| `llm_benchmark/results/<perfil>/` | Métricas crudas en JSON, una por corrida, separadas por máquina |
| `llm_benchmark/work/<perfil>/` | El código que cada modelo escribió (solo `.py` y `.R`; lo demás se regenera) |

---

## Reproducir

**Requisitos:** Python 3.11 (`requests`, `pandas`, `openpyxl`, `plotly`, `statsmodels`), R 4.6.1 (`writexl`, `readxl`, `openxlsx`, `ggplot2`, `forecast`, `dplyr`, `readr`, `tidyr`, `lubridate`), y Ollama o llama.cpp.

```bash
python make_data.py                                    # datos sinteticos, semilla fija
python bench.py <modelo>                               # un turno via Ollama
python bench.py <etiqueta> --backend llama --port 8080 # un turno via llama-server
python bench_cline.py <etiqueta> [tarea...]            # agentico via Cline CLI
python bench_zero.py <etiqueta> [tarea...]             # agentico via Zero
```

Rutas configurables por variable de entorno (los valores por omisión son los de la máquina de referencia): `BENCH_PROFILE`, `BENCH_RSCRIPT`, `BENCH_R_BIN`, `BENCH_CLINE`, `BENCH_ZERO`, `BENCH_OLLAMA`.

Protocolo detallado y checklist en [SEGUIMIENTO.md](llm_benchmark/SEGUIMIENTO.md).

**No se versionan los pesos** (42 GB de GGUF). Descargarlos de `unsloth` o `bartowski` a `llama_cpp/`.

---

## Contexto

Trabajo para evaluar la IA local en equipo institucional como alternativa sin costo de licenciamiento a los asistentes comerciales de programación. Los datos del benchmark son sintéticos y reproducibles; el caso de validación adicional usa datos abiertos públicos del ITAEE.

[abxda](https://github.com/abxda)
