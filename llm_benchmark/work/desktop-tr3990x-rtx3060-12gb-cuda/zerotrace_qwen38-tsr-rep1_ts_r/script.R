# -*- coding: utf-8 -*-
# script.R
# Lee serie_mensual.csv (columnas: fecha, valor), convierte a ts (frequency=12),
# ajusta un ARIMA con auto.arima del paquete forecast, genera un pronostico de
# 12 meses y lo guarda en pronostico_r.csv (columnas: fecha, pronostico).

# ---------------------------------------------------------------------------
# Cargar datos
# ---------------------------------------------------------------------------
df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
stopifnot(all(c("fecha", "valor") %in% names(df)))

# ---------------------------------------------------------------------------
# Convertir a serie temporal mensual (frequency = 12)
# ---------------------------------------------------------------------------
serie <- ts(df$valor, frequency = 12, start = as.integer(substr(df$fecha[1], 1, 4)))

# ---------------------------------------------------------------------------
# Ajustar modelo con auto.arima (selección automática por AIC)
# ---------------------------------------------------------------------------
library(forecast)
modelo <- auto.arima(serie)

# ---------------------------------------------------------------------------
# Pronostico de 12 meses: media puntual
# ---------------------------------------------------------------------------
pron <- forecast(modelo, h = 12)
pred <- as.data.frame(pron)   # columnas: point, lower, upper
pred$pronostico <- pred$`Point Forecast`

# ---------------------------------------------------------------------------
# Fechas de los meses siguientes a la serie (primero de cada mes) en YYYY-MM-DD
# ---------------------------------------------------------------------------
last_date <- as.Date(as.character(df$fecha[n_obs]))
n_obs <- length(df$fecha)
start_next <- last_date + 1
next_months <- as.Date(seq(start_next, by = "month", length.out = 12))
pred$fecha <- format(next_months, "%Y-%m-%d")

# ---------------------------------------------------------------------------
# Guardar resultado con las columnas pedidas (fecha, pronostico)
# ---------------------------------------------------------------------------
write.csv(pred[, c("fecha", "pronostico")], "pronostico_r.csv", row.names = FALSE)

cat("Modelo:", capture.output(summary(modelo))[[1]], "\n")
cat("Pronostico de 12 meses generado en pronostico_r.csv\n")
