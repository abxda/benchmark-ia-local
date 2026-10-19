# Script de R para análisis y pronóstico de serie temporal

# Leer los datos
datos <- read.csv("serie_mensual.csv")

# Convertir fecha a DATE
datos$fecha <- as.Date(datos$fecha)

# Crear objeto ts con frecuencia mensual (12 meses)
ts_series <- ts(datos$valor, frequency = 12, start = min(datos$fecha), end = max(datos$fecha))

# Agregar modelo ARIMA usando forecast
model <- auto.arima(ts_series)

# Generar pronóstico de 12 meses futuros
pronostico <- forecast(model, h = 12)

# Crear DataFrame de resultado
resultado <- data.frame(
  fecha = as.Date(seq(min(datos$fecha), by = "month", length.out = 12 + max(datos$fecha)))),
  pronostico = predict(model, h = 12, level = "mean")
)

# Reorganizar fechas
resultado$fecha <- as.Date(resultado$fecha)
resultado$pronostico <- as.numeric(resultado$pronostico)

# Guardar en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

cat("Pronóstico generado y guardado en pronostico_r.csv\n")
