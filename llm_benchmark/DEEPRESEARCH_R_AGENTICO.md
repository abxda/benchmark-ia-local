# Brief de investigación: ¿qué modelos abiertos son realmente buenos en R, y por qué casi ninguno lo es?

> **Cómo usar este documento**
> Pégalo completo como prompt en un agente de investigación profunda (Gemini Deep Research,
> Claude, NotebookLM). Es autocontenido: incluye hardware, resultados empíricos propios y
> criterios. No necesita contexto adicional.
> **Ventana de búsqueda:** lanzamientos y publicaciones de los últimos 12 meses.

---

## 1. Por qué esta pregunta

Evalúo modelos de lenguaje **de pesos abiertos, ejecutables 100% en local** para trabajo
estadístico en **Python y R**. Llevo ~15 modelos medidos con un benchmark propio que
**ejecuta el código generado y valida el archivo producido** (no evalúa el texto de la
respuesta).

El hallazgo que motiva esta investigación: **en Python casi todos los modelos funcionan;
en R casi todos fracasan, y fracasan de formas específicas y repetidas.** R es la mitad
de mi trabajo real, y prácticamente ningún benchmark público de código lo cubre —
HumanEval, MBPP, SWE-bench, LiveCodeBench y Terminal-Bench son esencialmente Python y
shell. Eso significa que **los rankings que existen no predicen lo que me importa**, y lo
he confirmado: modelos con SWE-bench alto se caen en mis tareas de R.

Quiero entender la causa y encontrar los modelos que sí sirven.

---

## 2. Evidencia propia (línea base — úsala, no la repitas)

Suite de 6 tareas: 3 dominios (automatización de Excel, generación de dashboards,
pronóstico de series de tiempo) × 2 lenguajes (Python y R). Modo agéntico: el modelo
escribe, ejecuta, lee el error y se corrige, hasta 25 turnos. Razonamiento desactivado.
Datos sintéticos con semilla fija. Hardware de medición: RTX 3060 12 GB; el perfil de
referencia es una laptop sin GPU.

**Resultados relevantes (marcador global y comportamiento en R):**

| Modelo | Tamaño Q4 | Global | Comportamiento en R |
|---|---|---|---|
| gemma-4-26B-A4B (MoE 3.8B act.) | 17 GB | 6/6 | Único que pasa las tres tareas de R sin drama |
| Gemma 4 E4B (edge 7.5B ef.) | 5 GB | 6/6 | Sólido pese al tamaño |
| Qwen3.8-27B 2-bit | 9 GB | 6/6 | Pasa, con tropiezos en fechas |
| Nemotron 3.5 Lightning 30B-A3B | 25 GB | 6/6 | Pasa Excel-R; inestable en series (75%) |
| Qwopus3.6-35B-A3B | 17 GB | 5/6 | El mejor en series de tiempo R; falla Excel-R |
| Ornith-1.5-9B (denso) | 5.8 GB | 4/6 | Falla Excel-R; series R estable (83%) |
| Qwen3.8-9B destilado | 5.8 GB | 4/6 | Python rapidísimo, R roto |
| Ternary Bonsai 2 27B (1.72 bpw) | 6 GB | 4/6 | Alucina funciones de R inexistentes |
| Gemma 4 E2B (4.65B ef.) | 3.1 GB | 3/6 | **3/3 en Python, 0/3 en R** |
| Qwen3.5-0.8B | 0.5 GB | 0/6 | No produce código válido |

**Taxonomía de fallos en R que he observado y verificado leyendo las trazas:**

1. **Alucinación de paquetes y funciones**: `library(writex)` en vez de `writexl`;
   `writex::write_tibble()`, que no existe.
2. **Argumentos inventados**: `write_xlsx(..., sheet = "Resumen")` — writexl no tiene ese
   parámetro. Cometido por modelos de familias distintas, lo que sugiere una confusión
   sistemática con la API de openxlsx o con pandas.
3. **Identificadores inventados en el idioma del prompt**: un modelo cuantizado a 1.72
   bits escribió `ordenar(resumen, by = 1)` en un script en español.
4. **Fechas**: el fallo más recurrente de todos. Uso de `%m+%` o `months()` de lubridate
   sin cargar la librería; `seq()` con argumentos no numéricos; aritmética de fechas con
   `+ 1:12*30` en vez de meses reales.
5. **Confusión de concepto**: confundir el nombre de una hoja de Excel con el nombre del
   archivo (generar `Resumen.xlsx` en vez de una hoja llamada `Resumen`).
6. **Abandono del archivo**: ante un error, el modelo deja de editar `script.R` y empieza
   a improvisar con `Rscript -e '...'`, donde el escapado del shell rompe `$` y comillas.
7. **Fallo silencioso**: el script corre sin error pero el entregable no cumple la
   especificación. El bucle agéntico **no** lo corrige, porque el intérprete no protesta.

**Dato de método descubierto:** en modo agéntico el **prefill** (procesar el prompt) pesa
más que el **decode** (generar), porque cada turno reprocesa un contexto largo. Un modelo
con 28% más decode y 40% menos prefill resultó 25% más lento en tiempo real.

---

## 3. Lo que necesito que investigues

### Pregunta A — ¿Por qué los modelos son malos en R?
Busca evidencia sobre la **composición de los datos de entrenamiento** de los modelos de
código abiertos. En particular:
- ¿Qué proporción de R declaran los reportes técnicos de las familias principales
  (Qwen, Gemma, DeepSeek, Llama, Mistral, StarCoder/BigCode, Granite, Nemotron)?
- ¿Alguna familia declara explícitamente R como lenguaje soportado o priorizado?
- ¿Hay análisis publicados (papers, posts técnicos, tesis) sobre el desempeño de LLMs en
  R frente a Python, y sobre las causas (menos código en GitHub, dialectos tidyverse vs
  base R, documentación en viñetas en vez de docstrings)?
- ¿Existe evidencia de que el ecosistema **tidyverse vs base R** confunda a los modelos?

### Pregunta B — ¿Qué evaluaciones de R existen?
Necesito discriminadores mejores que mi suite, que ya se satura (varios modelos empatan
en 6/6). Busca:
- Benchmarks, evals o leaderboards que midan **R específicamente** (por ejemplo, trabajos
  del ecosistema Posit/RStudio, `helperbench` de Simon Couch, evaluaciones de paquetes
  como `ellmer`, `chattr`, `gander`, o cualquier suite académica).
- Benchmarks **multilenguaje** que incluyan R como subconjunto y publiquen el desglose
  (MultiPL-E, BabelCode, McEval, y equivalentes recientes).
- Para cada uno: qué mide exactamente, si ejecuta el código, si es agéntico o de un turno,
  dónde están los resultados y qué modelos abiertos aparecen.

### Pregunta C — ¿Qué modelos abiertos tienen evidencia real de ser buenos en R?
Lista candidatos con **evidencia verificable**, no marketing. Para cada uno: tamaño,
arquitectura (denso o MoE, parámetros activos), licencia, disponibilidad en GGUF, y la
**fuente concreta** de la evidencia en R. Prioriza:
- Modelos que quepan en ≤20 GB en Q4 (mi techo práctico).
- MoE con pocos parámetros activos, que en mi hardware rinden mucho mejor que densos.
- Evidencia de terceros por encima de la auto-reportada.

### Pregunta D — ¿Cómo mitigar los fallos de la taxonomía?
Busca técnicas documentadas y medidas (no especulación) para reducir esos fallos en local:
prompts de sistema específicos de R, inyección de documentación de paquetes, gramáticas o
salida estructurada, linters en el bucle agéntico (`lintr`, `styler`), verificación previa
de existencia de funciones, o herramientas MCP para R. Indica qué evidencia hay de que
funcionen y cuánto mejoran.

---

## 4. Reglas de rigor (importantes)

- **Verifica las citas contra la fuente primaria.** Me ha pasado que reportes de
  investigación atribuyen mal la evidencia: un post que evaluaba dos modelos MoE fue
  citado como si hubiera evaluado otros dos modelos distintos. Si citas un resultado, abre
  el original y confirma **qué modelo exacto y qué variante** se midió.
- **Distingue siempre** entre cifras auto-reportadas por el laboratorio y medidas por
  terceros independientes, y dilo explícitamente en cada caso.
- **Distingue** entre resultados con razonamiento activado y desactivado: mi contrato de
  medición lo desactiva, y las cifras publicadas suelen ser con razonamiento encendido.
- **Si no hay evidencia, dilo.** Prefiero "no encontré evaluaciones de R para esta familia"
  a una inferencia presentada como hecho. La ausencia de datos es en sí un hallazgo.
- Señala la **fecha** de cada fuente; en este campo seis meses son mucho tiempo.

---

## 5. Entregables

1. **Respuesta a la pregunta A** en 3-5 párrafos, con las cifras de composición de datos
   que hayas podido verificar y su fuente.
2. **Tabla de evaluaciones de R** (pregunta B): nombre, qué mide, ejecuta código sí/no,
   agéntico sí/no, enlace, modelos abiertos evaluados.
3. **Tabla de candidatos** (pregunta C) ordenada por fuerza de la evidencia, no por
   popularidad, con la columna "fuente de la evidencia en R" siempre llena.
4. **Lista de mitigaciones** (pregunta D) ordenada por evidencia de efectividad, indicando
   cuáles son aplicables a un runtime local tipo llama.cpp.
5. **Tres hallazgos que no esperaba**: lo que más me sirve es lo que contradiga mis
   supuestos o abra una línea que no estoy viendo.
