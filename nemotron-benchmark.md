# NVIDIA Nemotron 3.5 Lightning 30B-A3B en el benchmark de IA local

Evaluación de un modelo de código abierto corriendo **100% local** en una suite de tareas
reales de programación en Python y R, bajo un presupuesto de hardware fijo.

**Repositorio:** <https://github.com/abxda/benchmark-ia-local>
**Commits de esta evaluación:** [`7e1663e`](https://github.com/abxda/benchmark-ia-local/commit/7e1663e) (resultado) · [`a1ac02e`](https://github.com/abxda/benchmark-ia-local/commit/a1ac02e) (autopsia instrumentada)
**Fechas:** 10 y 11 de agosto de 2026

---

## Qué mide el experimento

La pregunta del proyecto es **qué puede hacer alguien que solo dispone de una laptop
institucional sin GPU**, usando modelos abiertos como alternativa a los asistentes
comerciales de programación. Cada corrida se etiqueta con su perfil de hardware para que
mediciones de máquinas distintas nunca se mezclen.

Esta evaluación se hizo en el perfil de exploración, no en el de referencia:

| | |
|---|---|
| **Perfil** | `desktop-tr3990x-rtx3060-12gb-cuda` |
| **CPU / RAM** | AMD Threadripper 3990X (64 núcleos) · 256 GB DDR4 |
| **GPU** | NVIDIA RTX 3060, 12 GB |
| **SO / runtime** | Ubuntu 26.04 · llama.cpp CUDA |
| **Rol** | Explorar y acelerar. **No decide recomendaciones**: eso corresponde al perfil de la laptop de referencia |

### La suite: 6 tareas, 3 dominios × 2 lenguajes

Tareas de la práctica estadística cotidiana, en Python y en R:

1. **Excel** — leer un CSV y generar un `.xlsx` con una hoja y columnas exactas.
2. **Dashboard** — construir un tablero con dos gráficas a partir de los datos.
3. **Series de tiempo** — ajustar un modelo y pronosticar 12 meses.

El código generado **se ejecuta de verdad** y se valida el entregable (totales correctos
por región, archivos válidos, pronóstico dentro de rango plausible). No se evalúa el
texto de la respuesta: se evalúa el archivo producido.

### El contrato de ejecución

Idéntico para todos los modelos, sin excepciones:

- Modo agéntico con **Zero** (`zero exec --auto high`), que permite al modelo escribir,
  ejecutar, revisar y corregir su propio código.
- **Máximo 25 turnos** por tarea y **timeout de 1800 s**.
- **Razonamiento desactivado** (`enable_thinking: false`), verificado con una llamada de
  humo antes de cada corrida.
- Datos sintéticos reproducibles con semilla fija.

> **Regla de integridad del proyecto:** ante un fallo solo se permiten arreglos de
> infraestructura que igualen condiciones para todos. Está prohibido ajustar prompts,
> relajar validadores o repetir hasta que pase. El resultado oficial es **el primero
> medido**, nunca se sustituye por el mejor.

---

## Cómo llegó Nemotron a la mesa

Antes de gastar GPU, cada candidato pasa por una autopsia documental. Dos filtros
descartan un modelo sin medirlo, sin importar los benchmarks que declare:

- **Denso ≥30B** — en hardware limitado por ancho de banda de memoria, los modelos densos
  grandes se arrastran. Un MoE con pocos parámetros activos rinde varias veces más.
- **Razonamiento que no se puede apagar** — a las velocidades locales, el pensamiento
  extenso consume el presupuesto de tiempo completo.

Nemotron pasa ambos: es **MoE con 3B activos** y respeta `enable_thinking`.

### Ficha del modelo

| | |
|---|---|
| **Modelo** | NVIDIA-Nemotron-3.5-Lightning-30B-A3B |
| **Arquitectura** | MoE híbrido: **Mamba-2 + MoE + atención** |
| **Parámetros** | 30B totales / **3B activos** |
| **Cuantización usada** | Q4_K_M — 25.4 GB |
| **Origen del GGUF** | `ggml-org`, la organización que mantiene llama.cpp (soporte de primera mano) |
| **Contexto** | hasta 1M tokens |
| **Licencia** | OpenMDW-1.1 (**no** Apache-2.0) |
| **Publicado** | 11 de agosto de 2026 |

**SWE-bench Verified declarado por NVIDIA:** 51.6 (BF16) / 52.8 (NVFP4), medidos con
arnés propio y recetas publicadas en NeMo Gym. Es una cifra más baja que la de otros
candidatos, pero **más auditable** que los auto-reportes sin arnés especificado.

### Configuración de ejecución

```bash
llama-server -m NVIDIA-Nemotron-3.5-Lightning-30B-A3B-Q4_K_M.gguf \
  --n-gpu-layers 999 --n-cpu-moe 40 \
  -c 32768 --cache-reuse 256 --port 8080 -a local \
  --no-mmap -t 32 --reasoning off
```

- **VRAM ocupada:** 10.4 de 12.3 GB. Con `--n-cpu-moe 34` no cabe (OOM).
- **Velocidad de decodificación:** **47.7 tok/s** — un modelo de 25.4 GB corriendo en una
  tarjeta de 12 GB, gracias al descargue de expertos a los 64 núcleos de CPU.
- **Razonamiento:** verificado apagado (`reasoning_content: None`).

---

## Resultados

### Corrida oficial (10 de agosto) — 5/6 en 10.1 min

| Tarea | Resultado | Tiempo |
|---|---|---|
| Excel · Python | PASS | 68.3 s |
| Excel · R | **PASS** | 100.1 s |
| Dashboard · Python | PASS | 125.9 s |
| Dashboard · R | PASS | 119.8 s |
| Series de tiempo · Python | PASS | 91.6 s |
| Series de tiempo · R | **FAIL** | 103.1 s |
| **Total** | **5/6** | **10.1 min** |

Pasar **Excel en R** no es trivial: es la tarea que históricamente tumba modelos, y otros
candidatos fuertes la fallan entregando un archivo sin errores pero con la hoja mal
nombrada.

El fallo en series de tiempo en R fue **anómalo**: el registro del agente muestra que
escribió el script, lo ejecutó, y leyó de vuelta el CSV con los 12 pronósticos mensuales
correctos. Al terminar, el script y el entregable **habían desaparecido** del directorio
de trabajo, y no estaban en ninguna otra ruta del sistema. Las otras cinco tareas
conservaron sus archivos intactos, así que no era un fallo del arnés.

### Autopsia instrumentada (11 de agosto)

El arnés oficial guarda solo los últimos 1500 caracteres de la salida del agente, y el
formato de texto muestra el *resultado* de cada comando pero no el *comando* en sí — por
eso se perdió la evidencia. Se construyó `bench_zero_trace.py` con el **contrato
idéntico** (mismas tareas, mismo prompt, mismo validador, mismos 25 turnos) y solo
observabilidad añadida:

- `--output-format stream-json`, que incluye los argumentos de cada llamada a herramienta.
- `--init-session-id`, para dejar la sesión persistida y consultable.
- Guarda la salida **completa** de cada tarea.
- Escribe a archivos con sufijo `_zerotrace`, de modo que **no puede pisar un resultado
  oficial**.

#### El borrado no se reprodujo

En **7 corridas instrumentadas**, ninguna traza contiene `rm`, `unlink` ni `file.remove`,
y el entregable sobrevivió siempre. El episodio original queda **sin explicación
confirmada**.

#### Series de tiempo en R sí es inestable

| Corrida | Resultado | Tiempo |
|---|---|---|
| Suite oficial | FAIL — entregable generado y desaparecido | 103.1 s |
| Aislada 1 | PASS | 78.6 s |
| Aislada 2 | FAIL — pronóstico con NaN | 279.9 s |
| Aisladas 3–6 | PASS ×4 | 81.7 – 103.2 s |
| Suite completa trazada | PASS | 127.0 s |
| **Total** | **6 PASS / 2 FAIL — 75%** | |

El fallo capturado sí tiene diagnóstico. El agente abandonó el archivo `script.R` y se
puso a improvisar líneas sueltas con `Rscript -e`, hasta que el escapado del shell
convirtió `datos$valor` en `datos\$valor` y rompió el código. Catorce comandos, 280
segundos —el triple de lo normal— y un CSV lleno de NaN. **No es desconocimiento de R:
es un bucle de recuperación sin método.**

#### Suite completa con traza — 6/6 en 9.8 min

| Tarea | Resultado | Tiempo |
|---|---|---|
| Excel · Python | PASS | 62.8 s |
| Excel · R | PASS | 107.2 s |
| Dashboard · Python | PASS | 98.6 s |
| Dashboard · R | PASS | 94.7 s |
| Series de tiempo · Python | PASS | 95.3 s |
| Series de tiempo · R | PASS | 127.0 s |
| **Total** | **6/6** | **9.8 min** |

---

## Hallazgos

**1. Nemotron es un candidato sólido en este hardware.** Resuelve las seis tareas en
menos de diez minutos a 47.7 tok/s, con un modelo de 25.4 GB en una tarjeta de 12 GB. La
arquitectura MoE de 3B activos es lo que lo hace viable: el tamaño total importa para la
memoria, pero el costo por token lo fija la fracción activa.

**2. Pasa Excel en R**, la tarea que separa a los modelos capaces en ese lenguaje.

**3. Su punto débil no es el conocimiento, es la recuperación.** Cuando algo falla,
abandona el archivo y improvisa en la línea de comandos, donde el escapado del shell lo
traiciona. Un modelo que se mantiene disciplinado escribiendo y reejecutando el script
falla menos.

**4. El marcador de una sola corrida tiene ruido.** El mismo modelo, en la misma máquina
y con la misma configuración, dio **5/6 y 6/6 en dos corridas distintas**. La tarea en
disputa se midió ocho veces y pasó el 75%. Esto obliga a leer con cautela cualquier
veredicto basado en una tarea de diferencia — y es la lección más transferible de esta
evaluación.

---

## Limitaciones y advertencias de método

- **El resultado oficial es 5/6**, el primero medido. El 6/6 posterior se reporta como
  diagnóstico, no lo sustituye. Elegir el mejor de varias corridas sería contaminar el
  benchmark.
- **La corrida usa una versión más reciente de llama.cpp** que la de otras mediciones del
  proyecto, porque la arquitectura de este modelo no existe en la anterior. La calidad es
  comparable; los tiempos, no del todo.
- **Este perfil no decide nada.** La recomendación final del proyecto sale siempre de la
  laptop de referencia sin GPU. Nemotron aún no ha sido evaluado ahí.
- **El borrado del entregable sigue sin explicación.** Se reporta como observado y no
  reproducido, sin atribuirle una causa.
- **La licencia OpenMDW-1.1 no es Apache-2.0.** Si el modelo llegara a una recomendación
  institucional, conviene revisarla con detenimiento.

---

## Reproducir

```bash
git clone https://github.com/abxda/benchmark-ia-local
cd benchmark-ia-local/llm_benchmark
python make_data.py                                  # datos sintéticos, semilla fija

# Servidor local (thinking off) y suite agéntica
../linux/servidor.sh <ruta.gguf> <n_cpu_moe> <hilos>
python bench_zero.py <etiqueta>                      # oficial
python bench_zero_trace.py <etiqueta> [tarea...]     # instrumentado, con traza completa
```

Los resultados crudos quedan en `results/<perfil>/`, y el código que escribió el modelo
en cada intento, en `work/<perfil>/` — es la evidencia de calidad y se conserva
versionada.
