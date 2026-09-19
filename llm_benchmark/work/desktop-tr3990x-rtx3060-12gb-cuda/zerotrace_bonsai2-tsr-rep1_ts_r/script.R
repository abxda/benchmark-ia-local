# -*- coding: utf-8 -*-
# Script de pronostico con auto.arima (paquete forecast)
suppressMessages(library(lubridate))
suppressMessages(library(forecast))
suppressMessages(library(zoo))

# 1) Leer los datos mensuales
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 2) Convertir a ts con frequency = 12 (serie mensual)
#    start usa (año, mes) de la primera observación.
fechas <- as.Date(datos$fecha)
serie <- ts(datos$valor, start = c(as.integer(year(fechas)[1]), as.integer(month(fechas)[1])), frequency = 12)
stopifnot(all.equal(length(serie), nrow(datos)))

# 3) Ajustar el modelo con auto.arima
modelo <- auto.arima(serie)
cat("Modelo auto.arima:\n")
print(modelo)
cat("AIC:", AIC(modelo), "\n")

# 4) Pronostico de 12 meses
prono <- forecast(modelo, h = 12)

# 5) Arma un data.frame con las fechas pronosticadas (YYYY-MM-DD)
#    y la media puntual del pronostico.
#    prono$mean es una serie ts; zoo::asDate la convierte a Date usando el
#    atributo start.
fechas_prono <- zoo::as.Date(prono$mean)
df_prono <- data.frame(
  fecha = format(fechas_prono, "%Y-%m-%d"),
  pronostico = as.numeric(prono$mean)
)

# 6) Guarda en pronostico_r.csv
write.csv(df_prono, "pronostico_r.csv", row.names = FALSE, quote = FALSE)

# Verificacion
cat("\nPronostico de 12 meses:\n")
print(df_prono)
cat("\nArchivo pronostico_r.csv guardado.\n")
