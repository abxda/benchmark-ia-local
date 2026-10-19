# Script R para forecast ARIMA con serie mensual
# Implementación manual de ARIMA usando funciones base de R

# Leer los datos
df <- read.csv("serie_mensual.csv")

# Convertir fecha a formato Date y ordenar
df$fecha <- as.Date(df$fecha, formats = "%Y-%m-%d")
df <- df[order(df$fecha), ]

# Crear ts con frequency=12 (mensual)
ts_data <- ts(df$valor, frequency = 12)

# Calcular ARIMA(1,1,0) con estacionalidad mensual usando ts::arima()
# Nota: El paquete forecast::arima() no está disponible
model <- ts::arima(ts_data, order = c(1, 1, 0), seasonal = c(1, 1, 0, 12))

# Generar forecast de 12 meses
forecast_result <- forecast(model, n.ahead = 12)

# Extractir fechas y pronósticos
future_dates <- seq(as.Date("2026-01-01"), as.Date("2031-12-31"), by = "month")
predicted_values <- forecast_result$mean

# Crear dataframe de resultado
result <- data.frame(
  fecha = future_dates,
  pronostico = predicted_values
)

# Guardar resultado
write.csv(result, "pronostico_r.csv", row.names = FALSE)

print("Forecast generado y guardado en 'pronostico_r.csv'")
print(head(result))
print(tail(result))
