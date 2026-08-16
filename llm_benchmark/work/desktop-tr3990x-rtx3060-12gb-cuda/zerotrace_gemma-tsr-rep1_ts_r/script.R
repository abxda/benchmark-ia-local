library(forecast)

# 1. Leer los datos
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
datos$fecha <- as.Date(datos$fecha)

# 2. Convertir a objeto ts
start_year <- as.numeric(format(min(datos$fecha), "%Y"))
start_month <- as.numeric(format(min(datos$fecha), "%m"))

serie_ts <- ts(datos$valor, start = c(start_year, start_month), frequency = 12)

# 3. Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# 4. Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# 5. Preparar fechas para el pronóstico
# Usamos la última fecha de los datos y generamos los siguientes 12 meses
ultima_fecha <- max(datos$fecha)

# Creamos una secuencia de fechas empezando desde el mes siguiente
# seq.Date con "month" es fiable en R base
fechas_pronostico <- seq(as.Date(ultima_fecha), by = "month", length.out = 13)[2:13]

# 6. Crear dataframe de salida
df_pronostico <- data.frame(
  fecha = format(fechas_pronostico, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico$mean)
)

# 7. Guardar en CSV
write.csv(df_pronostico, "pronostico_r.csv", row.names = FALSE)
