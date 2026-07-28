# Script de pronóstico con ARIMA
# Lee serie_mensual.csv, ajusta auto.arima y genera pronóstico de 12 meses

library(forecast)

# Leer datos
df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
df$fecha <- as.Date(df$fecha)

# Convertir a serie temporal
ts_data <- ts(df$valor, start = c(2020, 1), frequency = 12)

# Ajustar modelo auto.arima
modelo <- auto.arima(ts_data)
print(modelo)

# Generar pronóstico de 12 meses
forecast_result <- forecast(modelo, h = 12)
print(forecast_result)

# Crear data frame de salida
last_date <- df$fecha[nrow(df)]
# Generar fechas para los próximos 12 meses
forecast_dates <- as.Date(paste0(
  rep(2026, 12), "-",
  sprintf("%02d", 1:12), "-",
  "01"
), format = "%Y-%m-%d")

result <- data.frame(
  fecha = forecast_dates,
  pronostico = forecast_result$mean
)

# Guardar resultado
write.csv(result, "pronostico_r.csv", row.names = FALSE)
print("Pronóstico guardado en pronostico_r.csv")
print(result)
