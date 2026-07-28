# Benchmark de IA local — laptop INEGI

Evaluación empírica y reproducible de modelos de lenguaje abiertos corriendo localmente
(Intel Core Ultra 5 225H, 32 GB DDR5 canal único, Windows 11) para programación en
Python y R: automatización de Excel, dashboards y series de tiempo.

## Mapa de documentos

| Documento | Para qué |
|---|---|
| [SEGUIMIENTO.md](SEGUIMIENTO.md) | **Empezar aquí**: estado actual, bitácora, próximos pasos, checklist |
| [RESULTADOS.md](RESULTADOS.md) | Informe técnico completo (fases 1-5, matrices, autopsias) |
| [QUE_MONITOREAR.md](QUE_MONITOREAR.md) | Radar: qué buscar en internet y cuándo re-correr el benchmark |
| [PROPUESTA_PONENCIA.md](PROPUESTA_PONENCIA.md) | Propuesta para el evento (nombre + objetivo) |
| [DEEPRESEARCH_MODELOS_PEQUENOS.md](DEEPRESEARCH_MODELOS_PEQUENOS.md) | Prompt autocontenido para investigación profunda (Claude / NotebookLM) |

## Resultado en una línea

`qwen3-coder:30b` para uso interactivo (5/6 tareas, 15.5 tok/s) y **Gemma 4 E4B + Zero**
para lotes desatendidos (**6/6 con 5 GB de RAM**) — calidad de asistente comercial en
tareas acotadas, sin licencias y sin que los datos salgan del equipo.

## Reproducir

```
python make_data.py                                   # datos sinteticos (semilla fija)
python bench.py <modelo>                              # un turno via Ollama
python bench.py <etiqueta> --backend llama --port N   # un turno via llama-server
python bench_cline.py <etiqueta> [tarea...]           # agentico via Cline CLI
python bench_zero.py <etiqueta> [tarea...]            # agentico via Zero
```

Detalle del protocolo y checklist completo en [SEGUIMIENTO.md](SEGUIMIENTO.md).
