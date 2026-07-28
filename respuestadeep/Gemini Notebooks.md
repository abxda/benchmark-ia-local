**Jackrong/Qwopus3.5-4B-Coder**

- **Nombre exacto del repositorio:** Jackrong/Qwopus3.5-4B-Coder.
- **Laboratorio:** Jackrong (Comunidad / Destilación).
- **Fecha:** Junio de 2026.
- **Arquitectura:** Densa híbrida (Gated DeltaNet + Gated Attention), con 4.6B de parámetros totales y 4.6B de parámetros activos.
- **Tamaño en Q4:** 2.78 GB (Q4_K_M).
- **Licencia:** Apache 2.0 / Fines de investigación y académica.
- **Resultados en benchmarks de código:** 89.4% en HumanEval (Pass@1), 83.2% en MBPP (Pass@1) y 61.2% en SWE-bench Verified, medidos por entidades independientes. Además, logró 82.0% de promedio en la suite benchlocal (incluyendo BugFind-15 con 71/100 y ToolCall-15 con 100/100), medido por la comunidad (Kyle Hessling/Jackrong).
- **Evidencia de desempeño en el lenguaje R:** Sí, análisis cualitativos de la comunidad en OpenClaw indican que reduce sustancialmente las alucinaciones de sintaxis en R y mantiene la estructura funcional gracias al entrenamiento "Trace Inversion".
- **GGUF y soporte en llama.cpp:** Sí, cuenta con distribuciones GGUF optimizadas (imatrix) y su soporte en llama.cpp y Ollama es nativo y maduro.
- **Razona por defecto y cómo se desactiva:** Sí razona por defecto (gracias al entrenamiento con "Trace Inversion"). Se desactiva configurando el parámetro `enable_thinking=False` en la inicialización de la plantilla, inyectando la bandera `--reasoning-budget 0` o especificando `thinking_budget_tokens: 0` en el JSON de configuración.

**Nanbeige/Nanbeige4.2-3B**

- **Nombre exacto del repositorio:** Nanbeige/Nanbeige4.2-3B.
- **Laboratorio:** Nanbeige LLM Lab.
- **Fecha:** Julio de 2026.
- **Arquitectura:** Densa (Looped Transformer), con 4B de parámetros totales y 3B de parámetros activos (no incrustados físicos) que se reutilizan secuencialmente.
- **Tamaño en Q4:** ~2.50 GB (Q4_K_M).
- **Licencia:** Apache 2.0.
- **Resultados en benchmarks de código:** 88.5% en HumanEval (Pass@1) medido de forma independiente, y 63.6% en SWE-bench Verified, 67.6% en MBPP y 72.5% en LiveCodeBench v6, medidos oficialmente por los creadores del modelo.
- **Evidencia de desempeño en el lenguaje R:** Sí, reportes cualitativos en OpenClaw demuestran que tiene una reducción sustancial de alucinaciones de sintaxis específicas de R.
- **GGUF y soporte en llama.cpp:** Sí tiene GGUF, pero su soporte en llama.cpp requiere de la inclusión dinámica de scripts (`trust_remote_code=True`) o de copiar manualmente los binarios resultantes en el backend (como se requiere en LM Studio).
- **Razona por defecto y cómo se desactiva:** Sí razona de forma predeterminada mediante un procesamiento lógico denso pero continuo. Por su diseño, no requiere desactivación ni directivas complejas de bloqueo (no usa delimitadores como `<think>`), ya que el razonamiento se integra ágilmente en la generación semántica.

**Qwen/Qwen3.5-4B**

- **Nombre exacto del repositorio:** Qwen/Qwen3.5-4B.
- **Laboratorio:** Alibaba Qwen Team.
- **Fecha:** Marzo de 2026.
- **Arquitectura:** Densa híbrida (Gated DeltaNet + Gated Attention), con 4.66B de parámetros totales y activos.
- **Tamaño en Q4:** ~2.70 GB a 3.4 GB (Q4_K_M).
- **Licencia:** Apache 2.0.
- **Resultados en benchmarks de código:** 87.2% en HumanEval (Pass@1), 82.5% en MBPP (Pass@1), 55.8% en LiveCodeBench v6 y 53.1% (o 38.8% dependiendo del tipo de scaffold) en SWE-bench Verified, medidos oficialmente.
- **Evidencia de desempeño en el lenguaje R:** sin dato.
- **GGUF y soporte en llama.cpp:** Sí cuenta con GGUF y tiene soporte nativo y maduro desde su lanzamiento en llama.cpp y Ollama.
- **Razona por defecto y cómo se desactiva:** No razona por defecto (el modo "thinking" viene desactivado por defecto en la serie Small de Qwen3.5). Si fuera encendido deliberadamente, se desactiva configurando `enable_thinking=False` o inyectando `--reasoning-budget 0`.

**google/gemma-4-e2b**

- **Nombre exacto del repositorio:** google/gemma-4-e2b.
- **Laboratorio:** Google DeepMind.
- **Fecha:** 2 de abril de 2026.
- **Arquitectura:** Densa con Per-Layer Embeddings (PLE), cuenta con 5.1B de parámetros totales (incluyendo embeddings) y 2.3B de parámetros activos (efectivos).
- **Tamaño en Q4:** ~4.20 GB.
- **Licencia:** Apache 2.0.
- **Resultados en benchmarks de código:** 44.0% en LiveCodeBench v6, 37.5% en AIME 2026 y 633 puntos en Codeforces ELO, medidos de forma oficial por Google.
- **Evidencia de desempeño en el lenguaje R:** sin dato.
- **GGUF y soporte en llama.cpp:** Sí existe en formato GGUF. Sin embargo, padece de un bug activo y severo en llama.cpp donde el grafo de computación omite la inyección residual del PLE, degradando drásticamente su precisión sintáctica e invalidándolo para generar código complejo.
- **Razona por defecto y cómo se desactiva:** Sí razona por defecto, gestionando esto mediante tokens de sistema específicos. Se desactiva omitiendo el token `<|think|>` en la cabecera del prompt o agregando el parámetro `--chat-template-kwargs '{"enable_thinking":false}'`.

**google/gemma-4-e4b**

- **Nombre exacto del repositorio:** google/gemma-4-e4b.
- **Laboratorio:** Google DeepMind.
- **Fecha:** 2 de abril de 2026.
- **Arquitectura:** Densa con Per-Layer Embeddings (PLE), cuenta con 8B de parámetros totales y 4.5B de parámetros activos (efectivos).
- **Tamaño en Q4:** ~5.90 GB.
- **Licencia:** Apache 2.0.
- **Resultados en benchmarks de código:** 52.0% en LiveCodeBench v6, 42.5% en AIME 2026, 940 puntos en Codeforces ELO y 14.0% en SWE-bench Verified, medidos de forma oficial por Google.
- **Evidencia de desempeño en el lenguaje R:** sin dato.
- **GGUF y soporte en llama.cpp:** Sí tiene GGUF. Al igual que la versión E2B, está afectado por el mismo fallo crítico de omisión de tensores PLE en llama.cpp que corrompe la precisión del código.
- **Razona por defecto y cómo se desactiva:** Sí razona por defecto. Se apaga omitiendo el token `<|think|>` en el prompt del sistema o corriendo el entorno con `--chat-template-kwargs '{"enable_thinking":false}'`.

**CRAAAAAAAAAA/Qwable3.5-9B** *(modelo adicional extra que entra en el límite de memoria)*

- **Nombre exacto del repositorio:** CRAAAAAAAAAA/Qwable3.5-9B.
- **Laboratorio:** Independiente / Comunidad (creado por Ok-Intention2610).
- **Fecha:** ~Junio de 2026 (publicado hace 1 mes).
- **Arquitectura:** Densa (afinada a partir de Qwen3.5-9B), con 9B de parámetros totales y activos.
- **Tamaño en Q4:** ~5.6 GB (requiere ~6 GB de VRAM para inferencia).
- **Licencia:** sin dato.
- **Resultados en benchmarks de código:** 90.2% en HumanEval (Pass@1), 84.4% en MBPP (Pass@1) y 53.3% en AIME (SFT), medidos y reportados por su propio desarrollador usando greedy T=0.
- **Evidencia de desempeño en el lenguaje R:** sin dato.
- **GGUF y soporte en llama.cpp:** Sí dispone de GGUF y funciona fluidamente en la familia de herramientas locales con soporte llama.cpp.
- **Razona por defecto y cómo se desactiva:** sin dato (el desarrollador solo indica que las métricas se obtuvieron con "thinking OFF", evidenciando que se puede desactivar, pero no especifica la directiva formal usada para este afinamiento concreto).

---

**Campos vacíos y fuentes necesarias para llenarlos:**

- **Evidencia de desempeño en el lenguaje R:** Quedó marcado como "sin dato" para los modelos `Qwen/Qwen3.5-4B`, `google/gemma-4-e2b`, `google/gemma-4-e4b` y `CRAAAAAAAAAA/Qwable3.5-9B`. Para completarlo, haría falta un reporte de evaluación sistemático centrado en R, como una publicación en el blog de Simon P. Couch o la ejecución directa del test *helperbench* evaluando específicamente a estos modelos en refactorización local.
- **Licencia:** Quedó "sin dato" para `CRAAAAAAAAAA/Qwable3.5-9B`. Para encontrarlo, sería necesario ingresar y revisar el portal oficial de Hugging Face en la URL exacta de este repositorio.
- **Mecanismo de desactivación de razonamiento:** Para `CRAAAAAAAAAA/Qwable3.5-9B`, faltan los comandos o directivas exactas. Se requeriría acceder al archivo *chat_template* dentro de los metadatos del repositorio original en Hugging Face o la documentación del creador para ver si heredó las mismas configuraciones bandera base de Qwen3.5.
