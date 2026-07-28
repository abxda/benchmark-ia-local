# 🛰 AI Radar

**Alertas en español de lanzamientos de modelos de IA** — europeos, chinos, americanos, open y closed weights. Detecta, verifica, clasifica y distribuye, casi gratis de operar.

Una herramienta de A2 Big Data · abxda × Fable.

---

## Qué es

AI Radar vigila continuamente las fuentes donde los lanzamientos de modelos de IA aparecen primero, descarta el ruido y la especulación, y entrega solo lo confirmado — en español, con contexto, y por el canal que cada quien prefiera (landing web, Telegram, RSS, boletín por correo, X).

No es un agregador de noticias ni un scraper de redes sociales: es un **harness de detección + verificación** que antepone la confianza de cada alerta a la velocidad de publicarla.

---

## La estrategia de búsqueda y validación

El corazón del sistema es un pipeline de **dos pasadas independientes** — un cazador y un verificador que no confían ciegamente el uno en el otro.

```
┌──────────────┐    ┌───────────────┐    ┌──────────────────┐    ┌─────────────┐
│   DETECTAR   │───▶│   CLASIFICAR  │───▶│     VERIFICAR     │───▶│  PUBLICAR   │
│ (multi-fuente)│    │ (1er analista)│    │ (evidencia + 2º)  │    │ (5 canales) │
└──────────────┘    └───────────────┘    └──────────────────┘    └─────────────┘
```

### 1. Detectar — barrido multi-fuente, no un solo canal

Ninguna fuente por sí sola es confiable ni completa, así que el radar escucha varias en paralelo, cada una con su propia naturaleza de señal:

- **Catálogos oficiales** (OpenRouter, Hugging Face) — la señal más limpia: fecha de alta verificable, sin opinión de por medio. Aquí un "nuevo" casi siempre es nuevo de verdad.
- **Hacker News** (vía su API de búsqueda) — buena para contexto y repercusión, pero mezcla anuncios reales con discusiones, retrospectivas y republicaciones de historias viejas.
- **Comunidades de Reddit** (r/LocalLLaMA, r/MachineLearning, r/StableDiffusion, r/singularity) — llegan rápido, pero con la mayor proporción de ruido y especulación de todas las fuentes.

Cada fuente pasa primero por un **filtro barato de palabras clave** (release, launch, weights, benchmark, announce...) antes de gastar una sola llamada a un modelo de lenguaje — el descarte grosero es gratis, la inteligencia se reserva para lo que ya parece prometedor.

### 2. Clasificar — el primer analista, con memoria de que puede fallar

Un modelo de lenguaje lee cada hallazgo y decide: ¿es relevante?, ¿de qué origen?, ¿pesos abiertos o cerrados?, ¿qué tan importante es (0-100)? Redacta también el resumen en español y el borrador del tuit.

Este analista conoce su propia limitación estructural: su entrenamiento tiene una fecha de corte, y no puede saber por sí mismo si algo "nuevo" en realidad ya se anunció hace meses. Por eso se le da la fecha de hoy explícitamente y la instrucción de sospechar de la recirculación — pero un modelo de lenguaje solo, sin acceso al mundo, tiene un techo real ahí. De ahí la necesidad del segundo paso.

### 3. Verificar — la pasada que busca evidencia externa antes de confiar

Esta es la pieza que distingue al radar de un simple resumidor de RSS: **antes de publicar, se busca el hallazgo en la web** (DuckDuckGo, sin necesidad de llave de API) y un segundo modelo — independiente del primero — juzga con esa evidencia en la mano, no con su propia memoria:

- **Anti-recirculación**: si la evidencia deja ver que el anuncio original es de hace semanas o meses, se rechaza — sin importar qué tan convincente sonara el primer análisis. Este es el mecanismo que corrigió el caso real donde el sistema estuvo a punto de anunciar como "novedad" un modelo que ya llevaba tiempo en el mercado: la fuente (una discusión reciente en un foro) hablaba de él en presente, pero la búsqueda reveló la fecha real de lanzamiento.
- **Anti-rumor**: si el hallazgo viene de una fuente opinión-first (foro, discusión) y la búsqueda no arroja evidencia independiente que lo respalde, tampoco se publica.
- **Anti-alucinación en la referencia**: cuando el verificador decide citar una fuente adicional de respaldo, esa URL se contrasta contra los resultados reales de la búsqueda — si no aparece ahí textualmente, se descarta. El sistema nunca puede inventarse una cita.
- **Enriquecimiento, no solo filtro**: cuando la evidencia confirma el hallazgo, el verificador reescribe el resumen incorporando los datos concretos que encontró (empresa detrás del modelo, arquitectura, cifras de benchmark) — la verificación no es un simple sí/no, también mejora la calidad de lo que se publica.

La regla de fondo: **ningún paso individual del pipeline es la autoridad final**. El detector puede traer ruido, el primer analista puede errar por desconocimiento del presente, y solo lo que sobrevive el contraste contra evidencia externa llega a publicarse.

### 4. Publicar — un mensaje, adaptado a cada canal

Solo entonces la alerta ya verificada se distribuye — landing web, Telegram, RSS, boletín por correo (redactado con su propio criterio editorial, aparte del harness de detección) y X — cada uno con el nivel de detalle y de costo que le corresponde.

---

## Por qué esta estrategia y no otra

- **Velocidad vs. confianza**: publicar instantáneamente cada mención de un modelo sería más rápido pero, sin la segunda pasada, indistinguible de un agregador ruidoso. El costo de un segundo análisis (segundos, centavos) es bajo comparado con el costo reputacional de una alerta falsa.
- **Dos modelos, no uno reforzado**: pedirle al mismo analista que "revise su propio trabajo" no corrige el problema de fondo — sigue sin tener acceso a información posterior a su entrenamiento. Separar detección de verificación, y dar al verificador evidencia real de búsqueda, ataca la causa, no el síntoma.
- **Fail-open, no fail-closed**: si DuckDuckGo no responde o el verificador no está disponible, el sistema no se detiene — deja pasar la alerta del primer análisis en vez de silenciar el radar entero. La verificación mejora la calidad; su ausencia no debe paralizar el servicio.
