# Brief de investigación: mejores modelos pequeños para programación local (Python y R)

> **Cómo usar este documento**
> Pégalo completo como prompt en Claude (modo investigación profunda) y en NotebookLM.
> Es autocontenido: incluye el hardware, los resultados empíricos previos y los criterios
> de evaluación, de modo que el agente de investigación no necesite contexto adicional.
> Fecha de corte de la búsqueda: **lanzamientos de los últimos 6 meses** (desde febrero 2026).

---

## 1. Contexto y objetivo

Estoy evaluando modelos de lenguaje **de pesos abiertos, ejecutables 100% localmente**,
para asistir en programación de **Python y R** aplicada a trabajo estadístico
(automatización de Excel, generación de dashboards, análisis de series de tiempo).
El equipo es una laptop institucional sin GPU dedicada. El objetivo es sustituir
licencias de asistentes comerciales por una alternativa local, sin costo recurrente y
sin que los datos salgan del equipo.

**Necesito identificar los mejores modelos PEQUEÑOS lanzados recientemente.**
"Pequeño" significa aquí: **cabe en ≤8 GB de RAM en cuantización Q4** (aproximadamente
≤8B parámetros densos, o MoE con ≤4B parámetros activos y ≤14B totales).

### Hardware objetivo (condiciona todo)

| Componente | Especificación | Implicación medida |
|---|---|---|
| CPU | Intel Core Ultra 5 225H (Arrow Lake-H, 14 núcleos) | Inferencia 100% CPU |
| RAM | 32 GB DDR5-5600 **en canal único (1 módulo)** | Ancho de banda es EL cuello de botella |
| GPU | iGPU Intel Arc (memoria compartida, tope ~16 GB) | Solo acelera prefill, no decodificación |
| SO | Windows 11 | Restringe algunos runtimes (vLLM no aplica) |

---

## 2. Lo que YA sé (no lo repitas, úsalo como línea base)

Ejecuté un benchmark propio con 6 tareas reales (Excel, dashboards y series de tiempo,
en Python y en R), ejecutando el código generado y validando los resultados.
Modo "un turno" = una sola respuesta. Modo "agéntico" = el modelo escribe, ejecuta,
lee errores y se auto-corrige dentro de un harness (Cline, Zero).

| Modelo | RAM (Q4) | Un turno | Agéntico | Velocidad |
|---|---|---|---|---|
| Gemma 4 E4B (4.5B efectivos) | 5 GB | **4/6** | **6/6** | 9–11 tok/s |
| Qwen3.5 4B | 2.7 GB | 2/6 | 5/6 | 11–12 tok/s |
| Qwen2.5-Coder 7B | 6 GB | 2/6 | no probado | 7.4 tok/s |
| Qwen3 8B | 7 GB | 2/6 | no probado | 6.6 tok/s |
| *(referencia grande)* Qwen3-Coder 30B-A3B | 18 GB | 5/6 | 6/6 | 15.5 tok/s |

**Hallazgos empíricos que definen los criterios de búsqueda:**

1. **Los MoE con pocos parámetros activos superan a los densos** de tamaño similar en
   velocidad, porque el cuello de botella es el ancho de banda de memoria, no el cómputo.
2. **Los densos de 7–8B no aportan nada**: más lentos que los de 4B y sin mejor calidad.
3. **La cuantización ≤2 bits destruye la calidad** (un 35B en 2-bit rindió como un 7B).
   Solo interesa Q4 o superior.
4. **El razonamiento ("thinking") es inviable localmente** a ~10 tok/s: consume miles de
   tokens antes de producir código. Solo sirven modelos no-pensantes o con el
   pensamiento desactivable de verdad.
5. **R es el punto débil universal** de todos los modelos; es el diferenciador clave.
6. **El modo agéntico compensa el tamaño**: modelos pequeños que iteran sobre errores
   reales alcanzan la calidad de modelos grandes de un solo turno.

**Campeón pequeño actual a vencer: Gemma 4 E4B** (4/6 un turno, 6/6 agéntico, 5 GB).

---

## 3. Preguntas de investigación (en orden de importancia)

1. **¿Qué modelos de pesos abiertos ≤8B (o MoE ≤4B activos) se lanzaron en los últimos
   6 meses y superan a Gemma 4 E4B en programación?** Para cada uno: nombre exacto del
   repositorio, laboratorio, fecha de lanzamiento, arquitectura (denso o MoE, totales y
   activos), licencia y tamaño en Q4 (GB).
2. **¿Cuáles tienen evidencia de desempeño en benchmarks de código?** Especificar la
   métrica y el valor: HumanEval, MBPP, LiveCodeBench, Aider Polyglot, SWE-bench Verified,
   EvalPlus. Indicar si la evaluación es del propio laboratorio o independiente
   (las independientes valen mucho más).
3. **¿Existe evidencia específica de desempeño en R?** (no solo Python). Buscar
   evaluaciones de Posit, el helperbench de Simon Couch, o cualquier benchmark
   multilenguaje que desglose R. Este es el diferenciador más valioso y el más escaso.
4. **¿Cuáles están entrenados o afinados para uso agéntico** (uso de herramientas,
   iteración sobre errores, edición de archivos)? Buscar menciones de RL agéntico,
   entrenamiento con tool-use, o SWE-bench como métrica principal del anuncio.
5. **¿Cuáles tienen GGUF disponible y soporte en llama.cpp mainline / Ollama?**
   ¿Desde cuándo? (Los formatos que exigen forks o esperan semanas al soporte quedan
   descartados.) Indicar si Unsloth, bartowski o el propio laboratorio publicaron GGUF.
6. **¿Cuáles son pensantes por defecto y cómo se desactiva el razonamiento?**
   (parámetro exacto: `enable_thinking`, `/no_think`, flag del servidor, etc.)
7. **¿Qué reportes de usuarios existen sobre velocidad (tok/s) en CPU o iGPU de laptop?**
   Los benchmarks en GPUs dedicadas (A100, RTX 4090) NO son transferibles a este equipo.
   Priorizar reportes de r/LocalLLaMA, foros de llama.cpp, y usuarios con hardware Intel/AMD.

---

## 4. Criterios de inclusión y exclusión

**Incluir un modelo si cumple TODO:**
- Pesos abiertos, licencia que permita uso institucional (Apache 2.0, MIT o similar;
  señalar explícitamente si la licencia tiene restricciones de uso).
- Cabe en ≤8 GB de RAM en Q4 (o ≤6 GB idealmente).
- Lanzado o actualizado en los últimos 6 meses.
- Orientado a código o con desempeño demostrado en código.

**Excluir explícitamente:**
- Modelos solo accesibles por API (sin pesos descargables).
- Modelos que solo rinden con razonamiento extendido activado.
- Cuantizaciones de 1–2 bits presentadas como "modelos pequeños" (ya descartadas
  empíricamente: la calidad colapsa).
- Modelos que requieren runtimes exóticos, forks de llama.cpp o hardware específico.
- Modelos lanzados hace más de un año, aunque sigan siendo populares.
- Benchmarks reportados únicamente por el laboratorio que creó el modelo, sin
  verificación independiente — inclúyelos pero **etiquétalos como no verificados**.

---

## 5. Formato de respuesta solicitado

### 5.1 Tabla comparativa (obligatoria)

| Modelo (repo exacto) | Lab | Fecha | Arquitectura | Q4 (GB) | Licencia | Benchmark de código (métrica y fuente) | ¿Evidencia en R? | ¿GGUF/llama.cpp? | ¿Pensante? |
|---|---|---|---|---|---|---|---|---|---|

### 5.2 Ficha breve por candidato (máximo 5 candidatos, los mejores)

Para cada uno, en 150 palabras máximo:
- Qué lo hace destacar frente a Gemma 4 E4B.
- Su debilidad conocida o riesgo.
- Evidencia concreta con enlace a la fuente.

### 5.3 Recomendación final

- **Los 2 modelos que más vale la pena descargar y probar**, en orden, con la razón
  de una línea para cada uno.
- Enlace directo al repositorio GGUF recomendado (Unsloth o bartowski preferentemente)
  y el nombre exacto del archivo Q4 sugerido.
- Cualquier configuración especial requerida (plantilla de chat, flags, desactivación
  del razonamiento).

### 5.4 Señales de alerta

Menciona explícitamente si detectas: benchmarks inflados o no reproducibles,
contaminación de datos de entrenamiento, licencias restrictivas, o quejas recurrentes
de usuarios sobre calidad real vs. la anunciada.

---

## 6. Fuentes sugeridas (ordenadas por señal/ruido)

1. **Hugging Face**: modelos en tendencia con filtro GGUF; cuentas de Unsloth,
   bartowski, ggml-org, lmstudio-community.
2. **r/LocalLLaMA**: reportes reales de tok/s en hardware de laptop y quejas de calidad.
3. **Blog de Posit y trabajo de Simon Couch (helperbench)**: la única fuente seria de
   evaluación de LLMs **en R**.
4. **Aider Polyglot leaderboard, EvalPlus, LiveCodeBench, SWE-bench Verified**:
   comparaciones bajo el mismo andamiaje.
5. **Changelog y releases de llama.cpp / biblioteca de modelos de Ollama**:
   confirman soporte real de la arquitectura.
6. **Anuncios oficiales de los laboratorios** (Google/Gemma, Alibaba/Qwen, Meta/Llama,
   Mistral, Microsoft/Phi, IBM/Granite, DeepSeek, Kwaipilot, ServiceNow/StarCoder,
   AllenAI/OLMo) — útiles para fechas y especificaciones, escépticos para calidad.

---

## 7. Nota para NotebookLM

Si estás procesando este documento en NotebookLM junto con otras fuentes cargadas
(artículos, tarjetas de modelo, hilos de foros):

- Prioriza **contrastar las afirmaciones de las fuentes cargadas** contra los criterios
  de la sección 4, en lugar de resumirlas.
- Señala **contradicciones entre fuentes** (por ejemplo, un laboratorio que reporta 70%
  en un benchmark donde una evaluación independiente reporta 45%).
- Genera la tabla de la sección 5.1 usando **solo** información presente en las fuentes;
  marca como "sin dato" lo que no aparezca, en lugar de inferirlo.
- Indica al final **qué preguntas de la sección 3 quedaron sin responder** con el
  material disponible, para saber qué buscar después.
