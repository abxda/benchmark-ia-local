# Referencia: contra qué comparar un candidato

Los campeones actuales del benchmark, expresados en términos **públicamente verificables** — identidad del modelo, tamaño en disco, arquitectura y benchmarks abiertos. El resultado interno (`5/6`, `6/6` sobre una suite propia de 6 tareas) no es comparable con nada de la calle; sirve como bitácora, no como criterio de monitoreo.

Última medición: 2026-07-26 (fase 6b). Fuente completa: `llm_benchmark/RESULTADOS.md`.

---

## Los campeones

| Rol | Modelo | Arquitectura | Q4 en disco | Medición propia |
|---|---|---|---|---|
| **Interactivo** (IDE/chat, un turno) | **Qwen3-Coder-30B-A3B** (`qwen3-coder:30b`) Q4_K_M | MoE 30B / 3.3B activos | ~18 GB | 5/6 · 17.1 tok/s |
| **Lotes agénticos** | **gemma-4-26B-A4B-it** UD-Q4_K_XL | MoE 25.2B / 3.8B activos | ~17 GB | 6/6 · 76 min |
| **Edge** (RAM libre) | **Gemma 4 E4B-it** Q4_K_M | Denso ~4.5B efectivos | ~5 GB | 6/6 · 2.45 h |

Hardware: Intel Core Ultra 5 225H, 32 GB DDR5 **canal único**, sin GPU dedicada, backend **solo CPU** (llama.cpp b10107, 10 hilos).

---

## Los umbrales públicos que un candidato debe superar

Lo que sí se puede contrastar contra una ficha de modelo o un anuncio:

- **Envolvente de hardware** — ≤20 GB en Q4 y MoE con **≤4B parámetros activos**. Es el filtro más duro y el más fácil de verificar: sale del nombre (`XXB-AYB`) y del tamaño del GGUF. Un candidato que no lo cumpla no se prueba, sin importar sus números.
- **Código (Python)** — **SWE-bench Verified ≥ 52%** bajo scaffold comparable. Es donde ronda Qwen3-Coder-30B-A3B. LiveCodeBench v6 sirve como alterna; **HumanEval y MBPP no**: están contaminados, todo modelo pequeño reporta ~90%.
- **R (el diferenciador)** — **helperbench** de Simon Couch (Posit), ≥9/10 en refactorización agéntica real. Es la única evaluación seria de LLMs locales en R que existe. Un candidato con evidencia ahí vale la prueba **aunque no sea "coder" de nombre y aunque en Python solo empate**: R es donde todos los campeones fallan.
- **Capacidad agéntica** — SWE-bench como métrica primaria del anuncio, o entrenamiento con RL sobre herramientas. El bucle agéntico es lo que rescata las tareas de R.

---

## La advertencia que debe ir en el prompt

**Los números anunciados no predicen el resultado en esta máquina.** Caso medido, no hipotético:

> **KAT-Coder-V2.5-Dev** (MoE 35B-A3B, RL agéntico) anuncia **69.4% en SWE-bench Verified** — muy por encima del ~52% del campeón. En la laptop **empató en calidad (5/6) y perdió en velocidad (13% más lento, 12.9-13.4 vs 15.5 tok/s)**. No destronó a nadie y quedó como reserva.

De ahí que un benchmark superior sea **señal para probar, no evidencia de mejora**. Dos correcciones concretas al puntuar:

1. Un número alto obtenido **con razonamiento activado** no transfiere: a ~15 tok/s, pensar cuesta 8-15 min por tarea. Si el anuncio no aclara si el score es con o sin thinking, asumir que es con.
2. **Cifra reportada por el propio lab ≠ evaluación independiente.** Pesa más una medición de terceros bajo scaffold conocido, o un reporte de tok/s en iGPU/CPU de laptop, que cualquier tabla del anuncio.

A igual calidad, **decide la velocidad**. A igual velocidad, decide R.
