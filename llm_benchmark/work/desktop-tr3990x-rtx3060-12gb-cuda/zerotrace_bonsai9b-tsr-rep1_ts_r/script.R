# Script para analizar serie mensual, ajustar ARIMA y hacer pronóstico
# Columnas: fecha, valor (72 meses de serie con tendencia y estacionalidad anual)

# Leer datos
df <- read.csv("serie_mensual.csv")

# Convertir fecha a formato Date
df$fecha <- as.Date(df$fecha)

# Ordenar por fecha
df <- df[order(df$fecha), ]

# Convertir a ts con frecuencia 12 (mensual con estacionalidad anual)
ts_series <- ts(df$valor, frequency = 12, start = as.Date("2020-01-01"), end = as.Date("2025-12-01"))

# Usar ARIMA con parámetros de orden y estacionalidad separados
model <- arima(ts_series, order = c(1, 1, 1), seasonal = c(1, 1, 1))

# Hacer pronóstico de 12 meses
forecast_result <- forecast(model, n ahead = 12)

# Extraer fechas pronostico y pronóstico
forecast_dates <- format(forecast_result$time, "%Y-%m-%d")
forecast_values <- forecast_result$mean

# Crear dataframe de resultado
resultado <- data.frame(
  fecha = forecast_dates,
  pronostico = forecast_values
)

# Guardar en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

print("Proceso completado. Salida: pronostico_r.csv")
print(head(resultado))
print(model)
