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

# Extraer fechas para los próximos 12 meses
last_date <- tail(data$fecha, 1)
forecast_dates <- seq(from = as.Date(paste0(format(last_date, "%Y-%m"), "-01")) + 31, 
                      by = "month", length.out = 12)
forecast_dates <- as.Date(format(forecast_dates, "%Y-%m-01"))

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