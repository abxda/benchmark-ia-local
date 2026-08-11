# Seguimiento — IA local en laptop institucional

Bitácora viva del proyecto. Actualizar cada vez que se pruebe un modelo, harness o
configuración nueva. Última actualización: **2026-08-11**.

## Estado actual (campeones por rol)

| Rol | Modelo | Config | Resultado |
|---|---|---|---|
| Interactivo (IDE/chat) | **qwen3-coder:30b** Q4_K_M (18 GB) | llama.cpp **b10107** CPU, 10 hilos, temp 0, ctx 8-16K | 5/6 un turno · **17.1 tok/s** |
| Lotes desatendidos (agéntico) | **gemma-4-26B-A4B** UD-Q4_K_XL (17 GB) | Zero `exec` + llama-server, thinking off | **6/6 · 76 min** |
| Lotes con RAM libre | Gemma 4 E4B Q4_K_M (5 GB) | Zero `exec`, thinking off | 6/6 · 2.45 h |
| Reserva agéntica | KAT-Coder-V2.5 IQ4_XS (18.8 GB) | Cline o Zero | 5/6 · ~67-74 min |
| Mejor en R (series de tiempo) | Qwopus3.6-35B-A3B APEX I-Compact (17.3 GB) | Zero `exec` + llama-server, thinking off | 5/6 · 61 min — `ts_r` en 10.2 min, el mejor registrado; falla `excel_r` |

**Backend: solo CPU.** La iGPU quedó descartada empíricamente (fase 6a): SYCL degrada la
decodificación y Vulkan pierde el dispositivo con prompts reales. Usar build b10107 o
posterior (+10% de decodificación gratis sobre b10088).

## Bitácora

| Fecha | Fase | Qué se probó | Resultado clave |
|---|---|---|---|
| 2026-07-22 | 1 | 4 modelos vía Ollama (30B MoE, 4b, 7b, 8b), suite de 6 tareas | 30B gana: 5/6 y además el más rápido (MoE en canal único) |
| 2026-07-22 | 2 | Runtimes alternativos (llama.cpp CPU/Vulkan), 2-bit, ternario | Ollama=llama.cpp; 10 hilos > 14; cuantización extrema descartada |
| 2026-07-23 | 3 | KAT-Coder-V2.5-Dev IQ4_XS (35B-A3B, RL agéntico) | Empata 5/6, 13% más lento; primer modelo que pasa Excel R |
| 2026-07-23/24 | 4 | Modo agéntico: Cline CLI y Zero × (30B, KAT, 4b) | Primer 6/6 (30B×Zero); harness importa tanto como modelo; 4b: 2/6→5/6 |
| 2026-07-24 | 5 | Gemma 4 E4B (edge 4.5B ef., 5 GB) | Segundo 6/6 (con Zero), 3.6× menos RAM que el 30B; nuevo campeón de lotes |
| 2026-07-26 | 6a | Backends iGPU: SYCL vs Vulkan vs CPU (b10107) | SYCL refutado; Vulkan brilla en sintético pero pierde el dispositivo en carga real; +10% gratis por actualizar build |
| 2026-07-26 | 6b | gemma-4-26B-A4B (MoE 25.2B/3.8B act., 17 GB) | **6/6 agéntico en 76 min** (2.8× más rápido que el 30B); 5/6 un turno; nuevo campeón de lotes |
| 2026-07-28 | 3060-ancla | Estreno perfil `desktop-tr3990x-rtx3060-12gb-cuda`: campeón gemma-4-26B-A4B × Zero | **6/6 · 9.1 min** — reproduce el 6/6 de laptop a ~8.4×; 3060 validada como proxy (fix justo de PATH/rbin documentado) |
| 2026-07-28 | 3060-qwopus | Qwopus3.6-35B-A3B-Coder APEX I-Compact (17.3 GB, MoE ~3B act.) × Zero en la 3060 | **6/6 · 6.6 min** — ts_r en 49s (campeón: 194s); candidato fuerte, falta revalidar en laptop (la laptop decide) |
| 2026-07-28 | 7 | Qwopus APEX I-Compact en la laptop: un turno + Zero | **4/6 un turno · 5/6 agéntico en 61 min** — no destrona a gemma (6/6). Gana en ts_r (10.2 min vs 18.3) pero pierde excel_r: entrega xlsx sin error con la hoja mal nombrada y el agente se declara exitoso |
| 2026-08-10 | 3060-muse | Muse-Glimmer-30B kquant (Meta, denso 30B multimodal, SWE-bench Verified 76% declarado) | **Descartado sin medir**: 6.2 tok/s (denso) y razonamiento imposible de apagar; con timeout de 1800 s/tarea la suite solo mediría el reloj. Requirió build nuevo de llama.cpp (arquitectura `muse_glimmer`) |
| 2026-08-10 | 3060-nemotron | NVIDIA-Nemotron-3.5-Lightning-30B-A3B Q4_K_M (MoE híbrido Mamba-2, 3B act., GGUF de ggml-org) | **5/6 · 10.1 min** a 47.7 tok/s; pasa los dos filtros. Pasa `excel_r` (que Qwopus falla) y falla `ts_r` de forma insólita: genera y verifica el pronóstico, luego borra el entregable |

## Lecciones acumuladas (no repetir experimentos)

1. Canal único de memoria = cuello de botella; MoE con pocos activos > densos. 10 hilos > 14.
2. Cuantización ≤2 bits y ternarios densos: descartados con evidencia (calidad o velocidad colapsan).
3. Razonamiento/thinking local: inviable a ~10-15 tok/s. Siempre `enable_thinking:false`
   (funciona en plantillas Qwen y Gemma; verificar por modelo con una llamada de humo).
4. El bucle agéntico compensa conocimiento (no velocidad): rescata las tareas de R.
5. Cline en Windows: errores fantasma con stderr de R (PowerShell 5.1); usar Zero para
   agéntico con R. Cline OK para Python.
6. Los blobs GGUF de Ollama no siempre cargan en llama.cpp mainline (metadatos de
   conversión); ante error, bajar el GGUF oficial de unsloth/bartowski.
7. **La iGPU no sirve para trabajo real** (fase 6a): SYCL degrada decode; Vulkan da
   3.6× de prefill en `llama-bench` pero pierde el dispositivo (`ErrorDeviceLost`) con
   prompts de ~2,900 tokens, incluso con lotes reducidos. Solo CPU.
8. **Medir con carga realista no es opcional**: el benchmark sintético habría llevado a
   recomendar Vulkan. Igual que en fase 4, donde ejecutar el código reveló que los
   "fallos" del campeón eran del harness.
9. **Fechas en R es el fallo recurrente universal** (lubridate sin cargar): lo cometieron
   KAT-Coder y gemma-4-26B en la misma tarea. El bucle agéntico lo corrige solo.
10. **Verificar las citas de la investigación externa**: los reportes de Claude y NotebookLM
   atribuyeron mal la evidencia de R de Simon Couch (dijeron Qwen3.5-9B y Gemma 4 E4B;
   el post original prueba los MoE 26B-A4B y 35B-A3B). Leer siempre la fuente primaria.
11. Scripts .ps1: **escribirlos en ASCII puro** — PowerShell 5.1 los lee como ANSI y un
   guión largo se convierte en comilla, rompiendo el parser.
12. **Los resultados y los workdirs se separan por perfil en la ruta, no solo en el JSON**
   (`results/<perfil>/`, `work/<perfil>/`). El 2026-07-28 el `gemma-4-26b-a4b_zero.json`
   de la laptop se perdió al hacer `git pull`: el desktop usó la misma etiqueta con otras
   mayúsculas y Windows, que no distingue mayúsculas, dejó un solo archivo. Se recuperó
   de 4edeb01, igual que los scripts de gemma en `work/`.
13. **El bucle agéntico solo corrige lo que el intérprete reporta como error** (fase 7):
   Qwopus rescató `ts_r` (R abortaba) pero no `excel_r`, donde el script corre limpio y
   entrega un xlsx con la hoja mal nombrada. Un fallo de especificación sin fallo de
   ejecución no se autocorrige: lo atrapa el checker del entregable, no el agente.
14. **Dos filtros que descartan un candidato antes de medirlo**, sin importar sus
   benchmarks declarados: (a) **denso ≥30B** — Muse-Glimmer-30B rinde 6.2 tok/s en la
   3060 contra ~58 de los MoE, y en la laptop sería aún peor; (b) **razonamiento que no
   se puede apagar** — si `--reasoning off` y `reasoning_budget:0` no lo detienen, el
   modelo queda fuera del presupuesto (lección 3). Muse-Glimmer declara 76% en SWE-bench
   Verified y aun así no es candidato: el techo de calidad no sirve si no cabe.

## Próximos candidatos y triggers

- **Investigación en curso**: `DEEPRESEARCH_MODELOS_PEQUENOS.md` es el prompt
  autocontenido para buscar modelos pequeños (≤8 GB en Q4) mejores que Gemma 4 E4B en
  los lanzamientos recientes. Se corre en Claude (investigación profunda) y NotebookLM;
  los candidatos que devuelva entran por el checklist de abajo.
- **gemma-4-26B-A4B** (MoE 26B/3.8B activos): encaja en el patrón "XXB-AYB ≤35B, ≤4B
  activos" — candidato natural a suceder al 30B interactivo. Probar cuando haya tiempo
  de laptop libre (~19 GB de descarga estimada en Q4).
- Segundo módulo DDR5-5600 → re-medir todo (~2× decode esperado).
- Resto de triggers y patrones: ver `QUE_MONITOREAR.md`.

## Cómo probar un modelo nuevo (checklist)

```
# 1. Conseguir GGUF Q4 (unsloth/bartowski) -> D:\ProgramacionLocal\llama_cpp\
# 2. Servidor (thinking off por si acaso):
$env:LLAMA_ARG_CHAT_TEMPLATE_KWARGS='{"enable_thinking":false}'
D:\ProgramacionLocal\llama_cpp\cpu\llama-server.exe -m <gguf> -t 10 -c 32768 --cache-reuse 256 --port 8080 -a local
#    (prioridad BelowNormal para laptop usable)
# 3. Humo: una llamada /v1/chat/completions y revisar reasoning_content vacio
# 4. Suites:
python bench.py <etiqueta> --backend llama          # un turno (~15 min)
python bench_zero.py <etiqueta>                     # agentico Zero (~1-3 h)
python bench_cline.py <etiqueta>                    # agentico Cline (solo Python fiable)
# 5. Autopsia de fallos: ejecutar a mano work\<...>\script.{py,R} para clasificar
#    (modelo vs harness) antes de registrar el veredicto.
# 6. Registrar: fila en la bitacora de este archivo + seccion en RESULTADOS.md
```

## Inventario

- **Modelos en disco**: blobs Ollama (30B campeón, 4b, 7b, 8b) · `llama_cpp\`:
  KAT-Coder IQ4_XS (18.8 GB), Gemma 4 E4B Q4 (5 GB), Qwen3.5-4B Q4 (2.7 GB, prescindible).
- **Runtimes/harnesses**: llama.cpp b10088 (cpu/ y vulkan/), Ollama 0.32.1,
  Cline CLI 3.0.46 (npm), Zero 0.5.0 (npm, proveedor `local-llama` → puerto 8080).
- **Harness de benchmark**: `bench.py`, `bench_cline.py`, `bench_zero.py`,
  `make_data.py`; resultados crudos en `results\<perfil>\*.json`; workdirs en `work\<perfil>\`.
- **Documentos**: `RESULTADOS.md` (informe completo), `QUE_MONITOREAR.md` (radar),
  `PROPUESTA_PONENCIA.md` (evento), reporte visual HTML (Artifact).
