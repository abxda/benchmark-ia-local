# Qué monitorear en internet: el próximo modelo que valdría la pena probar

Perfil construido a partir de la evidencia empírica del benchmark del 2026-07-22,
actualizado tras las fases 4-5 (2026-07-24, ver `RESULTADOS.md`). Hoy hay **dos campeones
por rol**: `qwen3-coder:30b` Q4_K_M para uso interactivo (5/6 un turno, 15.5 tok/s) y
**Gemma 4 E4B** Q4 para lotes agénticos desatendidos (6/6 con Zero, 5 GB de RAM). Solo
vale la pena interrumpir el trabajo y re-correr el benchmark si aparece algo que cumpla
la ficha de abajo.

## La ficha del modelo hipotético (todas obligatorias)

| Criterio | Umbral | Por qué (lección del experimento) |
|---|---|---|
| **Arquitectura** | MoE con **≤4B parámetros activos** | En canal único de memoria, los densos ≥14B son inviables (7B denso = 7.4 tok/s; 27B denso ternario = 2.3 tok/s). El MoE 3.3B activos dio 15.5 tok/s. |
| **Tamaño total en Q4** | **≤20 GB** (≈ ≤35B totales) | 32 GB de RAM: el 30B Q4 usa 19 GB y deja ~13 GB para IDE + R + Python. |
| **Cuantización** | **Q4 nativo disponible** (GGUF) | El 2-bit degradó un 35B al nivel de un 7B (2/6 tareas, mismos errores torpes). Preferir Q4 de un modelo que quepa, nunca Q2 de uno grande. |
| **Especialización** | **Coder / instruct, NO-pensante** (o pensamiento desactivable de verdad) | A ~14 tok/s el razonamiento cuesta 8-15 min por tarea simple: inutilizable. El entrenamiento coder marcó la diferencia en seguir especificaciones exactas. |
| **Soporte de runtime** | Cargable en **llama.cpp mainline u Ollama** desde el día 1 | Los formatos que exigen forks (Bonsai/ternario) son fricción y riesgo. Si Unsloth publica GGUFs, buena señal. |
| **Calidad** | **SWE-bench Verified ≥ 52%** (mismo scaffold) o señal directa de R | El 30B actual ronda 50-52%. Menos que eso no justifica el cambio. |

**El diferenciador real es R.** Todos los modelos fallaron en R (el campeón: 2/3).
Un MoE ≤35B con evidencia de R (helperbench ≥90%, o entrenamiento explícito con
corpus de R como hizo StarCoder2) es el hallazgo que cambiaría la recomendación,
aun si en Python solo empata.

## Las pistas: cómo reconocerlo sin saber su nombre

No busques marcas ni versiones — busca estos patrones en cualquier anuncio o ficha
de modelo, vengan del lab que vengan:

- **El patrón "XXB-AYB" en el nombre o la ficha técnica** (p. ej. "30B-A3B",
  "26B-A4B"): totales-B / activos-B. Es la firma de un MoE eficiente. Lo que
  buscas: primera cifra ≤35, segunda cifra ≤4. Ese patrón en un modelo *coder* es
  la señal más fuerte que existe para esta laptop.
- **La palabra "Coder" / "Code" / "Dev" en un lanzamiento de familia nueva**: los
  labs publican primero la familia general (pensante) y semanas-meses después la
  variante coder no-pensante. Cuando una familia MoE pequeña nueva demuestre buen
  código, la variante coder que le siga es el candidato natural.
- **Cualquier evaluación independiente de LLMs locales en R** que muestre un
  modelo ≤35B con ≥85%: R es terreno tan descuidado que una sola fuente seria
  basta para justificar la prueba, aunque el modelo no sea "coder" de nombre.
- **Un agregador/comunidad reportando tok/s decentes en iGPU/CPU de laptop**
  (no en GPUs dedicadas): señal de que el modelo es viable en hardware como este;
  los benchmarks en A100/4090 no transfieren.
- **Soporte anunciado en el changelog de los runtimes estándar** en los primeros
  días: si la arquitectura tarda semanas en llegar a mainline o vive en un fork,
  déjalo madurar.
- **Ternario/1-bit solo con tres palabras juntas**: *nativamente entrenado* + *MoE*
  + *coder*. La cuantización post-hoc a 1-2 bits y los ternarios densos ya quedaron
  descartados empíricamente; no hay excepción sin esas tres condiciones.

## Dónde vigilar (fuentes ordenadas por señal/ruido)

1. **Hugging Face** — trending de modelos con filtro GGUF + texto "coder"/"A3B"/"A4B";
   la cuenta de **Unsloth** (publican GGUFs dinámicos el día del lanzamiento).
2. **Ollama model library** (ollama.com/library) — si aparece ahí, el soporte ya está resuelto.
3. **r/LocalLLaMA** — los reportes de tok/s en hardware Intel/AMD iGPU salen ahí primero.
4. **Blog de Posit y helperbench de Simon Couch** — la única fuente seria de
   evaluación de LLMs **en R**; un post nuevo suyo vale más que cualquier benchmark general.
5. **Aider Polyglot leaderboard y SWE-bench Verified** — para el umbral de calidad
   (comparar siempre bajo el mismo scaffold).
6. **Releases de llama.cpp** — dos triggers: soporte de una arquitectura nueva de la
   lista de arriba, o mejoras SYCL/Vulkan para iGPU Intel (hoy la iGPU solo ayuda al prefill).

## Lo que las fases 4-5 cambiaron del perfil (modo agéntico)

- **El bucle agéntico compensa conocimiento, no velocidad**: un modelo pequeño que lee
  errores y corrige iterando alcanza la calidad de un grande de un turno (2/6→5/6 el
  4b; 4/6→6/6 el E4B). Al evaluar candidatos, la pregunta ya no es solo "¿qué sabe?"
  sino "¿qué tan bien itera?" — buscar evidencia de entrenamiento agéntico (RL con
  herramientas, SWE-bench como métrica primaria del anuncio).
- **Nueva clase a vigilar: edge (~4-5B efectivos, ≤5 GB en Q4)** con soporte mainline
  día 1. Si supera al campeón edge actual en un turno, probarla también en agéntico:
  la combinación ligera+agente es la que deja la laptop utilizable mientras trabaja.
- **La debilidad en R deja de ser eliminatoria si el modelo itera bien** (el agente la
  corrige solo); sigue siendo el diferenciador clave para el uso interactivo de un turno.
- **El harness importa**: cualquier prueba agéntica nueva debe hacerse con un harness
  que juzgue por códigos de salida reales (tipo Zero); en Windows, los que ejecutan vía
  PowerShell 5.1 producen errores fantasma con los warnings de R.

## Triggers que ameritan re-correr el benchmark (30 min con `bench.py`)

- Aparece un modelo que cumple la ficha completa → `ollama pull` + `python bench.py <modelo>`.
- Instalas el **segundo módulo DDR5-5600** → re-medir todo (esperado: ~2× decode, ~25-30 tok/s).
- llama.cpp anuncia mejora sustancial para Intel iGPU/NPU → re-medir prefill híbrido.
- Posit/helperbench publica un local ≤35B con ≥85% en R → probarlo aunque no sea coder.

## Qué ignorar (aprendido a costo de ~30 GB de descargas)

- Densos grandes "pero cuantizados chiquito" — la RAM baja, la velocidad no.
- Cuantizaciones ≤2 bits de cualquier cosa — la calidad cae al nivel de un modelo 4-8× menor.
- Modelos que solo rinden con razonamiento activado — localmente no hay presupuesto de tokens para pensar.
- Formatos que requieren forks o runtimes exóticos — esperar a que lleguen a mainline.
- Benchmarks sin scaffold comparable o reportados solo por el propio lab.
