# Script para análisis de serie temporal con ARIMA

# Cargar las librerías necesarias
library(forecast)

# Leer el archivo CSV
data <- read.csv("serie_mensual.csv", header = TRUE, stringsAsFactors = FALSE)

# Convertir la columna fecha a tipo Date
data$fecha <- as.Date(data$fecha)

# Convertir a serie temporal con frecuencia 12 (mensual)
ts_data <- ts(data$valor, start = c(2020, 1), frequency = 12)

# Ajustar modelo ARIMA automático
model <- auto.arima(ts_data)

# Generar pronóstico de 12 meses
forecast_result <- forecast(model, h = 12)

# Crear las fechas para el pronóstico manualmente
last_date <- tail(data$fecha, 1)
forecast_dates <- seq(from = as.Date(paste0(format(last_date, "%Y-%m"), "-01")) + 31, 
                      by = "month", length.out = 12)
# Ajustar las fechas al primer día del mes
forecast_dates <- as.Date(format(forecast_dates, "%Y-%m-01"))

# Crear el dataframe con las fechas y pronósticos
forecast_df <- data.frame(
  fecha = format(forecast_dates, "%Y-%m-%d"),
  pronostico = forecast_result$mean
)

# Guardar el resultado en un archivo CSV
write.csv(forecast_df, "pronostico_r.csv", row.names = FALSE)

# Mostrar información del modelo y el pronóstico
cat("Modelo ARIMA ajustado:\n")
print(model)
cat("\nPrimeras 5 predicciones:\n")
print(head(forecast_result$mean, 5))
cat("\nÚltimas 5 predicciones:\n")
print(tail(forecast_result$mean, 5))