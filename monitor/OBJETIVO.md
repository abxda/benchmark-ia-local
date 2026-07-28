# Objetivo del monitoreo

Contexto que el clasificador y el verificador deben tener presente al puntuar. Define **qué experimento alimenta este radar** y, por lo tanto, qué modelo importa.

---

## El experimento

Evaluación empírica y reproducible de **modelos de lenguaje abiertos corriendo localmente en una laptop institucional** (Intel Core Ultra 5 225H, 32 GB DDR5 en canal único, sin GPU dedicada, Windows 11), aplicados a tareas reales de práctica estadística en **Python y R**: automatización de Excel, dashboards y series de tiempo.

La pregunta que el experimento responde: **¿puede un modelo abierto en hardware de oficina sustituir a un asistente de programación comercial, sin licencias y sin que los datos salgan del equipo?**

El radar existe para detectar el modelo que mejore ese resultado. No para cubrir la actualidad de la IA.

---

## El modelo que buscamos

Un **modelo pequeño especializado en código que corra en esa laptop**. Los umbrales vienen de medición propia, no de preferencia:

| Eje | Lo que buscamos |
|---|---|
| **Tamaño** | ≤20 GB en Q4 (≈ ≤35B totales). Es lo que deja RAM libre para IDE, R y Python. |
| **Arquitectura** | MoE con ≤4B parámetros activos. En canal único, los densos ≥14B son inviables (7B denso = 7.4 tok/s). La firma en el nombre es el patrón `XXB-AYB`. |
| **Especialización** | Coder / instruct **no-pensante**. A ~14 tok/s, razonar cuesta 8-15 min por tarea simple. |
| **Formato** | GGUF Q4 nativo, cargable en llama.cpp mainline u Ollama desde el día 1. Nada de forks ni de cuantización ≤2 bits. |
| **Evidencia** | Calidad comparable o mejor al campeón actual bajo el mismo scaffold, o señal de capacidad agéntica (itera y se autocorrige). |

**El diferenciador que más pesa: R.** Todos los modelos probados fallan en R. Cualquier evidencia seria de un modelo local competente en R justifica la prueba, aunque no sea "coder" de nombre y aunque en Python solo empate.

Detalle completo de umbrales, pistas de reconocimiento y triggers en `llm_benchmark/QUE_MONITOREAR.md`.

---

## Cómo se traduce a prioridad

El score responde **"¿esto cambiaría la recomendación del benchmark?"**, no "¿esto es frontera de la IA?".

- **Alto**: modelo pequeño, abierto, orientado a código, ejecutable localmente en el perfil de arriba.
- **Medio**: modelo abierto pequeño de propósito general que podría servir para código, o herramienta de runtime local (llama.cpp, cuantización, soporte de iGPU) que cambie qué es ejecutable.
- **Bajo**: modelo de frontera cerrado o cualquier modelo que no quepa en la laptop. Se registra como contexto, no como hallazgo accionable.

Un modelo de frontera vía API es exactamente lo que este trabajo busca sustituir. Es el punto de comparación, no el objetivo.
