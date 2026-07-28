library(forecast)

# Leer los datos
datos <- read.csv("serie_mensual.csv", header = TRUE)

# Convertir a ts con frecuencia 12
serie_ts <- ts(datos$valor, start = c(2010, 1), frequency = 12)

# Ajustar modelo automático ARIMA
modelo <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Crear dataframe con fechas y pronósticos
ultima_fecha <- tail(datos$fecha, 1)
fecha_inicio <- as.Date(ultima_fecha) + 1
fecha_fin <- fecha_inicio + 11
fechas <- seq(fecha_inicio, fecha_fin, by = "month")
pronostico_valores <- pronostico$mean

# Guardar en archivo CSV
resultado <- data.frame(fecha = format(fechas, "%Y-%m-%d"), pronostico = pronostico_valores)
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)
