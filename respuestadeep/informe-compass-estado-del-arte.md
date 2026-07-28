# LLMs de código abierto para coding agéntico local en laptops institucionales (Intel Arrow Lake) — Estado del arte a julio de 2026

## TL;DR
- **El mejor conjunto para esta laptop es Qwen3-Coder-30B-A3B-Instruct (MoE 30.5B / 3.3B activos) a Q4_K_M (~18.7 GB) como agente principal, más Qwen2.5-Coder-1.5B para autocompletado**, ejecutados con **LM Studio o llama.cpp con backend Vulkan** y conectados a **Cline (con "compact prompt")** o **Continue.dev**. Es el único punto de equilibrio realista entre capacidad agéntica y velocidad en 32 GB de RAM sin GPU NVIDIA.
- **Expectativas de velocidad realistas: ~10–18 tokens/s** de decodificación en este iGPU Arc 130T / CPU con RAM en canal único; el cuello de botella es el ancho de banda de memoria. **Añadir un segundo módulo DDR5 (doble canal) es la mejora individual con mayor impacto**, pudiendo casi duplicar los tokens/s.
- **R es el punto débil**: los modelos locales van claramente por detrás de los de nube en R. Los modelos locales de generación anterior (Qwen 3 14B, GPT-OSS 20B, Mistral 24B) fallaban tareas agénticas de R casi por completo (~0% en helperbench, dic-2025), pero la nueva generación (Qwen 3.5 35B-A3B, Gemma 4) alcanza ~90% (abr-2026). Recomiendo Qwen3-Coder-30B para R con verificación humana obligatoria.

## Key Findings

1. **Qwen3-Coder-30B-A3B es el estándar de facto para coding local en 2026.** Es MoE (30.5B totales, 3.3B activos, 128 expertos con 8 activos), Apache-2.0, con contexto nativo de 262.144 tokens. Sobre SWE-bench Verified hay varias mediciones según el scaffold: la reproducción oficial de Nebius con OpenHands reporta **50.3% Pass@1**, el paper InCoder-32B lista **51.9**, y hay reportes comunitarios de hasta 59.2. En Q4_K_M ocupa ~18.7 GB, cabe holgadamente en 32 GB.
2. **Devstral Small 2 (24B, Mistral, Apache-2.0, 9 dic 2025) es la alternativa densa especializada en agentes**: según el anuncio oficial de Mistral, *"Devstral Small 2 scores 68.0% on SWE-bench Verified, and places firmly among models up to five times its size while being capable of running locally on consumer hardware"*; el hermano mayor Devstral 2 (123B) logra 72.2%. Contexto 256K, ~14 GB en Q4. Entrenado con All Hands AI específicamente para flujos agénticos multi-archivo.
3. **El stack Vulkan tiene bugs conocidos en Arrow Lake iGPU.** Hay issues abiertos en llama.cpp/Ollama en los que el backend Vulkan produce salida corrupta ("garbage/gibberish") en Arrow Lake (ARL) con modelos de 3B+. Esto obliga a validar cuidadosamente el runtime en el hardware exacto antes de estandarizar.
4. **La NPU Intel AI Boost (~13 TOPS) no es útil para el LLM principal.** Solo sirve para modelos pequeños (<3-4B) vía OpenVINO con INT4 simétrico y no supera a CPU/iGPU para chat interactivo. Un desarrollador que probó la NPU concluyó: *"Skip the NPU for LLMs unless you specifically need low-power background inference. The CPU (or even iGPU) will serve you better for interactive chat."*
5. **R va muy por detrás de Python en todos los modelos abiertos.** Según Zhao & Fard (arXiv 2410.07793), StarCoder2-7B logra **~19.65% Pass@1** y CodeLlama-7B **~20.50%** en HumanEval-R, frente a ~29% y ~26% en Python. Posit (creadores de RStudio/tidyverse) recomienda para R: *"For R coding tasks, we recommend using OpenAI's GPT-5 or o4-mini or Claude Sonnet 4… Claude Sonnet 4 remains a competitive option."* — todos modelos de nube.
6. **Las herramientas agénticas requieren modelos capaces.** Cline reporta que *"AMD's testing revealed that models smaller than Qwen3 Coder 30B consistently fail with Cline, producing broken outputs or refusing to execute commands properly"* (incluyendo gpt-oss-20b y deepseek-r1-qwen3-8b). Continue.dev es menos exigente y funciona bien con modelos más pequeños en modo chat+autocompletado.

## Details

### 1. Modelos de frontera locales (2025-2026)

**Qwen3-Coder-30B-A3B-Instruct** — El mejor todoterreno. MoE 30.5B/3.3B activos, 262K contexto nativo (1M con YaRN), Apache-2.0. SWE-bench Verified 50.3–51.9% según scaffold. El hermano mayor Qwen3-480B-A35B, según docs de Unsloth, *"achieves SOTA coding performance rivalling Claude Sonnet-4, GPT-4.1, and Kimi K2, with 61.8% on Aider Polyglot"*. Q4_K_M ~18.7 GB; Unsloth cita ~18 GB de memoria combinada para 6+ tok/s. Tool-calling con formato de función propio (arreglado en llama.cpp/Ollama/LM Studio), soportado nativamente por Cline/Qwen Code/Continue. **Modelo agéntico principal recomendado.**

**Devstral Small 2** — 24B densa, Apache-2.0, 68.0% SWE-bench Verified, contexto 256K, ~14 GB Q4_K_M. Especializado en agentes (leer código, editar múltiples archivos, ejecutar tests, iterar). Más ligero en disco que Qwen3-Coder y la mejor opción cuando se necesita un número agéntico medido y fiable. (La versión previa Devstral-Small-2507 daba 53.6%.)

**Qwen2.5-Coder** (0.5B a 32B, densos) — La familia de referencia previa. El 14B logra 83.5 HumanEval+, 27.0 SWE-bench Verified; Q4_K_M ~8.7 GB, Q8 ~14.7 GB, contexto 32K (128K con YaRN). El 32B (Q4_K_M ~20 GB) fue el primer modelo abierto que igualó a GPT-4o en código; lidera reparación multi-lenguaje (73.7 Aider code-repair, 65.9 McEval). El 1.5B (<1 GB) es la elección oficial de Continue.dev para autocompletado FIM.

**gpt-oss-20b** (OpenAI, MoE, MXFP4) — ~14 GB, 128K contexto, corre en 16 GB de RAM. Baseline sólida pero por detrás de Qwen3-30B en código multilingüe.

**GLM-4.x, DeepSeek-V3.2, Kimi K2, Qwen3-Coder-Next (80B)** — Modelos más capaces (DeepSeek-V3.2 lidera abiertos en Aider Polyglot con 0.745) pero fuera del alcance de 32 GB; requieren workstation/nube.

Otros a considerar para casos ligeros: **CodeGemma/Gemma**, **Granite Code (IBM)**, **StarCoder2** (fuerte en lenguajes de bajo recurso), **Phi-4** (14B, 128K, "el LLM local más accesible" según Hugging Face blog).

### 2. Soporte para R (crítico para la práctica estadística)

R es un lenguaje de bajo recurso para los LLMs. Datos duros (Zhao & Fard, arXiv 2410.07793, HumanEval-R): StarCoder2-7B ~19.65% Pass@1 y CodeLlama-7B ~20.50%, vs ~29% y ~26% en Python. El informe técnico de Qwen2.5-Coder ni siquiera incluye R en su tabla MultiPL-E (solo 8 lenguajes: Python, C++, Java, PHP, TS, C#, Bash, JS); su cobertura de R solo se infiere del agregado McEval (65.9). StarCoder2 destacó en lenguajes de bajo recurso y su corpus (Stack v2) incluyó 22 GB de R.

Posit evaluó modelos con su paquete `vitals` y el dataset `are`: recomienda GPT-5, o4-mini o Claude Sonnet 4 para R, y anota que *"Anecdotally, many R programmers seem to prefer Claude Sonnet to OpenAI's models."* Probaron modelos abiertos (gpt-oss-120b y 20b) y quedaron por debajo de los mejores de pago. Simon Couch (Posit) con su `helperbench` encontró que en dic-2025 los modelos locales (Qwen 3 14B, GPT-OSS 20B, Mistral 3.1 24B) puntuaban **~0%** en tareas agénticas de R, mientras que para abr-2026 Qwen 3.5 35B-A3B y Gemma 4 26B-A4B alcanzaban **~90%** (*"Gemma 4 and Qwen 3.5 got it right all but one time"*).

**Conclusión:** usar Qwen3-Coder-30B como mejor opción local para R hoy, pero con revisión humana obligatoria del código estadístico (la brecha Python→R es amplia y persistente). Si el hardware se amplía, evaluar los MoE más nuevos (Qwen 3.5 35B-A3B, Gemma 4), que representan el nuevo frontera local en R.

### 3. Capacidades agénticas y tool-calling

Qwen3-Coder tiene tool-calling de calidad con formato propio. En benchmarks agénticos (fuente: paper InCoder-32B, arXiv 2603.16790), Qwen3-Coder-30B logra Terminal-Bench 23.8, SWE-bench Verified 51.9, τ²-bench Retail 25.4. Devstral Small 2 llega a 68.0% SWE-bench. **El gap con la nube es real:** DeepSeek-v3.2 alcanza 73.1 SWE-bench, Claude Opus 4.6 ~82% Aider Polyglot, GPT-5 88% Aider. Los modelos locales de 30B ofrecen aproximadamente el 65-80% de la capacidad frontera en tareas acotadas y verificables, degradándose más rápido que los modelos de nube conforme crece el contexto acumulado.

### 4. Stack de ejecución local en Intel Arrow Lake (sin NVIDIA)

- **LM Studio** (opción principal recomendada): usa llama.cpp con backend Vulkan para GPU Intel, expone API OpenAI en `localhost:1234/v1`, muestra indicadores visuales de compatibilidad, instalación trivial en Windows 11. La guía AMD para Cline especifica subir el contexto de 4096 a 32768 y poner GPU Offload al máximo.
- **llama.cpp** (Vulkan o SYCL): máxima flexibilidad y ecosistema GGUF completo. En pruebas sobre Intel, llama.cpp fue ~2x más rápido que OpenVINO; un laptop Intel de 32 GB corre 7B a ~4 tok/s en CPU, y 1.5-3B a 20+ tok/s. **Advertencia crítica: bugs de salida corrupta con Vulkan en Arrow Lake** — validar antes de desplegar; usar backend CPU o SYCL si aparecen.
- **IPEX-LLM (Intel)**: fork de Ollama/llama.cpp con aceleración SYCL/oneAPI para GPU Intel; añadió soporte NPU para series 100H/200V/200H. Mejor optimización específica de Arc pero más frágil y menos "battle-tested" que las rutas estándar; en Windows conviene usarlo vía sus binarios/contenedores.
- **OpenVINO GenAI**: aprovecha NPU + iGPU + CPU. En 2026.2 soporta Qwen3.5/3.6 y modelos MoE como Qwen3.6-35B-A3B en AI PC. La NPU requiere modelos INT4 simétricos (`--sym --ratio 1.0 --group-size 128`) y es útil sobre todo para modelos <3-4B; no supera a CPU/iGPU en chat interactivo. Nota: en Core Ultra Serie 2, prompts >1024 tokens con modelos >7B pueden requerir >16 GB de RAM.
- **Ollama**: fácil de usar, pero su binario oficial no acelera GPU Intel de forma nativa; requiere el fork IPEX-LLM o builds con Vulkan (en desarrollo, con los bugs mencionados en Arrow Lake).

### 5. Herramientas agénticas conectadas a modelos locales

- **Cline / Roo Code** (VS Code): las más agénticas y exigentes. AMD probó >20 modelos y concluyó que solo Qwen3-Coder 30B y superiores funcionan de forma fiable; requiere activar **"compact prompt"** (*"designed specifically for local models at 10% the length"*, pierde MCP/Focus Chain) y subir num_ctx (16K-32K mínimo; el contexto por defecto es la causa #1 de fallos). Recomendación por RAM de AMD: 32 GB → Qwen3-Coder 30B (4-bit); 64 GB → 8-bit; 128 GB+ → GLM-4.5-Air.
- **Continue.dev**: chat + edit + autocompletado, menos agéntico, tolerante a modelos pequeños. Stack local validado oficialmente: `qwen2.5-coder:7b` (chat/edit) + `qwen2.5-coder:1.5b` (autocompletado FIM).
- **Aider**: par-programador por terminal con edición por diffs; su leaderboard Polyglot es referencia multi-lenguaje.
- **Tabby**: autocompletado autohospedado ligero (StarCoder2, Qwen2.5-Coder).
- **OpenHands**: framework agéntico usado con Devstral; más pesado, orientado a resolver issues de GitHub de forma autónoma.
- **Zed, Void, Qwen Code, Mistral Vibe CLI**: alternativas con endpoint local compatible OpenAI.

### 6. Rendimiento y expectativas realistas

En este hardware (Arc 130T con 7 núcleos Xe2 a 2.2 GHz; RAM DDR5-5600 en **canal único**), las velocidades son modestas y limitadas por ancho de banda de memoria:
- Modelos 7B Q4 en CPU/iGPU Intel: **~4-7 tok/s**.
- Qwen3-Coder-30B-A3B (MoE, solo 3.3B activos): al activar pocos parámetros es más rápido de lo que sugiere su tamaño total; en un Arc 140T (Framework, RAM más rápida) se reportan ~30 tok/s con LM Studio. En esta laptop con canal único, esperar bastante menos: **~10-18 tok/s** de decodificación (estimación conservadora; el prefill/procesamiento de prompt es más lento aún).
- El **canal único es el limitante clave**: el iGPU comparte la RAM del sistema y las iGPU están fuertemente limitadas por ancho de banda. Fórmula: BW (GB/s) = MT/s × canales × 8 / 1000; pasar de 1 a 2 canales prácticamente duplica el ancho de banda y, con ello, los tok/s de decodificación (limitados por memoria). El consenso de la industria (Corsair): *"Two sticks of RAM will significantly outperform a single stick of the same total capacity for LLM inference."* **Recomendación fuerte: instalar un segundo módulo DDR5-5600 idéntico para doble canal.**

### 7. Consideraciones de despliegue gubernamental

- **Privacidad**: la ejecución 100% local mantiene los microdatos y datos estadísticos sensibles en el equipo, sin enviarlos a ninguna nube (crítico para estadística oficial y secreto estadístico). Las licencias Apache-2.0 (Qwen3-Coder, Qwen2.5-Coder, Devstral Small 2) permiten uso institucional/comercial sin restricciones ni tarifas.
- **Funcionamiento sin conexión**: todos los runtimes recomendados operan completamente offline tras descargar los pesos una vez.
- **Estandarización**: LM Studio + un modelo GGUF fijo es fácil de replicar en muchas laptops idénticas. Congelar y documentar la versión exacta de runtime, driver gráfico y driver NPU para evitar regresiones y los bugs de Vulkan en Arrow Lake. Distribuir los GGUF vía un repositorio interno para evitar descargas desde internet en cada equipo.

## Recommendations

**Combinación A — Agente de código capaz (uso principal, Python y R):**
Qwen3-Coder-30B-A3B-Instruct Q4_K_M (~18.7 GB) + LM Studio (Vulkan) + Cline con "compact prompt" (o Continue.dev si Cline resulta inestable). Contexto 32K-64K. Para tareas multi-archivo acotadas y verificables. **Verificación humana obligatoria en código R estadístico.**

**Combinación B — Asistente ligero de autocompletado + chat (despliegue estándar en flota):**
Qwen2.5-Coder-7B-Instruct (chat/edit, Q4/Q5) + Qwen2.5-Coder-1.5B (autocompletado FIM) + Continue.dev. Rápido, bajo consumo, ideal como línea base uniforme en todas las laptops.

**Combinación C — Especialista agéntico alternativo:**
Devstral Small 2 24B Q4_K_M (~14 GB) + OpenHands o Cline. Cuando se priorice fiabilidad agéntica medida (68% SWE-bench Verified) sobre contexto/velocidad, o cuando se necesite un modelo más ligero en disco.

**Acciones inmediatas escalonadas:**
1. Instalar un segundo módulo DDR5-5600 para doble canal (mayor impacto por costo).
2. Piloto con LM Studio + Qwen3-Coder-30B en 2-3 laptops, midiendo tok/s reales y validando que Vulkan **no** produzca salida corrupta; si la hay, degradar a backend CPU o probar IPEX-LLM/SYCL.
3. Desplegar la Combinación B en la flota general y reservar la A/C para perfiles de ciencia de datos avanzados.
4. Evaluar los MoE nuevos (Qwen 3.5 35B-A3B, Gemma 4 26B-A4B) para R conforme haya soporte estable en OpenVINO/llama.cpp.

**Umbrales de decisión que cambian la recomendación:** si tok/s < 8 o Vulkan es inestable en el hardware exacto → degradar a modelos 7-14B densos en CPU (Combinación B). Si se añade doble canal y se superan ~15 tok/s con el 30B → estandarizar la Combinación A para perfiles técnicos. Si Posit/Simon Couch confirman un MoE local >85% en R que quepa en 32 GB → migrar el caso de uso de R a ese modelo.

## Caveats
- Los bugs de Vulkan en Arrow Lake iGPU son reales y pueden invalidar la aceleración por GPU; **validar en el hardware exacto (Arc 130T)** antes de estandarizar.
- Muchas cifras de tok/s provienen de hardware distinto (Apple Silicon, Arc dedicadas A770/B70, Arc 140T con RAM más rápida y doble canal); las estimaciones para Arc 130T con canal único son extrapolaciones conservadoras y deben medirse en piloto.
- No existe un Pass@1 limpio y publicado de R para Qwen2.5-Coder/Qwen3-Coder; la evaluación de R se apoya en fuentes indirectas (Zhao & Fard para 7B base, Posit/Simon Couch para tareas agénticas).
- Los scores de SWE-bench dependen fuertemente del scaffold (OpenHands vs mini-swe-agent vs custom); por eso las cifras de Qwen3-Coder-30B varían entre 18.8% (solo Bash) y 51.9% (con herramientas). Comparar siempre bajo el mismo harness.
- Nombres de modelos muy recientes (Qwen 3.5/3.6, Gemma 4, GLM-5, Qwen3-Coder-Next) aparecen mayormente en fuentes secundarias/agregadores; verificar disponibilidad, pesos y licencia en Hugging Face antes de desplegar.