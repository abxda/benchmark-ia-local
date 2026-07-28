# Resultados del experimento: modelo local para programar en Python y R

**Fecha:** 2026-07-22
**Equipo:** Intel Core Ultra 5 225H (Arrow Lake-H, 14 núcleos) · 32 GB DDR5-5600 **canal único** (1 DIMM) · iGPU Intel Arc · Windows 11
**Runtime:** Ollama 0.32.1 — ejecución **100% CPU** (el binario oficial de Ollama no acelera iGPU Intel, como advierte el informe compass)
**Configuración:** temperatura 0, num_ctx 8192, pensamiento desactivado donde aplica

## Método

Para cada modelo se midió:

1. **Velocidad** (prefill y decodificación en tok/s) con un prompt corto (~25 tokens) y uno largo (~2,900 tokens), 2 repeticiones, vía métricas nativas de la API de Ollama.
2. **Suite de 6 tareas reales** (3 dominios × 2 lenguajes): automatización de Excel, generación de dashboards y pronóstico de series de tiempo, en Python y en R. El código generado se **ejecutó realmente** y se validó el resultado (totales correctos por región en el Excel, archivos de dashboard válidos, pronóstico de 12 meses dentro de rango plausible). Entorno: Python 3.11 (pandas, openpyxl, plotly, statsmodels) y R 4.6.1 (writexl, readxl, openxlsx, ggplot2, forecast, dplyr, readr, tidyr, lubridate).

Datos sintéticos reproducibles (`make_data.py`, semilla fija): ventas por región/mes y una serie mensual de 72 puntos con tendencia y estacionalidad.

## Resultados

| Modelo | Tamaño en RAM | Decode tok/s (estable) | Prefill tok/s (caché fría) | Python | R | Total |
|---|---|---|---|---|---|---|
| **qwen3-coder:30b** (MoE 30B/3.3B act.) | 19 GB | **14–16** | ~46 | **3/3** | **2/3** | **5/6** |
| qwen3.5:4b | ~4 GB | 11–12 | ~65 | 2/3 | 0/3 | 2/6 |
| qwen2.5-coder:7b | ~6 GB | 7.4 | ~40 | 1/3 | 1/3 | 2/6 |
| qwen3:8b | ~7 GB | 5.5–6.6 | ~34 | 2/3 | 0/3 | 2/6 |

Detalle por tarea (P = pasó, F = falló):

| Tarea | 30b | 4b | 7b-coder | 8b |
|---|---|---|---|---|
| Excel Python (pandas/openpyxl) | P | P | F¹ | P |
| Excel R (writexl) | F² | F | F | F |
| Dashboard Python (plotly) | P | P | P | P |
| Dashboard R (ggplot2) | P | F | P | F |
| Series de tiempo Python (Holt-Winters) | P | F | F | F |
| Series de tiempo R (auto.arima) | P | F | F | F |

¹ Generó el archivo pero no respetó la especificación exacta de columnas.
² Usó `read_excel()` de readxl para leer un CSV.

## Hallazgos

1. **El MoE de 30B es a la vez el más capaz Y el más rápido.** Con solo 3.3B parámetros activos decodifica a 14–16 tok/s, más rápido que los densos de 7–8B (5.5–7.4 tok/s) en esta máquina limitada por ancho de banda de memoria. Confirma exactamente la predicción del informe compass (~10–18 tok/s).
2. **R es el punto débil de todos los modelos**, tal como advertía el informe: los modelos ≤8B pasaron 0–1 de 3 tareas de R; solo el 30B logró 2/3. La verificación humana del código R sigue siendo obligatoria.
3. **Las tareas de series de tiempo separan a los modelos**: solo el 30B las resolvió (en ambos lenguajes). Excel y dashboards en Python los resuelve casi cualquier modelo.
4. **El prefill es el costo oculto**: ~35–65 tok/s en frío significa que un prompt de 4,000 tokens (típico de un agente tipo Cline) tarda 1–2 minutos en procesarse la primera vez. Usar `keep_alive` largo y prompts compactos.
5. **La ejecución es 100% CPU** (19 GB en RAM para el 30B, cabe con holgura en 32 GB, dejando ~13 GB para IDE + R + Python).

## Recomendación

- **Modelo principal: `qwen3-coder:30b` con Ollama** (temperatura 0 para código, num_ctx 8192–16384, `keep_alive` largo). Es la única opción probada que resuelve las tres áreas objetivo en ambos lenguajes.
- Como asistente ligero de respuesta rápida, `qwen3.5:4b` es preferible a los 7–8B: más rápido y con igual tasa de éxito. Los densos qwen2.5-coder:7b y qwen3:8b no aportan nada en esta máquina: más lentos y sin mejor calidad.
- **Instalar el segundo módulo DDR5-5600** (canal único confirmado empíricamente como cuello de botella): duplicaría el ancho de banda y con ello los tok/s de decodificación (~25–30 esperables para el 30B).
- Revisión humana obligatoria del código R, especialmente lectura de datos y manejo de fechas, donde se concentraron los fallos.

## Fase 2 — Runtimes alternativos y cuantizaciones extremas (2026-07-22)

Se evaluó el mismo `qwen3-coder:30b` sobre runtimes alternativos, más dos modelos de
cuantización extrema propuestos como "tipo BitNet". vLLM se descartó sin prueba: requiere
Linux y GPU dedicada (su backend CPU no compila en Windows); en WSL2 rendiría por debajo
de llama.cpp.

### Velocidad por runtime/modelo (llama-bench, pp512/tg128)

| Configuración | RAM | Prefill | Decode | Condiciones |
|---|---|---|---|---|
| 30B Q4 · Ollama (CPU) | 19 GB | ~46–65 | 14–16 | 14 hilos |
| 30B Q4 · llama.cpp CPU | 18 GB | 64.8 | 13.7 | 14 hilos |
| **30B Q4 · llama.cpp CPU** | 18 GB | **67.2** | **15.5** | **10 hilos, prioridad baja** |
| 30B Q4 · Vulkan iGPU (expertos en CPU) | 18 GB | 64.6 | 9.9 | 14 hilos |
| 30B Q4 · Vulkan iGPU (24/48 capas) | 18 GB | 97.1 | 12.7 | 14 hilos |
| Qwen3.6-35B-A3B UD-Q2_K_XL (2-bit) | 12.3 GB | 44.5 | 14.8 | 10 hilos, prioridad baja |
| Bonsai 27B ternario (1.71 bit, denso) | 6.7 GB | 3.2 | 2.3 | 10 hilos, prioridad baja |

Notas:
- Con 10 hilos rinde MÁS que con 14 (menos contención en canal único de memoria); además deja la laptop usable.
- La iGPU no mejora la decodificación (comparte el mismo ancho de banda) pero el offload parcial de 24 capas mejora el prefill ~50% (97 tok/s). No se observó salida corrupta Vulkan en los benches, aunque la validación de texto generado por Vulkan quedó pendiente (no aporta al caso de uso principal).
- El offload completo a iGPU falla por memoria (Windows limita la GPU compartida a ~16 GB y el modelo pesa 17.3 GiB).

### Calidad en la suite de 6 tareas

| Modelo | Python | R | Total |
|---|---|---|---|
| 30B Q4 vía llama.cpp CPU | 3/3 | 2/3 | **5/6** (idéntico a Ollama) |
| Qwen3.6-35B 2-bit (sin razonamiento) | 1/3 | 1/3 | 2/6 |
| Qwen3.6-35B 2-bit (con razonamiento) | — | — | inutilizable: 8 min y 6,000 tokens de puro pensamiento sin producir código (2 tareas probadas) |
| Bonsai 27B ternario | — | — | no evaluado: descartado por velocidad |

### Hallazgos de la fase 2

1. **Ollama y llama.cpp CPU son equivalentes** en velocidad y calidad para el 30B (mismo motor). La ventaja de llama.cpp es el control fino (hilos, prioridad, offload); la de Ollama, la simplicidad operativa.
2. **"Menos bits" no es gratis.** El 2-bit dinámico del Qwen3.6-35B ahorra 6 GB y decodifica bien (14.8 tok/s), pero la calidad cayó al nivel de los modelos de 4-8B (2/6). El ternario denso (Bonsai) es 6× más lento: la cuantización extrema ahorra memoria, no cómputo, y en denso el cómputo manda.
3. **El razonamiento local es un lujo que esta máquina no puede pagar**: a ~14 tok/s, los presupuestos de pensamiento que dan a esta familia su ~90% en R equivalen a 10-15 min por tarea simple.
4. **Config óptima descubierta: 10 hilos** (no 14) — más rápido y la laptop sigue usable.
5. Ruta iGPU prometedora solo para prefill (offload parcial de capas + generación en CPU no es combinable hoy en un solo proceso; no se justifica).

### Recomendación final (sin cambios, ahora con más evidencia)

**`qwen3-coder:30b` Q4_K_M** sigue siendo imbatible en esta laptop: el más capaz (5/6) y
el más rápido (15.5 tok/s decode). Runtime: **Ollama** para simplicidad de flota, o
**llama.cpp** (`llama-server -t 10`) si se quiere el ~10% extra de rendimiento y control.
Ninguna alternativa de cuantización extrema lo supera en ningún eje relevante.

## Fase 3 — KAT-Coder-V2.5-Dev (2026-07-23)

Primer candidato surgido del monitoreo (`QUE_MONITOREAR.md`): Kwaipilot KAT-Coder-V2.5-Dev,
MoE 35B-A3B construido sobre Qwen3.6-35B-A3B con RL agéntico para código (SWE-bench
Verified 69.4% reportado, presumiblemente con razonamiento). Probado en **IQ4_XS de
bartowski (18.8 GB)** sobre llama.cpp b10088 CPU, 10 hilos, prioridad baja,
`enable_thinking: false` (verificado: cero tokens de razonamiento).

| Métrica | KAT-Coder-V2.5 IQ4_XS | qwen3-coder:30b Q4_K_M (campeón) |
|---|---|---|
| Decode (estable) | 12.9–13.4 tok/s | **15.5 tok/s** |
| Prefill | 42–60 tok/s | **67 tok/s** |
| Python | **3/3** | **3/3** |
| R | 2/3 (falló series de tiempo) | 2/3 (falló Excel) |
| Total | **5/6** | **5/6** |

Detalle clave: KAT-Coder es el **primer modelo que pasa Excel en R** (writexl correcto,
donde el campeón usó readxl para leer un CSV). Su único fallo fue en series de tiempo R:
usó `months()` de lubridate sin cargar la librería (`library(lubridate)` ausente) — otra
vez la categoría "fechas en R". El pronóstico en sí (auto.arima) estaba bien planteado.

### Veredicto

**Empate en calidad (5/6 vs 5/6, con fallos de R complementarios), pero 13–15% más lento
y 0.8 GB más de RAM.** No destrona al campeón: a igual calidad, la velocidad decide.
Matiz importante: el 2/6 del Qwen3.6 base en 2-bit (fase 2) queda explicado — era culpa
de la cuantización extrema, no de la familia; en Q4 esta arquitectura rinde al nivel del
campeón. Si Kwaipilot publicara una variante no-pensante nativa o el modelo se usara en
scaffold agéntico (donde su entrenamiento RL importa más que el chat de un turno), valdría
la pena re-evaluar.

## Fase 4 — Modo agéntico: Cline y Zero (2026-07-23/24)

Se repitió la suite de 6 tareas en **modo agéntico**: el modelo, envuelto en un harness
(Cline CLI 3.0.46 headless y Zero 0.5.0 `exec`), debe escribir el script, **ejecutarlo él
mismo, leer los errores y auto-corregirse** (límite 30 min/tarea). Mismo `llama-server`
(b10088, 10 hilos, prioridad baja, ctx 32k, `--cache-reuse`) y mismos checkers de las
fases 1-3; la especificación de cada tarea es idéntica. Se añadió el mejor modelo pequeño
(qwen3.5:4b, GGUF Q4_K_M de unsloth, 2.7 GB) solo con Zero.

### La matriz completa (aciertos · tiempo total de la suite)

| Modelo | Un turno (fase 1-3) | Cline | Zero |
|---|---|---|---|
| qwen3-coder:30b (campeón) | 5/6 · ~5 min | 4/6 · 89 min | **6/6 · 3.6 h** |
| KAT-Coder-V2.5 IQ4_XS | 5/6 · ~6 min | 5/6 · 74 min | 5/6 · **67 min** |
| qwen3.5:4b | 2/6 · ~4 min | — | **5/6** · 2.1 h |

### Autopsias (cada fallo fue diagnosticado ejecutando a mano el código del agente)

- **Campeón × Cline, dash_r y ts_r**: el código del agente era **correcto en ambas**
  (ejecutado a mano: rc=0, salidas válidas que pasan el checker). Falló el harness: en
  Windows, Cline ejecuta vía PowerShell 5.1, que envuelve cualquier texto en stderr como
  `NativeCommandError` — las advertencias inofensivas de R (deprecación de ggplot2,
  mensajes de carga de `forecast`) se vuelven "errores fantasma", el agente pelea contra
  ellos y se rinde. Excel R pasó porque `writexl` carga en silencio.
- **KAT × Cline, ts_r**: mismo error fantasma, respuesta distinta — su script era correcto
  desde el minuto 7, pero el agente concluyó que `forecast` estaba roto y se fue a
  reinstalarlo desde CRAN (descargó el tarball) hasta agotar los 30 min.
- **KAT × Zero, excel_r**: fallo genuino de especificación — creó el xlsx sin la hoja
  'Resumen' y cerró satisfecho sin verificar el nombre.
- **4b × Zero, excel_r**: fallo genuino de conocimiento — inventó la función `writexl()`
  (la real es `write_xlsx`) y 35 min de iteraciones no le alcanzaron para descubrirlo.

### Hallazgos de la fase 4

1. **El único 6/6 de todo el experimento es campeón × Zero** — el modo agéntico con un
   harness robusto desbloqueó las tareas de R que ningún setup de un turno completó. Costo:
   3.6 h la suite (~36 min/tarea), dominadas por el prefill de contextos agénticos largos.
2. **El harness importa tanto como el modelo.** Zero (agente en Go que juzga por código de
   salida real) es inmune a los errores fantasma que le costaron 2 tareas a Cline en
   Windows. Cline, cuando funciona, es 2-3× más rápido por tarea. Con R en Windows,
   Cline no es confiable hoy; con Python puro, sí.
3. **El entrenamiento agéntico de KAT-Coder es real**: 5/6 en los tres modos (el más
   consistente), el más rápido por tarea agéntica (11-12 min), y el único que intentó
   rodear el error fantasma con estrategias alternativas. Su SWE-bench de 69.4% se
   traduce en eficiencia de iteración, no en un techo de calidad más alto aquí.
4. **El bucle agéntico transforma a los modelos pequeños: 4b pasó de 2/6 a 5/6.** Un
   modelo de 2.7 GB que no sabe escribir el script perfecto a la primera sí sabe leer un
   error real y corregirlo. Rescató dash_r, ts_py y ts_r — todas las que fallaba en un
   turno salvo la de conocimiento puro de API. Nueva economía: modelo chico + agente
   robusto ≈ calidad de modelo grande de un turno, pagando con tiempo de pared.
5. **Los fallos que sobreviven al modo agéntico son de dos tipos**: lagunas de
   conocimiento de API (4b inventando funciones) y disciplina de especificación (KAT sin
   verificar el nombre de hoja). Ninguno es de velocidad ni de runtime.
6. Nota operativa: los blobs GGUF de Ollama no siempre cargan en llama.cpp mainline
   (el de qwen3.5:4b traía metadatos `rope.dimension_sections` incompatibles; el del
   30B sí funcionó). Verificar antes de asumir compatibilidad.

### Recomendación tras la fase 4

- **Uso interactivo (chat/completions en el IDE)**: sin cambios — `qwen3-coder:30b` un
  turno (5/6 en ~15 s/tarea de generación).
- **Tareas desatendidas por lote** (deja corriendo y regresa): **Zero + qwen3-coder:30b**
  para máxima calidad (6/6), o **Zero + qwen3.5:4b** si la RAM debe quedar libre — 5/6
  con solo 2.7 GB residentes es el resultado más sorprendente del experimento.
- **KAT-Coder-V2.5** es la mejor combinación velocidad/calidad agéntica (5/6 en ~67 min)
  y el más robusto a harnesses imperfectos; vale la pena conservar su GGUF.
- **Cline en Windows**: solo para Python hasta que su ejecución maneje stderr de R con
  códigos de salida reales (o usar PowerShell 7+/otro shell si se vuelve configurable).

## Fase 5 — Gemma 4 E4B (2026-07-24)

A petición: **Gemma 4 E4B** (Google, marzo 2026), arquitectura edge con Per-Layer
Embeddings — 4.5B parámetros efectivos / 8B totales, Q4_K_M de **4.98 GB** (unsloth),
soporte llama.cpp mainline desde el día 1. Piensa por defecto, pero `enable_thinking:false`
funciona con su plantilla (verificado). Mismo protocolo: suite de un turno + suite
agéntica con Zero, mismo stack (b10088, 10 hilos, prioridad baja, temperatura 0).

### Resultados

| Métrica | Gemma 4 E4B | qwen3.5:4b (rival directo) |
|---|---|---|
| Decode / prefill | 9.2–10.8 / 60–71 tok/s | 11–12 / ~65 tok/s |
| Un turno | **4/6** (falló excel_r y ts_r) | 2/6 |
| Zero agéntico | **6/6 · 2.45 h** | 5/6 · 2.1 h |

- **Un turno 4/6 es el mejor resultado de un modelo pequeño en modo directo** de todo el
  experimento — incluye ts_py (Holt-Winters), que en fase 1 solo el 30B pasó. Sus dos
  fallos fueron los clásicos de R.
- **Con Zero: 6/6 — el segundo marcador perfecto del experimento**, y el primero de un
  modelo pequeño. El bucle agéntico rescató ambas tareas de R (excel_r en 21 min, ts_r
  en 19). Suite completa en 2.45 h vs 3.6 h del campeón de 30B.
- Rareza: su primera tarea agéntica tomó 47 min (la más fácil); el resto ya en ritmo
  normal de 10-27 min.

### La matriz final del experimento completo

| Modelo | RAM | Un turno | Cline | Zero |
|---|---|---|---|---|
| qwen3-coder:30b | 18 GB | **5/6** · ~5 min | 4/6 · 89 min | **6/6** · 3.6 h |
| KAT-Coder-V2.5 | 18.8 GB | 5/6 · ~6 min | **5/6** · 74 min | 5/6 · **67 min** |
| **Gemma 4 E4B** | **5 GB** | 4/6 · ~5 min | — | **6/6 · 2.45 h** |
| qwen3.5:4b | 2.7 GB | 2/6 · ~4 min | — | 5/6 · 2.1 h |

### Veredicto de la fase 5

**Gemma 4 E4B redefine la categoría pequeña**: mejor un turno que cualquier ≤8B probado
(4/6), y en agéntico iguala el 6/6 del campeón siendo **3.6× más ligero en RAM y 32%
más rápido en la suite**. Para lotes desatendidos es la nueva recomendación por defecto:
deja 27 GB de RAM libres mientras trabaja. El 30B conserva el uso interactivo (5/6 de un
turno con 50% más velocidad de generación y respuestas más largas por minuto); para
chat rápido con mínima RAM, Gemma 4 E4B también sustituye a qwen3.5:4b.

## Fase 6a - Backends de iGPU: SYCL y Vulkan a fondo (2026-07-26)

Surgido de la investigación externa, que afirmaba que el backend **SYCL** (oneAPI de Intel)
supera a Vulkan en Arrow Lake. Nunca lo habíamos probado: la fase 2 fue solo CPU y Vulkan.
Se usaron los binarios precompilados de **llama.cpp b10107** (cpu, sycl y vulkan, mismo
build para que la comparación sea limpia), `llama-bench` pp512/tg128, prioridad baja y
**sin `-fa`** (bug documentado de corrupción en Arrow Lake Xe2, issue 19276).

La iGPU expone 16.8 GB, así que **Gemma 4 E4B (5 GB) cabe completo y el 30B (17.3 GiB) no**.

| Configuración | Prefill | Decode |
|---|---|---|
| **E4B · Vulkan, offload total** | **293.1** | 11.6 |
| E4B · SYCL, offload total | 154.0 | 9.0 |
| E4B · CPU, 10 hilos | 81.9 | **12.0** |
| 30B · CPU, 10 hilos | 70.2 | **17.1** |
| 30B · SYCL, 24 capas | 69.2 | 10.8 |

### Hallazgos

1. **SYCL es un callejón sin salida en esta máquina.** En el 30B no mejora el prefill
   (69.2 vs 70.2 de CPU) y hunde la decodificación (10.8 vs 17.1). En el E4B mejora el
   prefill pero castiga la decodificación un 25%. La afirmación de la investigación
   externa queda **refutada empíricamente**.
2. **Vulkan con offload total da números espectaculares en el benchmark sintético**
   (3.6× el prefill de CPU con la decodificación casi intacta)... **y falla en carga real.**
   Al procesar un prompt de ~2,900 tokens el driver pierde el dispositivo
   (`vk::Device::getFenceStatus: ErrorDeviceLost`) tras ~2,000 tokens. Se reintentó con
   lotes reducidos (`-b 512 -ub 128`), la mitigación estándar para timeouts de GPU:
   **falló idénticamente**. La salida no sale corrupta (la prueba de humo fue perfecta);
   el dispositivo simplemente muere. **La iGPU no es viable para trabajo real aquí.**
3. **Actualizar el build da rendimiento gratis**: b10088 → b10107 subió el 30B de
   67.2/15.5 a **70.2/17.1** (+10% de decodificación) sin cambiar nada más.
4. Lección de método: el benchmark sintético (pp512) habría llevado a recomendar Vulkan.
   Solo la prueba con carga real reveló que se cae. **Medir con prompts realistas no es
   opcional.**

### Consecuencia práctica

Se mantiene **CPU con 10 hilos** como única configuración de producción, ahora sobre
**b10107** por el +10% gratuito. La ruta de iGPU queda cerrada hasta que cambie el driver
o el backend.

## Fase 6b - gemma-4-26B-A4B: el nuevo campeón agéntico (2026-07-26)

Candidato surgido de dos vías que convergieron: nuestro propio radar (patrón MoE ≤35B
totales / ≤4B activos) y la evidencia externa de **Simon Couch**, que lo midió al **90%
en helperbench** (refactorización real en R). Advertencia de método: los reportes de
investigación afirmaban que Couch había validado a Qwen3.5-9B y a Gemma 4 E4B; al leer
el post original se confirmó que probó **gemma-4 26B-A4B y Qwen3.5 35B-A3B** (los MoE),
en una MacBook M4 Pro y con andamiaje agéntico. La cita estaba mal atribuida en ambos.

MoE 25.2B totales / **3.8B activos**, UD-Q4_K_XL de 17.0 GB, llama.cpp b10107 CPU,
10 hilos, prioridad baja, `enable_thinking:false` verificado (33 tokens, cero razonamiento).

| Métrica | gemma-4-26B-A4B | qwen3-coder:30b (campeón) |
|---|---|---|
| RAM | 17.0 GB | 18 GB |
| Decode / prefill | 8.4–10.4 / 36–46 | **17.1 / 70.2** |
| Un turno | 5/6 | 5/6 |
| **Agéntico (Zero)** | **6/6 · 76 min** | 6/6 · 214 min |

### Hallazgos

1. **6/6 agéntico en 76 minutos**: tercer marcador perfecto del experimento y **el más
   rápido con diferencia** — 2.8× más veloz que el campeón (214 min) y casi 2× más que
   Gemma 4 E4B (147 min), pese a decodificar más lento. Menos iteraciones desperdiciadas.
2. **En un turno empata (5/6) con perfil complementario**: pasó Excel R y dashboard R
   (el campeón falla Excel R) y solo falló series de tiempo R. Pero es **40% más lento**,
   así que no destrona al campeón interactivo.
3. **El fallo de un turno fue, otra vez, fechas en R**: usó `%m+%` y `months()` de
   lubridate sin cargar la librería — el mismo error exacto de KAT-Coder. Es el patrón
   de fallo más consistente del experimento y el bucle agéntico lo corrigió solo.
4. **La evidencia externa en R se confirma en nuestra suite**: es el primer modelo que
   pasa las tres tareas de R en modo agéntico sin drama y una de las dos de Excel/dashboard
   R al primer intento.

### Recomendación actualizada

- **Interactivo**: sigue `qwen3-coder:30b` (5/6 a 17.1 tok/s con b10107).
- **Lotes desatendidos**: **`gemma-4-26B-A4B` + Zero** sustituye al 30B como opción de
  máxima calidad — mismo 6/6 en **un tercio del tiempo**. Si la RAM debe quedar libre,
  Gemma 4 E4B (6/6, 5 GB, 147 min) sigue siendo la opción ligera.

## Perfil `desktop-tr3990x-rtx3060-12gb-cuda` — estreno y ancla (2026-07-28)

> Sección de perfil NO-referencia (ver ETHOS.md): esta máquina explora y acelera;
> las recomendaciones siguen saliendo del perfil `laptop-inegi-ultra5-32gb-1dimm`.

Hardware: Threadripper 3990X (64c) · 256 GB DDR4 · RTX 3060 12 GB · Ubuntu 26.04.
Stack: llama.cpp **b10155 CUDA**, Zero 0.5.0, mismos prompts/checkers/turnos que la laptop.

### Corrida ancla: gemma-4-26B-A4B × Zero (campeón vigente)

Config: UD-Q4_K_XL 17 GB, `--n-gpu-layers 999 --n-cpu-moe 22` (con escritorio abierto
ocupando ~2.1 GB de VRAM; con GPU limpia cabe 18), ctx 32K, thinking off. 10.5/12.3 GB.

| Tarea | Resultado | Tiempo |
|---|---|---|
| excel_py | PASS | 49.8s |
| excel_r | PASS | 78.0s |
| dash_py | PASS | 65.8s |
| dash_r | PASS | 77.0s |
| ts_py | PASS | 83.3s |
| ts_r | PASS | 193.8s |
| **Total** | **6/6** | **9.1 min** |

Mismo 6/6 que en laptop (76 min): el ancla reproduce, la máquina solo cambia la escala
de tiempo (~8.4×). Eso valida usar la 3060 como proxy de iteración rápida.

**Arreglo justo de entorno documentado** (no toca prompts ni checkers): `bench_zero.py`
antepone `BENCH_R_BIN` al PATH del agente; en Linux `/usr/bin` traía su propio `python3`
que tapaba el del venv (sin pandas → excel_py fallaba por infraestructura). Fix:
`linux/rbin/` con symlinks solo a R/Rscript. La tarea afectada se reejecutó desde cero.

### Candidato: Qwopus3.6-35B-A3B-Coder APEX I-Compact (2026-07-28)

Finetune de coding sobre Qwen3.6-35B-A3B (MoE, ~3B activos), Apache-2.0, quant APEX
I-Compact de mudler (17.3 GB; precisión adaptativa por experto, head MTP en Q8_0).
Pasó la autopsia documental; el resto del lote de candidatos del día se descartó sin
gastar GPU (27B denso no cabe en 12 GB, un 4B con benchmarks propios en cero, MLX
solo Apple, bases sin instruct, generación 2024 ya superada).

Config: `--n-cpu-moe 20 -t 32 --no-mmap` con GPU despejada (11.6/12.3 GB), ctx 32K,
thinking off. Velocidad: 110 tok/s prefill · **59.8 tok/s decode** (campeón: 58).

| Tarea | Qwopus (APEX I-Compact) | gemma-4-26B-A4B (ancla) |
|---|---|---|
| excel_py | PASS 47.6s | PASS 49.8s |
| excel_r | PASS 103.8s | PASS 78.0s |
| dash_py | PASS 99.7s | PASS 65.8s |
| dash_r | PASS 49.6s | PASS 77.0s |
| ts_py | PASS 44.5s | PASS 83.3s |
| ts_r | **PASS 48.9s** | PASS 193.8s |
| **Total** | **6/6 · 6.6 min** | 6/6 · 9.1 min |

Hallazgos: (1) cuarto 6/6 agéntico del experimento, ~27% más rápido que el campeón en
esta máquina; (2) `ts_r` —el punto débil histórico de todos los modelos en R— salió en
48.9s contra 193.8s del campeón, la diferencia más grande de la tabla; (3) ojo con la
comparación de configs: el ancla corrió con `-t 16` + mmap y n-cpu-moe 22, Qwopus con
`-t 32` + no-mmap y 20 — parte de la ventaja de tiempo puede ser infra, no modelo.

**Pendiente para decidir algo** (regla ETHOS: la laptop decide): revalidar en el perfil
`laptop-inegi-ultra5-32gb-1dimm`. El I-Compact de 17.3 GB cabe en los 32 GB de RAM de
la laptop en CPU puro, mismo régimen que el campeón (17 GB).

## Reproducir

```
python make_data.py
python bench.py <modelo>                              # Ollama
python bench.py <etiqueta> --backend llama --port N   # llama-server
python bench_cline.py <etiqueta> [tarea...]           # agentico via Cline CLI (servidor en 8080)
python bench_zero.py <etiqueta> [tarea...]            # agentico via Zero (servidor en 8080)
```
