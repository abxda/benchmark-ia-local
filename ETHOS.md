# El ethos: la restricción es el experimento

Este documento existe porque el proyecto va a correrse en máquinas más potentes, y ese es exactamente el momento en que un trabajo así se echa a perder. Léelo antes de agregar una máquina nueva.

---

## El principio

**El sujeto de estudio no es el modelo: es el modelo dentro de un presupuesto de hardware que no se puede ampliar.**

La pregunta que este repo responde no es "¿cuál es el mejor modelo abierto?" — esa ya la contestan cien leaderboards, y siempre gana el más grande. La pregunta es:

> ¿Qué puede hacer alguien que tiene la computadora que le tocó, sin presupuesto para otra, sin GPU, sin permiso de subir sus datos a una nube?

Esa persona es la mayoría. En una oficina pública, en una universidad, en un despacho pequeño, la laptop institucional **es** el techo. Un benchmark que solo mide modelos de 70B en una A100 no le dice nada, y peor: le dice implícitamente que su pregunta no importa.

La restricción no es una limitación del experimento. Es su objeto.

---

## Por qué esto se rompe solo al escalar

Cuando el mismo protocolo corra en una máquina con GPU dedicada, tres cosas van a pasar sin que nadie las decida:

1. **Todo pasa.** Modelos que aquí son inviables van a resolver las 6 tareas. La suite deja de discriminar y el resultado se vuelve "todos son buenos", que es información nula.
2. **Las conclusiones se contaminan.** "MoE con pocos activos le gana a los densos" es verdad *en canal único de memoria*. Con ancho de banda de sobra, deja de serlo. Si las mediciones de ambas máquinas viven en la misma tabla sin distinguirse, la lección se borra.
3. **El criterio se corre hacia arriba.** Al probar un 70B que anda bien, el listón mental sube y los modelos de 4B empiezan a parecer juguetes — justo los que le sirven a quien motivó el proyecto.

Ninguna de las tres es mala fe. Son la deriva natural de tener más recursos.

---

## Las reglas que lo evitan

### 1. Todo resultado lleva su perfil de hardware

Ninguna medición significa nada sin la máquina en que se tomó. Por eso `bench.py` graba el perfil dentro de cada JSON:

```bash
BENCH_PROFILE=workstation-rtx4090-64gb python bench.py <modelo>
```

**Perfil de referencia — el que define el proyecto:**

| | |
|---|---|
| `laptop-ref-ultra5-32gb-1dimm` | Intel Core Ultra 5 225H · 32 GB DDR5 **canal único** · sin GPU dedicada · Windows 11 · llama.cpp solo CPU |

Un perfil nuevo **agrega** una columna o una sección. Nunca reemplaza a este ni reescribe sus conclusiones.

### 2. La máquina modesta es la que decide la recomendación

Las máquinas potentes sirven para **explicar** (aislar si un fallo fue de capacidad o de recursos), para **explorar** (ver qué existe arriba del techo) y para **acelerar** el desarrollo del harness. No para recomendar.

La recomendación del repo — qué modelo usar — sale siempre del perfil de referencia. Si un modelo brilla en la workstation y no cabe en la laptop, el hallazgo se registra y la recomendación no cambia.

### 3. Cada conclusión declara su alcance

Al escribir un resultado, distinguir siempre entre:

- **Propiedad del modelo** — "falla las fechas en R si no carga lubridate". Viaja a cualquier máquina.
- **Interacción con el hardware** — "el MoE de 3.3B activos supera al denso de 7B". Vale solo en su perfil.

Cuando haya duda, es del hardware. La mayoría de las sorpresas de este proyecto lo fueron.

### 4. El techo se mueve por evidencia, no por comodidad

El techo actual es **≤20 GB en Q4** y **≤4B parámetros activos**, y no salió de una preferencia: salió de medir que un denso de 7B da 7.4 tok/s en esta máquina. Se puede subir el día que la máquina de referencia cambie — y ese día se documenta el cambio y se re-mide todo. No se sube porque el modelo nuevo es interesante.

---

## Cómo agregar una máquina sin perder el hilo

1. Definir el perfil y usarlo en `BENCH_PROFILE` desde la primera corrida.
2. Correr la suite completa con **el campeón actual** antes que nada. Sin ese ancla no hay forma de saber cuánto de una mejora es del modelo y cuánto de la máquina.
3. Registrar los resultados como sección nueva en `llm_benchmark/RESULTADOS.md`, encabezada por el perfil.
4. Al concluir, contestar explícitamente: **¿esto cambia algo para quien solo tiene la laptop?** Si la respuesta es no, la conclusión es interesante pero no es del proyecto.

---

## La prueba de que el ethos sigue vivo

Una sola pregunta, aplicable en cualquier momento:

> **¿Sigue habiendo una recomendación clara y medida para alguien con 32 GB de RAM y sin GPU?**

Mientras la respuesta sea sí, el proyecto está bien, no importa cuántas máquinas se hayan sumado. El día que la respuesta sea "depende, ¿qué tarjeta tienes?", el proyecto se volvió otro leaderboard más.
