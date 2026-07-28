# Script para pronóstico de series temporales con ARIMA

# Cargar librerías necesarias
library(forecast)

# Leer los datos
data <- read.csv("serie_mensual.csv", header = TRUE)

# Convertir la columna de fecha a tipo Date
data$fecha <- as.Date(data$fecha)

# Crear serie temporal con frecuencia 12 (mensual)
ts_data <- ts(data$valor, start = c(2020, 1), frequency = 12)

# Ajustar modelo ARIMA automático
model <- auto.arima(ts_data)

# Generar pronóstico de 12 meses
forecast_result <- forecast(model, h = 12)

# Crear fechas para los próximos 12 meses (desde enero 2026)
forecast_dates <- seq(from = as.Date("2026-01-01"), by = "month", length.out = 12)

# Crear dataframe con resultados
forecast_df <- data.frame(
  fecha = forecast_dates,
  pronostico = forecast_result$mean
)

# Guardar el pronóstico en un archivo CSV
write.csv(forecast_df, "pronostico_r.csv", row.names = FALSE)

# Mostrar información del modelo y resultados
cat("Modelo ARIMA ajustado:\n")
print(model)
cat("\nPrimeros 5 pronósticos:\n")
print(head(forecast_result$mean))
cat("\nÚltimos 5 pronósticos:\n")
print(tail(forecast_result$mean))