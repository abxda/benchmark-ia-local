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
> las recomendaciones siguen saliendo del perfil `laptop-ref-ultra5-32gb-1dimm`.

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
`laptop-ref-ultra5-32gb-1dimm`. El I-Compact de 17.3 GB cabe en los 32 GB de RAM de
la laptop en CPU puro, mismo régimen que el campeón (17 GB).

### Candidato: NVIDIA-Nemotron-3.5-Lightning-30B-A3B Q4_K_M (2026-08-10)

MoE híbrido **Mamba-2 + MoE + atención**, 30B totales / **3B activos**, GGUF oficial de
**ggml-org** (la organización de llama.cpp). Licencia OpenMDW-1.1 (no Apache: revisar si
alguna vez llega a recomendación institucional). NVIDIA declara SWE-bench Verified 51.6
(BF16) / 52.8 (NVFP4) con arnés propio y recetas publicadas en NeMo Gym — más auditable
que el 62.4 auto-reportado de Qwopus, aunque más bajo.

Pasa los dos filtros de la lección 14: MoE de 3B activos y `enable_thinking` respetado
(humo con `reasoning_content: None`). Config: Q4_K_M de 25.4 GB, `--n-cpu-moe 40 -t 32
--no-mmap`, 10.4/12.3 GB de VRAM; con 34 no cabe. Velocidad: **47.7 tok/s decode**.

| Tarea | Nemotron 3.5 Lightning | gemma-4-26B-A4B (ancla) |
|---|---|---|
| excel_py | PASS 68.3s | PASS 49.8s |
| excel_r | **PASS 100.1s** | PASS 78.0s |
| dash_py | PASS 125.9s | PASS 65.8s |
| dash_r | PASS 119.8s | PASS 77.0s |
| ts_py | PASS 91.6s | PASS 83.3s |
| ts_r | **FAIL 103.1s** | PASS 193.8s |
| **Total** | **5/6 · 10.1 min** | 6/6 · 9.1 min |

**Autopsia de `ts_r` — fallo raro: produce el entregable y luego lo borra.** El log del
agente muestra que escribió `script.R`, lo ejecutó ("Resultados guardados en
pronostico_r.csv") y leyó de vuelta el CSV con los 12 pronósticos mensuales correctos.
Al terminar, el workdir solo conserva los CSV de entrada: `script.R` y `pronostico_r.csv`
no están ahí ni en ninguna otra ruta del sistema. Las dos últimas llamadas a `bash`
devolvieron salida vacía, compatibles con un borrado. **No es fallo del arnés**: las
otras cinco tareas de la misma corrida conservan su script y su entregable. Zero no
guarda transcripción completa, así que el comando exacto no se pudo recuperar — queda
como incertidumbre. Para lotes desatendidos, borrar el entregable ya verificado es un
modo de fallo más grave que no resolver la tarea.

**Advertencia de método**: esta corrida usa `llama.cpp-master` (030ebb5, 2026-08-11),
no el b10155 del ancla y Qwopus — la arquitectura `nemotron_h` no existe en el build
viejo. La calidad es comparable; los minutos no del todo. Si el modelo avanza a
candidato serio, re-correr el ancla sobre este mismo build antes de comparar tiempos.

### Autopsia instrumentada de `ts_r` y varianza entre corridas (2026-08-11)

Para investigar el borrado se escribió `bench_zero_trace.py`: importa las mismas
`TASKS`, el mismo `agent_prompt` y el mismo checker que `bench_zero.py`, con los mismos
`--auto high --max-turns 25`. Solo cambia la observabilidad — `--output-format
stream-json` (el `text` muestra el resultado de `bash` pero no el comando),
`--init-session-id` para persistir la sesión, y guarda la salida completa en vez de los
últimos 1500 caracteres, que es exactamente por lo que se perdió la evidencia original.
Escribe a `*_zerotrace.json`: **el 5/6 oficial no se toca**.

**El borrado no se reprodujo.** En 7 corridas instrumentadas de `ts_r`, ninguna traza
contiene `rm`, `unlink` ni `file.remove`, y el entregable sobrevivió siempre. El
episodio original queda **sin explicación confirmada**.

**Lo que sí quedó medido es que `ts_r` es inestable en este modelo:**

| Corrida | Resultado | Tiempo |
|---|---|---|
| Suite oficial | FAIL — entregable generado y desaparecido | 103.1s |
| Aislada #1 | PASS | 78.6s |
| Aislada #2 (rep1) | FAIL — pronóstico con NaN | 279.9s |
| Aisladas #3-#6 (rep2-5) | PASS ×4 | 81.7-103.2s |
| Suite completa trazada | PASS | 127.0s |
| **Total** | **6 PASS / 2 FAIL (75%)** | |

El fallo de `rep1` sí tiene diagnóstico: el agente abandonó `script.R` y se puso a
improvisar one-liners con `Rscript -e`, hasta que el escapado del shell convirtió
`datos$valor` en `datos\$valor` y rompió el código. 14 comandos, 280s (3× lo normal) y
un CSV de NaN. No es desconocimiento de R: es un bucle de recuperación sin método.

**La suite completa trazada dio 6/6 · 9.8 min** (todas con su artefacto en disco). Es
decir: el mismo modelo, la misma máquina y la misma suite dieron **5/6 y 6/6 en dos
corridas distintas**. El resultado oficial sigue siendo el primero medido — no se
sustituye por el mejor —, pero la conclusión honesta es que **la diferencia entre 5/6 y
6/6 puede ser ruido**, y eso obliga a leer con cautela los veredictos de una sola
corrida de todo el experimento (ver lección 15).

### Candidato: Qwen3.8-27B UD-IQ2_XXS — el 2-bit que sí aguanta (2026-08-16)

Denso híbrido (16 × (3 × Gated DeltaNet → 1 × Gated Attention), 64 capas, 27B), recién
publicado. Se probó **a sabiendas de dos filtros en contra** (denso ~27B y lección 2:
"2-bit descartado con evidencia"), por orden directa y porque el quant de 9 GB cabe
entero en los 12 GB de la 3060 — el caso de uso exacto donde un denso no paga offload.

Calibración medida (dato en sí mismo, confirma la lección 1):

| Quant | Estrategia | Decode |
|---|---|---|
| UD-Q2_K_XL (10.7 GB) | auto-fit, capas a CPU | 9.9 tok/s |
| **UD-IQ2_XXS (9.0 GB)** | **entero en GPU** | **22.2 tok/s** |

En un denso, cada capa fuera de la GPU cuesta; se eligió el quant más agresivo a cambio
de 2.2× de velocidad. Config: build 030ebb5, `--n-gpu-layers 999`, ctx 32K, -t 32,
--no-mmap, thinking off verificado. VRAM: 11.8/12.3 GB (al límite: no abrir apps pesadas
durante corridas).

| Tarea | Qwen3.8 IQ2_XXS | gemma (mismo contexto) | Nemotron (mismo contexto) |
|---|---|---|---|
| excel_py | PASS 85.4s | PASS 78.6s | PASS 62.8s |
| excel_r | PASS 96.1s | PASS 57.4s | PASS 107.2s |
| dash_py | PASS 128.9s | PASS 75.0s | PASS 98.6s |
| dash_r | PASS 135.4s | PASS 71.4s | PASS 94.7s |
| ts_py | PASS 281.7s | PASS 77.2s | PASS 95.3s |
| ts_r | PASS 214.0s | PASS 140.5s | PASS 127.0s |
| **Total** | **6/6 · 15.7 min** | **6/6 · 8.3 min** | 6/6 · 9.8 min |

Estabilidad de `ts_r` (protocolo de repeticiones, mismo que gemma/Nemotron): suite + 5
aisladas = **5/6 PASS (83%)**, tiempos de pase 214–411 s. El fallo (rep3) quedó con traza
completa: es la **lección 9 en estado puro** — se atascó generando las 12 fechas futuras
en R (`as.Date + 1:12*30`, un `as.periods()` inexistente, sprintf malformado), espiral de
one-liners `Rscript -e` hasta agotar los 25 turnos. Terminó reportando honestamente "no
se ha ejecutado con éxito": ni fabricó ni borró nada.

**Lectura:** (1) **la lección 2 necesita matiz generacional** — el 2-bit dinámico de esta
familia ya no colapsa: 6/6 donde el Qwen3.6-35B 2-bit de julio hizo 2/6; (2) no destrona
al campeón en esta máquina: mismo 6/6 pero 1.9× el tiempo y ninguna tarea ganada;
(3) su nicho real es **GPUs de ~12 GB donde quepa entero** — en la laptop sin GPU un
denso de 27B seguiría siendo inviable (lección 1); (4) estabilidad ts_r 83%, entre
Nemotron (75%) y gemma (100%), con modo de fallo honesto.

### Candidato: empero-ai/Qwen3.8-9B Q4_K_M — Python-primero, R inconsistente (2026-08-16)

**El nombre engaña:** Qwen no publica ningún 9B en la familia 3.8 (solo 27B y 2.4T-A95B).
Este es un **Qwen3.5-9B destilado** por empero-ai con ~70k trazas del profesor
Qwen3.8-2.4T (ficha declara MMLU CoT 0.546→0.751 auto-reportado; GSM8K bajó 0.885→0.870;
sin benchmarks de código). Publicado el 15-08, sin validación externa. Pasó la autopsia
solo tras humo: la ficha dice que "cada respuesta abre con `<think>`", pero con
`enable_thinking:false` + `--reasoning off` el thinking **sí se apaga**, incluso en tareas
de código reales (`reasoning_content: None`, sin `<think>` en el contenido).

Config: Q4_K_M 5.8 GB, **entero en GPU con holgura** (7.6/12.3 GB), build 030ebb5,
ctx 32K, -t 32, --no-mmap. Velocidad: **53–56 tok/s**.

| Tarea | 9B empero | gemma (mismo contexto) |
|---|---|---|
| excel_py | **PASS 35.6s** | PASS 78.6s |
| excel_r | **FAIL** 124.1s | PASS 57.4s |
| dash_py | **PASS 27.2s** | PASS 75.0s |
| dash_r | PASS 61.8s | PASS 71.4s |
| ts_py | PASS 81.6s | PASS 77.2s |
| ts_r | **FAIL** 198.1s | PASS 140.5s |
| **Total** | **4/6 · 8.8 min** | 6/6 · 8.3 min |

Estabilidad `ts_r` (suite + 5 aisladas): **3/6 PASS (50%)** — 34.9s, 57.8s, 100.8s los
pases; los fallos por agotar turnos. Es el modelo más inconsistente de la ronda.

**Autopsias con traza completa:**
- `excel_r`: no es desconocimiento — sabía que era `writexl`. Se atascó en un bucle de
  entorno: intentó `install.packages('writexl')` (ya estaba instalado), lo reintentó con
  `type='source'`, probó `openxlsx`, listó paquetes… y además su `script.R` final tenía
  un **error lógico**: `data.frame(region=ventas$region, ventas_totales=ventas$ventas)`
  sin agrupar — copiaba las filas en vez de sumar por región. Aunque hubiera corrido,
  el checker lo habría tumbado.
- `ts_r` (rep4, falla en 62s): entró en bucle inspeccionando `forecast::auto.arima` en
  vez de escribir el pronóstico; se rindió temprano.

**Lectura:** (1) **los tiempos de Python son los más rápidos de toda la ronda** — excel_py
en 36s y dash_py en 27s, la mitad que el campeón; (2) **en R repite el patrón de los
≤9B de la fase 1** (fallan Excel R, inconsistentes en series): la destilación mejoró
razonamiento general, no el conocimiento de R; (3) no destrona a Gemma 4 E4B en la
categoría pequeña (E4B: 6/6 en laptop con 5 GB); (4) reserva sobre el linaje: es un
3.5-9B rebautizado, y el único benchmark propio no mide código.

### Candidato: Gemma 4 E2B Q4_K_M — el más rápido medido, pero se cae en R (2026-08-25)

Hermana pequeña de Gemma 4 E4B (campeón de la categoría ligera, 6/6 en laptop). Probada
por interés explícito en **velocidad**. Mismo quant Q4_K_M que E4B para comparación
directa. Nomenclatura: "E2B/E4B" son parámetros efectivos por token; los totales que
reporta llama.cpp son 4.65B vs 7.52B.

**Velocidad (llama-bench, pp512/tg128, todo en GPU, RTX 3060):**

| Modelo | Tamaño | Prefill | Decode |
|---|---|---|---|
| **Gemma 4 E2B Q4_K_M** | 2.88 GiB | **4,739 tok/s** | **139.6 tok/s** |
| Gemma 4 E4B Q4_K_M | 4.62 GiB | 2,798 tok/s | 78.1 tok/s |

**E2B es el modelo más rápido medido en todo el experimento** — 1.8× el decode de E4B,
el doble que gemma-4-26B-A4B (69.5) y 6× el 27B denso en 2-bit (22.2). VRAM en servicio:
3.7 GB. Coherente con la mitad de cómputo por token.

**Calidad: 3/6 en 2.7 min** (build 030ebb5, ctx 32K, -t 32, thinking off verificado):

| Tarea | E2B | E4B (referencia, laptop) |
|---|---|---|
| excel_py | PASS 25.8s | PASS |
| excel_r | **FAIL** 18.1s | PASS |
| dash_py | PASS 19.4s | PASS |
| dash_r | **FAIL** 61.1s | PASS |
| ts_py | PASS 24.7s | PASS |
| ts_r | **FAIL** 13.0s | PASS |
| **Total** | **3/6** | **6/6** |

**Patrón nítido: 3/3 en Python, 0/3 en R.** Estabilidad de `ts_r`: **0/6** (suite + 5
aisladas) — el único modelo del experimento que nunca la resuelve.

**Autopsias con traza:**
- `excel_r`: inventó un argumento inexistente, `write_xlsx(..., sheet="Resumen")`; writexl
  no tiene parámetro `sheet`. Ejecutó una sola vez y **se declaró exitoso** (`status:
  success`) sin verificar el entregable.
- `dash_r`: escribió un `script.py` **dentro de la tarea de R** — confundió el lenguaje.
- `ts_r`: `seq()` con argumento no numérico al construir las fechas (lección 9), sin
  capacidad de recuperarse.
- Integridad: `e2b-tsr-rep1` registró 5 errores de infraestructura (`fork/exec /bin/sh:
  not a directory`). Se verificó que la suite y las otras cuatro repeticiones tienen
  **cero**; el 3/6 y el 0/6 de `ts_r` no dependen de esa corrida.

**Lectura:** (1) E2B no es "E4B pero más chica": **cruza la frontera de capacidad**. Ahorra
1.9 GB y cuesta la mitad de la suite; (2) confirma dónde está el límite — E4B (7.52B
efectivos) hace 6/6, E2B (4.65B) hace 3/6; (3) su nicho legítimo es **Python acotado donde
la velocidad manda**: resuelve en 20-26 s por tarea, más rápido que cualquier otro modelo
medido; (4) **el marcador rápido engaña**: los 2.7 min incluyen rendirse en 13-18 s en las
tareas que falla. Terminar rápido no es terminar bien.

### Piso del experimento: Qwen3.5-0.8B Q4_K_M, y el matiz a la lección 3 (2026-08-25)

Modelo diminuto (752M params, **497 MiB** en Q4_K_M) probado para fijar el límite
inferior: dónde deja de tener sentido bajar de tamaño. Se midió en **dos
configuraciones**, siguiendo el precedente de la fase 2 (que ya reportaba "sin
razonamiento" y "con razonamiento" por separado).

**Velocidad: es el modelo más rápido medido en el experimento.**

| Modelo | Tamaño | Prefill | Decode |
|---|---|---|---|
| **Qwen3.5-0.8B Q4_K_M** | 497 MiB | **8,461 tok/s** | **277.5 tok/s** |
| Gemma 4 E2B Q4_K_M | 2.88 GiB | 4,739 | 139.6 |
| Gemma 4 E4B Q4_K_M | 4.62 GiB | 2,798 | 78.1 |
| gemma-4-26B-A4B (campeón) | 17 GB | — | 69.5 |

**Calidad: 0/6 en ambas configuraciones.** VRAM en servicio: 2.4 GB.

| Tarea | Thinking OFF (oficial) | Thinking ON |
|---|---|---|
| excel_py | FAIL — sin entregable | FAIL — **crea `reporte.xlsx`**, hoja mal nombrada |
| excel_r | FAIL — sin entregable | FAIL — sin entregable |
| dash_py | FAIL — sin entregable | FAIL — **crea `dashboard.html`** (1,374 bytes) |
| dash_r | FAIL — sin entregable | FAIL — sin entregable |
| ts_py | FAIL — sin entregable | FAIL — sin entregable |
| ts_r | FAIL — sin entregable | FAIL — sin entregable |
| **Total** | **0/6 · 8.0 min** | **0/6 · 8.8 min** |

**El marcador no cambia, pero el modo de fallo sí.** Sin pensamiento entrega **cero
archivos**; con pensamiento produce dos entregables reales que fallan por detalles de
especificación. Pasa de "no sabe hacerlo" a "casi lo hace". Humo comparativo con la
misma petición de Excel: sin pensar generó `from reportlab.lib.pagesizes A4` (error de
sintaxis, y reportlab es para PDF) y `os.makedirs` sin importar `os`; pensando usó
`openpyxl` y `Workbook`, las librerías correctas.

**Matiz a la lección 3** (hermano del matiz de la lección 16 al 2-bit): el razonamiento
**no es inviable en local por naturaleza, es inviable a velocidades bajas**. En la fase 2,
activarlo en el 35B a ~14 tok/s hizo la suite inutilizable (8 min y 6,000 tokens de puro
pensamiento sin producir código). Aquí el mismo presupuesto cuesta **~22 s**, y la suite
completa con thinking on solo tardó **10% más** (8.8 vs 8.0 min). Por encima de ~250 tok/s
pensar sale prácticamente gratis — y son los modelos diminutos, los que más lo necesitan,
los que pueden pagarlo. La regla operativa sigue siendo thinking off para los modelos de
trabajo (todos corren a 20-70 tok/s), pero el motivo es la velocidad, no el razonamiento
en sí.

**Lectura:** (1) **el piso está localizado**: 0.75B es demasiado poco para esta suite, con
o sin razonamiento; (2) la frontera de capacidad quedó acotada entre este 0/6, E2B (4.65B
efectivos) con 3/6 y E4B (7.52B) con 6/6; (3) un benchmark binario no premia la mejora
real que aporta el razonamiento aquí — vale registrarla cualitativamente.

### Candidato: Ornith-1.5-9B Q4_K_M — sangre nueva, 4/6, muy sólido en series de tiempo (2026-08-25)

Primer modelo de una **familia que el experimento no había tocado** (ornith-ai, licencia
MIT). Surgido del radar. Señales de adopción real: 1.14M descargas del GGUF. Por dentro
es arquitectura **Qwen3.5 densa**, 32 capas, 9.2B params — mismo peso en disco que E4B
(5.78 GB en Q4_K_M) pero denso, no edge.

**Velocidad (llama-bench, pp512/tg128, todo en GPU):**

| Modelo | Tamaño | Prefill | Decode |
|---|---|---|---|
| Gemma 4 E4B Q4_K_M | 4.62 GiB | 2,798 | **78.1** |
| **Ornith-1.5-9B Q4_K_M** | 5.37 GiB | 1,698 | 55.2 |

Más lento que E4B pese a ocupar más: el costo de ser denso de 9.2B contra 7.52B
efectivos. En la laptop sin GPU esa diferencia se agravaría.

**Calidad: 4/6 en 9.0 min** (build 030ebb5, ctx 32K, -t 32, thinking off verificado):

| Tarea | Ornith-1.5-9B | E4B (referencia, laptop) |
|---|---|---|
| excel_py | PASS 30.1s | PASS |
| excel_r | **FAIL** 96.3s | PASS |
| dash_py | PASS 82.5s | PASS |
| dash_r | PASS 125.4s | PASS |
| ts_py | PASS 55.5s | PASS |
| ts_r | **FAIL** 148.9s | PASS |
| **Total** | **4/6** | **6/6** |

**Estabilidad de `ts_r`: 5/6 (83%)** — falló en la suite pero **pasó las 5 repeticiones
aisladas** (90–195 s). Es de los mejores registros de esa tarea, por encima de Nemotron
(75%) y muy por encima del otro 9B destilado (50%). La lección 15 en acción: por una sola
corrida habríamos concluido que no sabe hacerla.

**Autopsia de `excel_r` — confundió nombre de hoja con nombre de archivo.** El script
dice literalmente: *"asi que se escribe como Resumen.xlsx y luego se copia a
reporte_r.xlsx"*; ejecutó `write_xlsx(resumen, "Resumen.xlsx")` + `file.copy(...)`. Ambos
archivos quedaron con la hoja por defecto `Sheet1`. Es **lección 13 en estado puro**: el
script corre limpio, R no protesta, el agente se declara exitoso y solo el checker del
entregable atrapa el fallo. El mismo modo de fallo que hundió a Qwopus en esta tarea.
En el humo previo ya había alucinado la librería (`library(writex)`,
`writex::write_tibble()`), pero de eso sí se recuperó: el bucle corrigió el error de
ejecución (lección 4) y no el de especificación (lección 13).

**Lectura:** (1) **no destrona a E4B**: 4/6 contra 6/6, más lento y 1.2 GB más grande;
(2) pero es un candidato serio en R de series de tiempo — 5/6 en `ts_r` con tiempos
estables; (3) su punto ciego es exactamente el mismo que el de Qwopus: entregar un xlsx
sin errores con la hoja mal nombrada; (4) al ser denso, su nicho es GPU con VRAM
suficiente, no la laptop de referencia.

### Síntesis de la ronda de agosto: 8 candidatos, ningún nuevo campeón, mucho conocimiento

Entre el 10 y el 25 de agosto de 2026 se evaluaron ocho candidatos en el perfil
`desktop-tr3990x-rtx3060-12gb-cuda`, todos con el mismo contrato (Zero agéntico, 25
turnos, thinking off verificado, código ejecutado y entregable validado) y —desde el
11-08— con el arnés instrumentado `bench_zero_trace.py`, que guarda la traza completa de
cada sesión. **Ninguno destronó a los campeones vigentes.** El valor de la ronda está en
lo que quedó aprendido.

#### Tabla comparativa (todos en la RTX 3060, build llama.cpp 030ebb5)

| Modelo | Tamaño | Arquitectura | Decode | Suite | `ts_r` |
|---|---|---|---|---|---|
| **gemma-4-26B-A4B** (campeón) | 17 GB | MoE 3.8B act. | 69.5 | **6/6 · 8.3 min** | 6/6 (100%) |
| Nemotron 3.5 Lightning 30B-A3B | 25.4 GB | MoE híbrido Mamba-2 | 47.7 | 6/6 · 9.8 min | 6/8 (75%) |
| Qwen3.8-27B UD-IQ2_XXS | 9.0 GB | denso híbrido, 2-bit | 22.2 | 6/6 · 15.7 min | 5/6 (83%) |
| **Gemma 4 E4B** (campeón ligero) | 5.0 GB | edge 7.52B ef. | 78.1 | 6/6 (laptop) | — |
| Ornith-1.5-9B | 5.8 GB | denso 9.2B (Qwen3.5) | 55.2 | 4/6 · 9.0 min | 5/6 (83%) |
| empero-ai/Qwen3.8-9B | 5.8 GB | Qwen3.5-9B destilado | 53–56 | 4/6 · 8.8 min | 3/6 (50%) |
| Gemma 4 E2B | 3.1 GB | edge 4.65B ef. | 139.6 | 3/6 · 2.7 min | 0/6 (0%) |
| Qwen3.5-0.8B | 0.5 GB | denso 0.75B | 277.5 | 0/6 · 8.0 min | 0/6 (0%) |
| Muse-Glimmer-30B | 17 GB | denso 30B multimodal | 6.2 | descartado sin medir | — |

#### Lo que quedó establecido

**1. La frontera de capacidad de los modelos pequeños está localizada.** Con tres puntos
medidos el mismo día y en las mismas condiciones: 0.75B → 0/6, 4.65B efectivos → 3/6,
7.52B efectivos → 6/6. El salto ocurre entre E2B y E4B. **E4B es el óptimo de la
categoría ligera** y ningún candidato de ≤6 GB se le acercó.

**2. Velocidad y capacidad son inversas, y casi proporcionales.** Cada duplicación de
parámetros efectivos cuesta aproximadamente la mitad de la velocidad: 277 → 139 → 78
tok/s para 0.75B → 4.65B → 7.52B. No hay comida gratis en esta escala.

**3. El marcador rápido engaña.** E2B "terminó la suite" en 2.7 minutos, pero eso incluye
rendirse en 13-18 segundos en las tareas que falla. Terminar rápido no es terminar bien;
el tiempo total solo es comparable entre modelos con el mismo marcador.

**4. Los modos de fallo importan más que el marcador**, sobre todo para lotes
desatendidos. Los observados, de más a menos peligroso:
- **Fabricar en silencio** (gemma en un demo fuera de suite: dashboard con datos de
  `np.random` presentado como real).
- **Destruir el entregable ya verificado** (Nemotron en `ts_r`: generó el pronóstico
  correcto, lo leyó, y desapareció; no reproducido en 7 intentos).
- **Declararse exitoso con el entregable mal** (Ornith y Qwopus en `excel_r`: xlsx sin
  error con la hoja mal nombrada — lección 13).
- **Atascarse sin método** (empero 9B: cinco `pip install` con los errores silenciados
  hasta reventar el contexto; Nemotron: one-liners de `Rscript -e` hasta romper el
  escapado).
- **Rendirse en voz alta** (Qwen3.8-27B: "no se ha ejecutado con éxito"). El más sano.

**5. Dos reglas del proyecto necesitaron matiz generacional, no derogación** (lecciones
16 y 17): el 2-bit moderno ya no colapsa la calidad, y el razonamiento no es inviable en
local sino inviable a velocidades bajas.

**6. Una sola corrida no decide** (lección 15). Nemotron dio 5/6 y 6/6 con la misma
configuración; Ornith falló `ts_r` en la suite y la pasó 5 de 5 veces aisladas. Sin el
protocolo de repeticiones, ambas conclusiones habrían sido erróneas.

#### Ejercicio fuera de suite: generación visual (n=1, artefactos solo locales)

Se probó un reto ambicioso en un solo prompt —galaxia espiral 3D procedural en HTML
autocontenido + 24 fotogramas exportados desde Python— con tres modelos. Ninguno alcanzó
el estándar de "impresionante": el 9B destilado no entregó nada, gemma entregó lo único
verificable de punta a punta (esquivó una dependencia ausente escribiendo BMP a mano) y
el 27B escribió un codificador PNG desde cero pero sus fotogramas salieron aplastados a
una línea, y aun así se declaró exitoso. **El hallazgo transferible: ninguno abrió sus
propios fotogramas.** La brecha para material visual no está en escribir la geometría
sino en verificar el resultado. Consecuencia práctica para futuros retos: pedir en el
prompt una verificación de *contenido* (que la imagen no esté vacía o plana), no solo de
existencia de archivos.

#### Estado tras la ronda

- **Lotes desatendidos**: sigue `gemma-4-26B-A4B` (6/6, el más rápido en igualdad de
  condiciones, y 6/6 en estabilidad de `ts_r`).
- **Categoría ligera**: sigue `Gemma 4 E4B` (6/6 con 5 GB), invicta tras ocho retadores.
- **Mejor en series de tiempo en R**: Qwopus sigue siendo el más rápido en esa tarea, con
  Ornith-1.5-9B como alternativa estable (83%).
- **Pendiente**: ningún candidato de esta ronda amerita revalidarse en la laptop de
  referencia, que es la que decide.

### Candidato: Ternary Bonsai 2 27B PTQ1_0 — el ternario ya corre, pero no retiene (2026-09-19)

Segunda visita de la familia Bonsai al experimento. La **v1 se descartó en fase 2** por
velocidad (2.3 tok/s en CPU de laptop: "la cuantización extrema ahorra memoria, no
cómputo"). PrismML publica ahora **Bonsai 2 27B**, ternario {−1,0,+1} a 1.72 bits/peso
sobre Qwen3.8-27B, y declara **98.2% de la inteligencia FP16** (84.78 promedio en 14
benchmarks **en modo thinking**), explícitamente por encima del **IQ2_XXS (72.59)** —
que es justo el build que nosotros medimos en **6/6**. Comparación ideal.

**Infraestructura**: requiere el fork [PrismML-Eng/llama.cpp](https://github.com/PrismML-Eng/llama.cpp)
(formatos PTQ1_0/PQ2_0 con rotación Hadamard; llama.cpp estándar puede cargar y devolver
basura). Compilado en `/mnt/data_4tb/IA-Local/llama.cpp-prism`, etiqueta validada
`prism-b10709-9a9394a`. Los builds del benchmark no se tocaron.

**Velocidad (llama-bench, mismo binario para ambos, todo en GPU):**

| Modelo | Tamaño | Prefill | Decode |
|---|---|---|---|
| **Bonsai 2 27B PTQ1_0** | 5.53 GiB | 276 | **27.5 tok/s** |
| Qwen3.8-27B UD-IQ2_XXS | 8.38 GiB | **458** | 21.5 tok/s |

**Calidad: 4/6 en 19.7 min** (thinking off verificado, ctx 32K, -t 32, 10.9 GB VRAM):

| Tarea | Bonsai 2 ternario | Qwen3.8-27B IQ2_XXS |
|---|---|---|
| excel_py | PASS 153.0s | PASS 85.4s |
| excel_r | **FAIL** 191.3s | PASS 96.1s |
| dash_py | PASS 160.2s | PASS 128.9s |
| dash_r | PASS 208.8s | PASS 135.4s |
| ts_py | PASS 140.6s | PASS 281.7s |
| ts_r | **FAIL** 325.6s | PASS 214.0s |
| **Total** | **4/6 · 19.7 min** | **6/6 · 15.7 min** |

Estabilidad `ts_r`: **3/6 (50%)** contra 5/6 (83%) del IQ2_XXS.

**Autopsias:**
- `excel_r`: **alucinó una función inexistente en español** — `ordenar(resumen, by = 1)`.
  Además arrastró `write_xlsx(..., sheet = "Resumen")`, argumento que writexl no tiene (el
  mismo error de E2B), ya visible en el humo previo. Inventar identificadores en el idioma
  del prompt es un síntoma característico de pérdida por cuantización.
- `ts_r`: agotó los 25 turnos habiendo ejecutado solo **4 comandos**. No es ignorancia:
  es lentitud de ciclo.

**Lectura:** (1) **el 98.2% no se sostiene en nuestra suite**: pierde 4/6 contra 6/6
justamente frente al IQ2_XXS que su ficha declara superar por 12 puntos; (2) **el tok/s
crudo no se tradujo en tiempo de reloj** — 28% más rápido generando y aun así **25% más
lento** en la suite, porque su prefill es 40% peor y el bucle agéntico procesa prompts
largos en cada turno. Dato transferible: *en modo agéntico manda el prefill, no el
decode*; (3) **el ternario ya es ejecutable** — contra los 2.3 tok/s de la v1 en CPU, aquí
da 27.5 en GPU con kernels propios: la lección 2 queda matizada también por este lado;
(4) **advertencia honesta**: su cifra se midió con razonamiento encendido y nuestro
contrato lo apaga. A 27.5 tok/s el thinking cae en la zona cara (lección 17), pero el
experimento está pendiente y sería la prueba justa de su afirmación.

## Fase 7 - Qwopus en el perfil de referencia: el candidato no destrona (2026-07-28)

Revalidación en `laptop-ref-ultra5-32gb-1dimm` (CPU puro, b10107, `-t 10`, ctx 32K,
thinking off, mmap por omisión) del candidato que dio 6/6 en 6.6 min en el desktop.
Mismo GGUF, byte a byte: `Qwopus3.6-35B-A3B-Coder-APEX-MTP-I-Compact.gguf` (17.33 GB).
Regla ETHOS: **la laptop decide**.

El build b10107, de antes del lanzamiento, carga la arquitectura MTP sin problema (15 s).

### Un turno

| Tarea | Qwopus | qwen3-coder:30b (campeón) | gemma-4-26B-A4B |
|---|---|---|---|
| excel_py | PASS 9s | PASS 11s | PASS 27s |
| excel_r | **FAIL** 9s | FAIL 9s | PASS 20s |
| dash_py | PASS 18s | PASS 28s | PASS 71s |
| dash_r | PASS 24s | PASS 24s | PASS 38s |
| ts_py | PASS 24s | PASS 22s | PASS 59s |
| ts_r | **FAIL** 28s | **PASS** 21s | FAIL 48s |
| **Total** | **4/6** | **5/6** | 5/6 |

Decode 11.9-13.7 tok/s (campeón: 9.6-13.8) — mismo régimen, más rápido tarea por tarea,
pero pierde `ts_r`, que el campeón sí resuelve. Ambos fallos son del modelo, no del
harness: `write_xlsx(..., sheet_name=)` (argumento inexistente en writexl) y
`year()` sin cargar lubridate — la lección 9, otra vez.

**Ojo con la primera medición**: en frío el servidor daba 5.9 tok/s (mmap paginando los
pesos). En caliente sube a ~14. Medir en frío habría descartado el modelo por error.

### Agéntico (Zero)

| Tarea | Qwopus laptop | gemma-4-26B-A4B | campeón 30B | Qwopus desktop |
|---|---|---|---|---|
| excel_py | PASS 9.7 min | PASS 11.2 min | PASS 14.2 min | PASS 47.6s |
| excel_r | **FAIL 7.6 min** | PASS 11.2 min | PASS 36.8 min | PASS 103.8s |
| dash_py | PASS 11.9 min | PASS 15.3 min | PASS 24.9 min | PASS 99.7s |
| dash_r | PASS 12.0 min | PASS 10.2 min | PASS 23.2 min | PASS 49.6s |
| ts_py | PASS 9.7 min | PASS 10.3 min | PASS 69.7 min | PASS 44.5s |
| ts_r | PASS 10.2 min | PASS 18.3 min | PASS 45.0 min | PASS 48.9s |
| **Total** | **5/6 · 61 min** | 6/6 · 76.5 min | 6/6 · 214 min | 6/6 · 6.6 min |

**El 6/6 del desktop no se reproduce en la laptop.** Qwopus es el más rápido de los tres
en la máquina de referencia (61 min contra 76.5 del campeón de lotes), pero pierde una
tarea que los otros dos resuelven. **La recomendación no cambia: gemma-4-26B-A4B sigue
siendo el campeón de lotes.**

### Hallazgos

1. **La ventaja en `ts_r` sí es del modelo, no de la GPU.** Era el hallazgo a validar:
   10.2 min contra 18.3 del campeón de lotes y 45.0 del interactivo — 1.8× y 4.4×. La
   dirección del desktop (4× sobre el campeón) sobrevive al cambio de máquina. En R para
   series de tiempo, Qwopus es el mejor modelo que ha pasado por este benchmark.
2. **El bucle agéntico rescató `ts_r` pero no `excel_r`,** y la diferencia explica el
   límite del modo agéntico: en `ts_r` R aborta con error y el agente lo lee y corrige;
   en `excel_r` el script **corre sin error** y produce un `.xlsx` con los datos correctos
   en una hoja llamada `Sheet1` en vez de `Resumen`. El agente se declara exitoso.
   Su "corrección" fue quitar el argumento que fallaba (`sheet_name=`) en vez de usar la
   forma correcta (`write_xlsx(list(Resumen = resumen), ...)`): **eliminó el requisito en
   lugar de cumplirlo.**
3. **Corolario para evaluar candidatos**: el bucle agéntico solo compensa lo que el
   intérprete reporta como error. Un modelo que falla la *especificación* sin fallar la
   *ejecución* no se corrige solo, y un harness que juzgue por código de salida —no por
   el entregable— lo daría por bueno. Aquí lo atrapó el checker, no el agente.
4. **Un turno predice mal el modo agéntico**: Qwopus fue 4/6 en un turno (peor que el
   campeón) y aun así el más rápido en agéntico. Pero también al revés: `ts_r` pasó de no
   compilar a ser su mejor tarea.

### Advertencia de método

Los tiempos del desktop y de la laptop **no son comparables entre sí** más allá del orden
de magnitud: distinto backend (CUDA vs CPU), distintos flags (`-t 32 --no-mmap` vs
`-t 10` + mmap) y distinta contención. Lo comparable es cada modelo contra los otros
**dentro de su propio perfil**, y eso es lo que hacen las dos tablas de arriba.

## Reproducir

```
python make_data.py
python bench.py <modelo>                              # Ollama
python bench.py <etiqueta> --backend llama --port N   # llama-server
python bench_cline.py <etiqueta> [tarea...]           # agentico via Cline CLI (servidor en 8080)
python bench_zero.py <etiqueta> [tarea...]            # agentico via Zero (servidor en 8080)
```
