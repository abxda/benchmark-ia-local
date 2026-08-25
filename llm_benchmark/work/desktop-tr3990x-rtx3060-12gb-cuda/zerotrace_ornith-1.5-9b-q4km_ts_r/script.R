#!/usr/bin/env Rscript
# Modelo de pronostico para serie mensual con tendencia y estacionalidad anual
# Lee serie_mensual.csv, ajusta con auto.arima y genera 12 meses de pronostico.

# --- Librerias ---
library(forecast)
# En forecast 9.x auto.arima se aloca en statsforecast
if (!requireNamespace("statsforecast", quietly = TRUE)) {
  install.packages("statsforecast", repos = "https://cloud.r-project.org")
  library(statsforecast)
}

# --- Lecture ---
serie <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# --- Conversion a objeto ts con periodicidad 12 ---
serie_ts <- ts(serie$valor, start = c(2020, 1), frequency = 12)

# --- Ajuste del modelo (auto.arima detecta tendencia + estacionalidad) ---
modelo <- auto.arima(serie_ts)

# --- Pronostico de 12 meses ---
h <- 12
pron <- forecast(modelo, h = h)

# La media puntual es la prediccion media (columna [1,])
pronostico_media <- pron[ , 1]

# --- Fechas de los meses siguientes (YYYY-MM-DD) ---
n <- length(serie_ts)
fecha_ultimo <- as.numeric(format(time(serie_ts)[n], "%Y-%m-%d"))
fechas <- as.Date(fecha_ultimo + seq_len(h) - 1)

# --- Escritura del archivo de salida ---
salida <- data.frame(
  fecha = format(fechas, "%Y-%m-%d"),
  pronostico = pronostico_media
)
write.csv(salida, "pronostico_r.csv", row.names = FALSE)

cat("Modelo ajustado:", class(modelo)[1], "\n")
cat("Pronostico de", h, "meses guardado en 'pronostico_r.csv'\n")
print(salida)
