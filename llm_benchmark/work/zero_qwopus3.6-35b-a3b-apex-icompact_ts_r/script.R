# Script de pronóstico ARIMA para serie mensual
library(forecast)

# Leer datos
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
datos$fecha <- as.Date(datos$fecha)

# Convertir a ts con frequency=12
serie_ts <- ts(datos$valor, start = c(2020, 1), frequency = 12)

# Ajustar modelo con auto.arima
modelo <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Generar fechas de pronóstico (12 meses siguientes a la última observación)
# La última fecha es 2025-12-01, los próximos 12 meses son de 2026-01 a 2026-12
fechas_pred <- seq(from = as.Date("2026-01-01"), by = "month", length.out = 12)

# Crear dataframe de salida con columnas 'fecha' y 'pronostico'
resultado <- data.frame(
  fecha = format(fechas_pred, "%Y-%m-%d"),
  pronostico = pronostico$mean
)

# Guardar resultado en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

cat("Pronóstico guardado en pronostico_r.csv\n")
cat(paste("Modelo:", modelo$call, "\n"))
print(pronostico)
