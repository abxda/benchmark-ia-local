library(forecast)

# 1. Leer la serie
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 2. Convertir a objeto ts
# La serie empieza en 2020-01-01 con frecuencia 12
serie_ts <- ts(datos$valor, start = c(2020, 1), frequency = 12)

# 3. Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# 4. Generar pronostico de 12 meses
pronostico_obj <- forecast(modelo, h = 12)

# 5. Preparar datos para guardar
# La serie termina en 2025-12-01. El pronóstico debe empezar en 2026-01-01.
fechas_pronostico <- seq(as.Date("2026-01-01"), by = "month", length.out = 12)

# Crear dataframe de salida
df_pronostico <- data.frame(
  fecha = format(fechas_pronostico, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico_obj$mean)
)

# 6. Guardar en CSV
write.csv(df_pronostico, "pronostico_r.csv", row.names = FALSE)
