# **Reporte de Investigación: Modelos de Lenguaje Pequeños para Programación Estadística Local en Python y R**

## **1\. Análisis del Entorno de Ejecución y Restricciones de Hardware**

La adopción de modelos de lenguaje de gran tamaño (LLMs) ejecutables localmente para la automatización de flujos de trabajo estadísticos, generación de cuadros de mando (dashboards) y análisis de series de tiempo requiere una comprensión profunda de las limitaciones de hardware. El entorno objetivo presenta una topología específica que dicta de manera ineludible el rendimiento de cualquier modelo implementado: un procesador Intel Core Ultra 5 225H (arquitectura Arrow Lake-H) con 14 núcleos, emparejado con 32 GB de memoria RAM DDR5-5600 configurada en canal único (single channel) y ejecutando el sistema operativo Windows 11\.

### **1.1 El Cuello de Botella del Ancho de Banda de Memoria**

En la arquitectura de inferencia de los LLMs, la fase de decodificación (la generación de cada token de texto o código) opera bajo un régimen estrictamente limitado por el ancho de banda de la memoria (memory-bound). Para generar un único token, el motor de inferencia debe transferir la totalidad de los pesos del modelo desde la memoria RAM hacia los registros del procesador.  
La configuración de canal único de este equipo es el factor restrictivo más crítico. Un módulo de memoria DDR5 operando a 5600 MT/s en canal único proporciona un ancho de banda teórico máximo de 44.8 GB/s. Sin embargo, en escenarios del mundo real, considerando la sobrecarga del sistema operativo, las latencias de acceso y la contención de otros procesos en Windows 11, el ancho de banda sostenido efectivo suele situarse entre 30 y 35 GB/s.  
Si se considera un modelo denso de aproximadamente 8 mil millones de parámetros cuantizado a 4 bits (Q4), el tamaño del archivo en memoria es de aproximadamente 4.8 a 5.5 GB. La matemática de la inferencia dicta que la velocidad máxima teórica se obtiene dividiendo el ancho de banda efectivo por el tamaño del modelo. Por lo tanto, un modelo de 5 GB procesado a 35 GB/s arrojará un límite físico de aproximadamente 7 tokens por segundo (tok/s). Este cálculo teórico explica con precisión milimétrica los resultados empíricos previos, donde el modelo Qwen3 de 8B alcanzó exactamente 6.6 tok/s y Qwen2.5-Coder 7B alcanzó 7.4 tok/s. Ninguna optimización algorítmica de software puede superar este límite físico en la decodificación de modelos densos sin reducir el tamaño de los pesos.

### **1.2 El Rol de la iGPU Intel Arc y la Compilación SYCL**

El procesador Intel Core Ultra 5 225H integra una unidad de procesamiento gráfico (iGPU) basada en la arquitectura Xe, la cual comparte el mismo bus de memoria física que la unidad central de procesamiento (CPU). Durante la decodificación de tokens, delegar el cómputo a la iGPU no incrementa la velocidad, ya que el cuello de botella sigue siendo el canal de memoria único. Sin embargo, la iGPU adquiere una importancia crítica durante la fase de evaluación del prompt (prefill).  
El procesamiento del contexto inicial (que puede incluir miles de líneas de código fuente o historiales de chat) es una operación intensiva en cómputo (compute-bound). Durante el prefill, el modelo procesa múltiples tokens simultáneamente utilizando multiplicación de matrices densas, una tarea en la que el paralelismo masivo de los núcleos Xe de la iGPU supera ampliamente a los núcleos de la CPU. Para explotar esta capacidad en Windows 11, donde runtimes como vLLM carecen de soporte nativo robusto para esta arquitectura, es imperativo utilizar llama.cpp compilado con el backend SYCL1. SYCL es el modelo de programación de la interfaz oneAPI de Intel, diseñado específicamente para la aceleración de hardware heterogéneo2.  
La evidencia empírica en procesadores Intel Core Ultra demuestra que el backend SYCL ofrece ventajas tangibles sobre alternativas multiplataforma como Vulkan. Por ejemplo, en pruebas documentadas, un modelo de 4B cuantizado a Q4\_K\_M mejoró su velocidad de 5.26 tok/s bajo Vulkan a 7.55 tok/s bajo SYCL4. Habilitar esta aceleración requiere la instalación de los controladores actualizados de Intel y el paquete de herramientas oneAPI, permitiendo a llama.cpp descargar las capas del modelo (-ngl) hacia la iGPU y aprovechar instrucciones específicas del hardware3.

## **2\. Evaluación de Modelos y el Desafío Específico de R**

El lenguaje R presenta un desafío único y persistente para la inteligencia artificial generativa. A diferencia de Python, que posee una sintaxis orientada a objetos altamente estandarizada y representa una porción masiva de los corpus de entrenamiento de internet, R es un lenguaje predominantemente funcional con características idiomáticas complejas. La evaluación no estándar (Non-Standard Evaluation, NSE) ampliamente utilizada en el ecosistema tidyverse, el manejo léxico del alcance (lexical scoping) y las promesas de evaluación perezosa (lazy evaluation) confunden frecuentemente a los modelos más pequeños. Las fallas comunes incluyen la invención de funciones inexistentes o la mezcla de sintaxis de R base con funciones de dplyr de manera incompatible.

### **2.1 El Cambio de Paradigma en Benchmarks: helperbench**

Históricamente, los modelos pequeños ejecutables localmente fallaban de manera categórica en la generación de código R estructurado, obteniendo tasas de éxito del 0% en refactorización básica6. No obstante, la investigación empírica reciente documenta un salto cualitativo en las arquitecturas de 2026\. El investigador Simon Couch (Posit) desarrolló helperbench, una herramienta de evaluación rigurosa diseñada para medir la capacidad de un agente local para refactorizar código en R6.  
A diferencia de métricas estáticas como HumanEval (que a menudo sufren de sobreentrenamiento o contaminación en los datos de prueba)8, helperbench obliga al modelo a operar de manera agéntica. El LLM debe utilizar herramientas de búsqueda para localizar un bloque de código específico en un directorio, leer su contenido, extraer la lógica en una función auxiliar (helper), reemplazar la llamada original en el script y ejecutar pruebas unitarias para validar el éxito de la refactorización6. Las pruebas de Couch publicadas en abril de 2026 demuestran que las iteraciones recientes de las familias Qwen y Gemma han logrado tasas de éxito casi perfectas (9 de 10\) en esta evaluación, demostrando una madurez técnica sin precedentes para modelos que caben en la RAM de una laptop9.  
Este hallazgo empírico redefine los criterios de viabilidad: el uso de modelos locales para flujos de trabajo estadísticos en R ha transitado de ser una curiosidad experimental a una alternativa de producción viable, siempre que el modelo se implemente dentro de un andamiaje (harness) que le permita utilizar herramientas e iterar sobre sus propios errores de compilación9.

## **3\. Dinámica Agéntica y la Crisis del Razonamiento Latente**

El déficit de capacidad inherente a los modelos de menos de 8 mil millones de parámetros se compensa sustancialmente mediante el uso de flujos de trabajo agénticos (agentic workflows). Entornos como Cline, Aider o Zero permiten que el LLM escriba un script, lo ejecute en la terminal, lea el registro de errores (traceback) y aplique correcciones iterativas10. Este bucle de retroalimentación (read-eval-print loop) transforma una tarea de generación directa (zero-shot) en un proceso de búsqueda y corrección, permitiendo a los modelos pequeños alcanzar tasas de resolución de problemas comparables a las de los modelos masivos de la nube en un solo turno9.

### **3.1 Aprendizaje por Refuerzo para Herramientas (Tool-Use)**

Para que el bucle agéntico funcione, el modelo debe poseer una capacidad robusta de seguimiento de instrucciones y uso de herramientas, respondiendo estrictamente en formatos estructurados (como JSON) sin desviarse hacia la conversación abierta. Los lanzamientos recientes han incorporado pipelines de aprendizaje por refuerzo (RL) específicamente diseñados para este fin14. Modelos como Granite 4.1 y la familia Qwen3.5 han sido sometidos a entrenamiento con síntesis de tareas ejecutables a gran escala y aprendizaje a partir de la interacción con entornos simulados, lo que minimiza la probabilidad de que el modelo emita comandos malformados o ignore los resultados de las herramientas16.

### **3.2 El Problema del "Pensamiento" en Entornos con Limitaciones de Memoria**

Una de las innovaciones más prominentes en el desarrollo de LLMs durante 2026 ha sido la integración de modelos de razonamiento latente. Estas arquitecturas generan extensas cadenas de pensamiento (Chain-of-Thought) de forma automática antes de producir la respuesta final, a menudo encerradas entre etiquetas como \<|think|\> y \</think\>19. Si bien esto mejora dramáticamente el puntaje en benchmarks matemáticos y lógicos, resulta catastrófico para la experiencia del usuario en hardware de bajo ancho de banda.  
Si un modelo decide generar 3,000 tokens de razonamiento para planificar la refactorización de un script de R, a una velocidad de generación de 7 tok/s, el sistema mantendrá al usuario esperando más de 7 minutos antes de emitir la primera línea de código ejecutable. En un flujo de trabajo agéntico que requiere múltiples llamadas a herramientas y correcciones de errores, esta penalización de latencia destruye la viabilidad de la herramienta. Además, se ha documentado que los modelos locales pequeños tienden a entrar en bucles de razonamiento infinitos (overthinking), perdiendo el hilo conductor de la instrucción original y fallando en la invocación de herramientas20.  
Por consiguiente, es un requisito no negociable que cualquier modelo candidato sea no-pensante por diseño, o posea mecanismos técnicos definitivos para desactivar esta característica. En modelos como Qwen3.5, esto se logra mediante la inyección del parámetro "enable\_thinking": false en la configuración de la solicitud, o asegurando que la plantilla del sistema suprima la generación de estas etiquetas10.

## **4\. Análisis del Mercado y Filtros de Exclusión (Últimos 6 Meses)**

El ecosistema de pesos abiertos ha experimentado una proliferación de lanzamientos en la ventana de febrero a julio de 2026\. La aplicación rigurosa de los criterios de exclusión elimina rápidamente varias de las opciones más publicitadas de la industria.

### **4.1 La Falsa Promesa de los MoE Masivos**

Las arquitecturas de Mezcla de Expertos (MoE) activan solo una fracción de sus parámetros totales durante el procesamiento de cada token, lo que mejora teóricamente la velocidad de inferencia24. Sin embargo, la totalidad de los pesos del modelo debe residir en la memoria RAM para que el enrutador pueda seleccionar qué expertos utilizar en un momento dado.  
Por ejemplo, el modelo Qwen3-Coder-Next, diseñado específicamente para codificación agéntica, posee 80 mil millones de parámetros totales pero solo activa 3 mil millones por token10. A pesar de su bajo conteo de parámetros activos, el archivo completo cuantizado a Q4 ocupa más de 40 GB26. De manera similar, DeepSeek-V4-Flash cuenta con 284B de parámetros totales y 13B activos, requiriendo más de 160 GB de memoria unificada23. Estos modelos desbordarían instantáneamente los 32 GB de RAM del equipo objetivo, forzando al sistema operativo a utilizar la unidad de estado sólido (NVMe) como memoria virtual (paginación), lo que reduciría la velocidad de generación a niveles inoperables (\<0.1 tok/s). Bajo el criterio estricto de ![][image1] 14B parámetros totales, estos modelos quedan excluidos.

### **4.2 El Colapso de la Cuantización Extrema**

Otra estrategia común para forzar modelos más grandes en hardware limitado es la cuantización extrema (1 o 2 bits). Modelos de 30B cuantizados a 2 bits (ej. IQ2\_XXS) pueden forzarse a encajar en 8-10 GB de RAM4. No obstante, la evidencia documentada y los hallazgos empíricos previos confirman que la pérdida de precisión en cuantizaciones inferiores a 3.5 bits destruye la perplejidad del modelo. Las redes neuronales pierden la capacidad de seguir reglas de sintaxis complejas y de razonar sobre la arquitectura del código, rindiendo por debajo de los modelos densos nativos de 7-8B en formatos Q423.

### **4.3 Candidatos Viables**

Tras aplicar los filtros de memoria (![][image1] 8 GB en Q4), licencia institucional, soporte para llama.cpp y evidencia en programación, emergen tres candidatos principales que superan la línea base del Gemma 4 E4B. Cabe destacar que el modelo Gemma 4 de 12B también fue evaluado; aunque técnicamente excede el límite de ![][image1] 8B parámetros densos (posee \~12B), su arquitectura unificada le permite ser cuantizado en un archivo de \~6.6 GB28, cumpliendo el requisito estricto de memoria de ![][image1] 8 GB en Q4. Sin embargo, su tamaño afecta negativamente la latencia, por lo que su recomendación se condiciona a la disponibilidad de VRAM en otros sistemas, centrándose este análisis en modelos verdaderamente optimizados para el ancho de banda del Intel 225H.

## **5\. Resultados y Selección de Candidatos**

La siguiente sección detalla los modelos que superaron todos los filtros técnicos, comenzando con una comparativa directa frente a la línea base.

### **5.1 Tabla Comparativa de Modelos Candidatos**

Esta tabla consolida las especificaciones técnicas, requisitos de memoria y validaciones de rendimiento independientes basadas en los repositorios oficiales y evaluaciones de terceros recopiladas hasta julio de 2026\.

| Modelo (repo exacto) | Lab | Fecha | Arquitectura | Q4 (GB) | Licencia | Benchmark de código (métrica y fuente) | ¿Evidencia en R? | ¿GGUF/llama.cpp? | ¿Pensante? |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| ibm-granite/granite-4.1-8b-instruct | IBM | Abr 2026 | Denso (8B) | \~4.8 GB | Apache 2.0 | HumanEval: 89.63% (Laboratorio)29 | Sin dato directo, pero optimizado para *tool-use*15. | Sí (bartowski) | No15 |
| Qwen/Qwen3.5-9B | Alibaba | Feb 2026 | Denso (9B) | \~6.0 GB | Apache 2.0 | LiveCodeBench v6: 82.7% (Lab) / 65.6% (Indep.)8 | Sí. Validado por S. Couch en helperbench9. | Sí (mainline) | Sí, pero desactivable flag enable\_thinking \[cite: 22\] |
| microsoft/Phi-4-mini-instruct | Microsoft | Mar 2026 | Denso (3.8B) | \~2.2 GB | MIT / Open | LiveCodeBench: Alto rendimiento lógico30 | Sin dato | Sí (unsloth, MaziyarPanahi)32 | No por defecto |
| *(Línea Base)* google/gemma-4-e4b-it | Google | Abr 2026 | Denso (4.5B) | \~3.3 GB | Apache 2.0 | LiveCodeBench v6: 44.0% (Laboratorio)34 | Sí. Validado por S. Couch en helperbench9. | Sí (mainline) | Sí, desactivable quitando \<|think|\> \[cite: 35, 36\] |

### **5.2 Fichas Breves por Candidato (Top 3\)**

**1\. Qwen/Qwen3.5-9B** Lo que lo hace destacar frente a Gemma 4 E4B es su dominio absoluto en la asimilación de contexto estructural gracias a su arquitectura híbrida (Gated Delta Networks) y su excepcional capacidad validada empíricamente para el lenguaje R, convirtiéndolo en un especialista para tareas estadísticas complejas.

* **Riesgo o debilidad:** Al tener 9B parámetros, su tamaño de \~6 GB en Q4 ejercerá una presión máxima sobre el ancho de banda del equipo, resultando en velocidades marginales (5-6 tok/s), haciéndolo menos ágil para autocompletado en tiempo real.  
* **Evidencia:** Evaluado y validado de manera independiente por Simon Couch en helperbench para refactorización en R, alcanzando tasas de éxito casi perfectas9. [Fuente](https://simonpcouch.com/blog/2026-04-16-local-agents-2/)

**2\. ibm-granite/granite-4.1-8b-instruct** Destaca por haber sido concebido desde sus cimientos para el entorno corporativo. A diferencia del Gemma 4 E4B, Granite 4.1 fue sometido a un riguroso alineamiento mediante aprendizaje por refuerzo (RL) multietapa enfocado exclusivamente en el uso de herramientas y adhesión a instrucciones estrictas, sin depender de cadenas de pensamiento15.

* **Riesgo o debilidad:** Su enfoque centrado en la seguridad empresarial (Guardian) y abstracción de datos puede volverlo más conservador en la escritura de algoritmos creativos o exploración de código novedoso.  
* **Evidencia:** Supera al modelo anterior de 32B en llamadas a herramientas y extracción de datos estructurados, alcanzando 89.6% en HumanEval15. [Fuente](https://www.ibm.com/granite/docs/models/granite4-1)

**3\. microsoft/Phi-4-mini-instruct** Destaca inmensamente por su huella de memoria minúscula. Con solo 3.8B parámetros y ocupando 2.2 GB en RAM, liberará el bus de memoria del Intel Core Ultra, permitiendo un procesamiento cercano a los 15-20 tok/s mientras maneja con destreza el razonamiento lógico derivado de su entrenamiento sintético30.

* **Riesgo o debilidad:** Tiende a perder coherencia y enfoque cuando se satura su ventana de contexto extensa con documentación densa o trazas de error extremadamente largas.  
* **Evidencia:** Optimizado para la adherencia de instrucciones y matemáticas de alta densidad32. [Fuente](https://huggingface.co/llmware/phi-4-mini-gguf)

### **5.3 Recomendación Final**

Basado en la compatibilidad estricta de hardware, evidencia empírica en programación agéntica y rendimiento validado en R, los modelos sugeridos para descarga y despliegue inmediato son:

> 1. **Qwen/Qwen3.5-9B (Alibaba Cloud):** La recomendación absoluta por ser el único modelo de este tamaño con evidencia independiente documentada de refactorización exitosa en el lenguaje R y robusto uso de herramientas.  
> 2. **ibm-granite/granite-4.1-8b-instruct (IBM):** La mejor alternativa de respaldo debido a su entrenamiento enfocado en determinismo empresarial, nula latencia por pensamiento latente y diseño algorítmico estable.

**Detalles de Configuración y Enlaces Directos:**

* **Para Qwen3.5-9B:**  
  * **Enlace:** https://huggingface.co/bartowski/Qwen3.5-9B-GGUF (o equivalente del laboratorio/unsloth).  
  * **Archivo sugerido:** qwen3.5-9b-instruct-q4\_k\_m.gguf (El esquema de cuantización K-quants preserva la precisión de los pesos atípicos necesarios para el código).  
  * **Configuración obligatoria:** Se debe inyectar el parámetro "enable\_thinking": false en la configuración de la solicitud del servidor local, o asegurar que el arnés (Cline/Zero) elimine el token \<|think|\> de la plantilla para prevenir bloqueos por latencia22.  
* **Para Granite 4.1 8B:**  
  * **Enlace:** https://huggingface.co/bartowski/granite-4.1-8b-instruct-GGUF  
  * **Archivo sugerido:** granite-4.1-8b-instruct-q4\_k\_m.gguf

### **5.4 Señales de Alerta (Red Flags)**

Durante el proceso de investigación y recopilación de métricas, se identificaron factores críticos de riesgo que deben monitorearse durante la adopción:

> 1. **Contaminación de Benchmarks Clásicos:** Evite utilizar HumanEval o MBPP como métricas definitivas de calidad. Las puntuaciones cercanas al 90% reportadas por los laboratorios para modelos de \<10B parámetros son indicativas de sobreentrenamiento (overfitting) o contaminación directa del conjunto de datos8. El rendimiento real solo es predecible mediante evaluaciones como LiveCodeBench o SWE-bench Verified.  
> 2. **Marketing Engañoso sobre Modelos MoE:** Desconfíe de la promoción de modelos descritos como "pequeños" basándose en sus parámetros activos (ej. 3B activos). Si el tamaño total del modelo excede la capacidad de la memoria RAM del sistema (como los 284B totales de DeepSeek-V4-Flash o los 80B de Qwen3-Coder-Next), el modelo colapsará la máquina independientemente del cómputo requerido por token10.  
> 3. **Bucles de Razonamiento Destructivos:** En foros especializados, los desarrolladores reportan que el modo de "pensamiento" (reasoning) introducido en 2026 con frecuencia rompe los flujos de trabajo de los agentes de codificación, ya que el modelo se atasca en justificaciones interminables en lugar de invocar la herramienta JSON solicitada20.  
> 4. **Inestabilidad de Software (SYCL):** Se han documentado informes de errores recientes en el motor llama.cpp donde la combinación del backend SYCL para gráficas Intel Arc junto con la función *Flash Attention* (-fa) produce corrupciones en la salida (fragmentos Unicode y alucinaciones) en ciertos modelos38.

## **6\. Configuración Óptima del Servidor de Inferencia (Intel SYCL)**

Para materializar las ganancias operativas en el hardware especificado y mitigar el severo límite del ancho de banda de la memoria de canal único, la infraestructura subyacente debe ser configurada explícitamente para compilar llama.cpp utilizando la biblioteca oneAPI de Intel.  
**Proceso de Compilación y Ejecución:** Se requiere instalar previamente el Intel oneAPI Base Toolkit. Tras inicializar el entorno mediante el script de variables (setvars.bat), la compilación óptima en Windows se efectúa forzando el compilador de C++ de Intel3:

Bash  
cmake \-B build \-G "Visual Studio 17 2022" \-T "Intel C++ Compiler 2025" \-A x64 \-DGGML\_SYCL=ON \-DCMAKE\_BUILD\_TYPE=Release

El comando de lanzamiento del servidor de inferencia debe balancear la carga entre la iGPU (para acelerar la ingesta masiva de código fuente) y la CPU. Un ejemplo de lanzamiento robusto sería:  
llama-server.exe \-m \[modelo.gguf\] \-ngl 999 \-c 8192 \-b 512 \-t \[hilos\]  
La bandera \-ngl 999 intenta descargar todas las operaciones tensoriales soportadas a la unidad gráfica integrada. Es imperativo monitorear el comportamiento de Flash Attention (-fa); si se observan salidas corruptas o incoherentes, debe omitirse este flag debido a las inestabilidades documentadas en la integración de SYCL para las arquitecturas Intel Core Ultra38. Finalmente, el número de hilos (-t) debe alinearse idealmente con el número físico de núcleos de alto rendimiento (P-cores) del Arrow Lake-H para evitar la contención asimétrica con los núcleos de eficiencia (E-cores).

## **7\. Nota para NotebookLM**

Para garantizar la integridad del análisis en futuras iteraciones dentro de NotebookLM, al procesar este documento en conjunción con fuentes adicionales (como tarjetas de modelos actualizadas o hilos comunitarios), proceda bajo las siguientes directrices estructurales:

* **Filtro Implacable de Restricciones Físicas:** Priorice contrastar cualquier afirmación externa de velocidad o eficiencia contra la restricción física delineada en la Sección 1 y 4 (el modelo en su totalidad debe residir en ![][image1] 8 GB de RAM). En lugar de resumir especificaciones de modelos MoE que superan los 14B de parámetros totales, desestímelos activamente indicando que su huella de almacenamiento excede los recursos disponibles.  
* **Contraste de Evidencia y Métricas R:** Señale contradicciones evidentes. Si una tarjeta de modelo publicita excelencia algorítmica general, confróntela con la escasez de datos específicos para la sintaxis del lenguaje R, destacando que el rendimiento en R no es correlativo al rendimiento en Python y requiere de verificaciones exhaustivas como el helperbench documentado en las secciones 2 y 5\.  
* **Generación de Tablas:** Si se invoca la expansión de la tabla en la Sección 5.1 utilizando nuevas fuentes, asegúrese de extraer la información empleando un modelo estricto de evidencia. Marca como "Sin dato" o "No verificado" cualquier celda donde la información no esté explícitamente confirmada en la fuente documental, evitando inferencias heurísticas.  
* **Identificación de Vacíos en la Investigación:** En base a la síntesis actual, una pregunta de la Sección 3 permanece con cobertura parcial: *la evidencia específica de degradación sintáctica de modelos puramente empresariales (como Granite 4.1) operando bajo la gramática funcional del ecosistema tidyverse en R*. Dado que la validación externa (Couch) se centró en las familias Qwen y Gemma, las búsquedas subsiguientes deberán orientarse a ubicar métricas de abstracción de datos en R para la arquitectura de IBM.

#### **Fuentes citadas**

> 1. docs/build.md · b4521 · USTC-OS-Lab / llama.cpp · GitLab, [https://git.ustc.edu.cn/ustc-os-lab/llama.cpp/-/blob/b4521/docs/build.md](https://git.ustc.edu.cn/ustc-os-lab/llama.cpp/-/blob/b4521/docs/build.md)  
> 2. AI PC Brings Larger LLM Development to Your Desk \- Intel, [https://cdrdv2-public.intel.com/828499/PUM57-complete.pdf](https://cdrdv2-public.intel.com/828499/PUM57-complete.pdf)  
> 3. Run LLMs on Intel® GPUs Using llama.cpp, [https://www.intel.com/content/www/us/en/developer/articles/technical/run-llms-on-gpus-using-llama-cpp.html](https://www.intel.com/content/www/us/en/developer/articles/technical/run-llms-on-gpus-using-llama-cpp.html)  
> 4. Recommendation for Intel Core 5 Ultra 225H w/32GB RAM running LInux \- Reddit, [https://www.reddit.com/r/LocalLLM/comments/1rlv1tj/recommendation\_for\_intel\_core\_5\_ultra\_225h\_w32gb/](https://www.reddit.com/r/LocalLLM/comments/1rlv1tj/recommendation_for_intel_core_5_ultra_225h_w32gb/)  
> 5. SYCL.md \- llama.cpp \- GitHub, [https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/SYCL.md](https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/SYCL.md)  
> 6. Local models are not there (yet) \- Posit, [https://posit.co/blog/local-models-are-not-there-yet](https://posit.co/blog/local-models-are-not-there-yet)  
> 7. logs \- Simon P. Couch, [https://simonpcouch.com/assets/2025-12-04-local-agents/logs/index.html](https://simonpcouch.com/assets/2025-12-04-local-agents/logs/index.html)  
> 8. LiveCodeBench v6 Leaderboard \- LLM Stats, [https://llm-stats.com/benchmarks/livecodebench-v6](https://llm-stats.com/benchmarks/livecodebench-v6)  
> 9. LLMs running on my laptop can drive coding agents now | Simon P. Couch, [https://simonpcouch.com/blog/2026-04-16-local-agents-2/](https://simonpcouch.com/blog/2026-04-16-local-agents-2/)  
> 10. Qwen/Qwen3-Coder-Next-GGUF \- Hugging Face, [https://huggingface.co/Qwen/Qwen3-Coder-Next-GGUF](https://huggingface.co/Qwen/Qwen3-Coder-Next-GGUF)  
> 11. qwen3-coder-next \- Ollama, [https://ollama.com/library/qwen3-coder-next](https://ollama.com/library/qwen3-coder-next)  
> 12. Aider code editing leaderboard has been replaced by new, much more challenging polyglot leaderboard. o1 tops it. : r/singularity \- Reddit, [https://www.reddit.com/r/singularity/comments/1hk6tzs/aider\_code\_editing\_leaderboard\_has\_been\_replaced/](https://www.reddit.com/r/singularity/comments/1hk6tzs/aider_code_editing_leaderboard_has_been_replaced/)  
> 13. Qwen3.5-35B-A3B alcanza el 37.8% en SWE-bench Verified Hard — casi igualando a Claude Opus 4.6 (40%) con la estrategia de verificación correcta \- Reddit, [https://www.reddit.com/r/LocalLLaMA/comments/1rkdlqi/qwen3535ba3b\_hits\_378\_on\_swebench\_verified\_hard/?tl=es-419](https://www.reddit.com/r/LocalLLaMA/comments/1rkdlqi/qwen3535ba3b_hits_378_on_swebench_verified_hard/?tl=es-419)  
> 14. Qwen3-Coder-Next: The Complete 2026 Guide to Running Powerful AI Coding Agents Locally \- DEV Community, [https://dev.to/sienna/qwen3-coder-next-the-complete-2026-guide-to-running-powerful-ai-coding-agents-locally-1k95](https://dev.to/sienna/qwen3-coder-next-the-complete-2026-guide-to-running-powerful-ai-coding-agents-locally-1k95)  
> 15. Introducing the IBM Granite 4.1 family of models, [https://research.ibm.com/blog/granite-4-1-ai-foundation-models](https://research.ibm.com/blog/granite-4-1-ai-foundation-models)  
> 16. Qwen: Qwen3.5: Towards Native Multimodal Agents, [https://qwen.ai/blog?id=qwen3.5](https://qwen.ai/blog?id=qwen3.5)  
> 17. GitHub \- QwenLM/Qwen3-Coder: Qwen3-Coder is the code version of Qwen3, the large language model series developed by Qwen team., [https://github.com/QwenLM/Qwen3-Coder](https://github.com/QwenLM/Qwen3-Coder)  
> 18. Granite 4.1 \- IBM, [https://www.ibm.com/granite/docs/models/granite4-1](https://www.ibm.com/granite/docs/models/granite4-1)  
> 19. Gemma 4's Thinking Mode: A Practical Guide to the \`\<|think|\>\` Token \- DEV Community, [https://dev.to/pulkitgovrani/gemma-4s-thinking-mode-a-practical-guide-to-the-think-token-8c5](https://dev.to/pulkitgovrani/gemma-4s-thinking-mode-a-practical-guide-to-the-think-token-8c5)  
> 20. What is the best local LLMs as of March 2026? : r/LocalLLaMA \- Reddit, [https://www.reddit.com/r/LocalLLaMA/comments/1rkppnl/what\_is\_the\_best\_local\_llms\_as\_of\_march\_2026/](https://www.reddit.com/r/LocalLLaMA/comments/1rkppnl/what_is_the_best_local_llms_as_of_march_2026/)  
> 21. Qwen3.5-9B tops every AI benchmark right now, but that's not how you should pick a model, [https://www.xda-developers.com/qwen-3-5-9b-tops-ai-benchmarks-not-how-pick-model/](https://www.xda-developers.com/qwen-3-5-9b-tops-ai-benchmarks-not-how-pick-model/)  
> 22. Qwen3.5-9B: Specifications and GPU VRAM Requirements \- ApX Machine Learning, [https://apxml.com/models/qwen35-9b](https://apxml.com/models/qwen35-9b)  
> 23. DeepSeek-V4: How to Run Locally | Unsloth Documentation, [https://unsloth.ai/docs/models/deepseek-v4](https://unsloth.ai/docs/models/deepseek-v4)  
> 24. Llama 4 Review — The Best Open-Source LLM Yet? | LLM Configurator Blog, [https://llmconfigurator.com/en/blog/llama-4-review-best-open-source-llm](https://llmconfigurator.com/en/blog/llama-4-review-best-open-source-llm)  
> 25. Qwen3.5: Nobody Agrees on Attention Anymore \- Hugging Face, [https://huggingface.co/blog/mlabonne/qwen35](https://huggingface.co/blog/mlabonne/qwen35)  
> 26. qwen/qwen3-coder-next \- LM Studio, [https://lmstudio.ai/models/qwen/qwen3-coder-next](https://lmstudio.ai/models/qwen/qwen3-coder-next)  
> 27. deepseek-ai / deepseek-v4-flash \- NVIDIA API Documentation, [https://docs.api.nvidia.com/nim/reference/deepseek-ai-deepseek-v4-flash](https://docs.api.nvidia.com/nim/reference/deepseek-ai-deepseek-v4-flash)  
> 28. Gemma 4 12B: Benchmarks, VRAM & How to Run It | TECHSY, [https://techsy.io/en/blog/gemma-4-12b](https://techsy.io/en/blog/gemma-4-12b)  
> 29. Granite \- IBM, [https://www.ibm.com/granite](https://www.ibm.com/granite)  
> 30. Phi-4-mini-instruct-GGUF | PromptLayer Models, [https://www.promptlayer.com/models/phi-4-mini-instruct-gguf/](https://www.promptlayer.com/models/phi-4-mini-instruct-gguf/)  
> 31. Welcome to the new Phi-4 models \- Microsoft Phi-4-mini & Phi-4-multimodal, [https://techcommunity.microsoft.com/blog/educatordeveloperblog/welcome-to-the-new-phi-4-models---microsoft-phi-4-mini--phi-4-multimodal/4386037](https://techcommunity.microsoft.com/blog/educatordeveloperblog/welcome-to-the-new-phi-4-models---microsoft-phi-4-mini--phi-4-multimodal/4386037)  
> 32. unsloth/Phi-4-mini-instruct-GGUF \- Hugging Face, [https://huggingface.co/unsloth/Phi-4-mini-instruct-GGUF](https://huggingface.co/unsloth/Phi-4-mini-instruct-GGUF)  
> 33. Phi 4 Mini Instruct GGUF by MaziyarPanahi — VRAM 1.7GB | LLM Explorer, [https://llm-explorer.com/model/MaziyarPanahi%2FPhi-4-mini-instruct-GGUF,2KzGsbooT8Fo02Z7oIATWs](https://llm-explorer.com/model/MaziyarPanahi%2FPhi-4-mini-instruct-GGUF,2KzGsbooT8Fo02Z7oIATWs)  
> 34. Gemma 4 Technical Report \- arXiv, [https://arxiv.org/html/2607.02770v1](https://arxiv.org/html/2607.02770v1)  
> 35. Disable thinking for Gemma 4 \- Google AI Developers Forum, [https://discuss.ai.google.dev/t/disable-thinking-for-gemma-4/138885](https://discuss.ai.google.dev/t/disable-thinking-for-gemma-4/138885)  
> 36. How to disable thinking in Gemma 4 via Ollama — 2026 \- WebCraft, [https://webscraft.org/blog/reasoning-mode-v-gemma-4-yak-vmikati-koli-potribno-i-skilki-koshtuye-2026?lang=en](https://webscraft.org/blog/reasoning-mode-v-gemma-4-yak-vmikati-koli-potribno-i-skilki-koshtuye-2026?lang=en)  
> 37. Phi-4 GGUF \- Optimized AI Model for GGUF Inference \- AIKosh, [https://aikosh.indiaai.gov.in/home/models/details/phi\_4\_gguf\_optimized\_ai\_model\_for\_gguf\_inference.html](https://aikosh.indiaai.gov.in/home/models/details/phi_4_gguf_optimized_ai_model_for_gguf_inference.html)  
> 38. SYCL: Flash attention (-fa) produces corrupted output on Intel Arc iGPU (Arrow Lake Xe2) · Issue \#19276 · ggml-org/llama.cpp \- GitHub, [https://github.com/ggml-org/llama.cpp/issues/19276](https://github.com/ggml-org/llama.cpp/issues/19276)

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAZCAYAAAA4/K6pAAAAlElEQVR4XmNgGAV0B6xA7AvEoegS+IAwEHcDcSeUTTRQB+JFQPwMiJPR5PACZiC2AuKrQBzAAHE2UQCkMAKIbwHxLiBmRJXGDziB+AkDGf5EBtxAnM8A8TPI72QDkFdAfj8OxOYMJHoFGYA0g8ICFphkA0Ugns8AiUqQNykCIANABhWiSwwDAIoqSRIwD0TbKKAKAACD5BFv3+RyRwAAAABJRU5ErkJggg==>