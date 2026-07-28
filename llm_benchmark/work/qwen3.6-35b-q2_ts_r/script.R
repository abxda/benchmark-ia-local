library(forecast)

# Leer el archivo CSV
datos <- read.csv('serie_mensual.csv', stringsAsFactors = FALSE)

# Convertir la columna de fecha a formato Date
datos$fecha <- as.Date(datos$fecha)

# Crear un objeto ts con frecuencia 12 (mensual)
serie_ts <- ts(datos$valor, start = c(year(datos$fecha[1]), month(datos$fecha[1])), frequency = 12)

# Ajustar el modelo ARIMA usando auto.arima
modelo_arima <- auto.arima(serie_ts)

# Generar el pronóstico para los próximos 12 meses
pronostico <- forecast(modelo_arima, h = 12)

# Crear un data frame con las fechas de los próximos 12 meses
fecha_inicio <- max(datos$fecha)
meses_siguientes <- seq(fecha_inicio + 1, by = "month", length.out = 12)
meses_siguientes <- as.Date(meses_siguientes)

# Guardar el pronóstico en un archivo CSV
resultado <- data.frame(fecha = meses_siguientes, pronostico = pronostico$mean)
write.csv(resultado, 'pronostico_r.csv', row.names = FALSE)
