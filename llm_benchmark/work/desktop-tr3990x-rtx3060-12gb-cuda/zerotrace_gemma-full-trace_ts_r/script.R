library(forecast)

# 1. Leer los datos
df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
df$fecha <- as.Date(df$fecha)

# 2. Convertir a serie temporal (ts)
inicio_fecha <- min(df$fecha)
anio_inicio <- as.numeric(format(inicio_fecha, "%Y"))
mes_inicio <- as.numeric(format(inicio_fecha, "%m"))

serie_ts <- ts(df$valor, start = c(anio_inicio, mes_inicio), frequency = 12)

# 3. Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# 4. Generar pronostico de 12 meses
pronostico <- forecast(modelo, h = 12)

# 5. Preparar fechas de pronóstico
ultima_fecha <- max(df$fecha)
# Generar el primer día del mes siguiente de forma robusta
# Sumamos 1 mes al último día de la serie
fecha_inicio_p <- as.Date(format(ultima_fecha, "%Y-%m-01")) + 32
fecha_inicio_p <- as.Date(format(fecha_inicio_p, "%Y-%m-01"))

meses_seguintes <- seq(fecha_inicio_p, by = "month", length.out = 12)

# 6. Crear dataframe de salida
resultado <- data.frame(
  fecha = format(meses_seguintes, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico$mean)
)

# 7. Guardar en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)
