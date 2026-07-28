library(forecast)
library(dplyr)

# Leer los datos del CSV
datos <- read.csv("serie_mensual.csv")

# Convertir la columna de fecha a clase Date y ordenar por fecha
datos$fecha <- as.Date(datos$fecha, format = "%Y-%m-%d")
datos <- datos[order(datos$fecha), ]

# Crear objeto ts con frequency=12 (anual)
serie_ts <- ts(datos$valor, start = 1900, end = nrow(datos)+1, frequency = 12)

# Ajustar modelo ARIMA usando auto.arima del paquete forecast
modelo_arima <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses (horizon=12)
pronostico_objeto <- forecast(modelo_arima, h = 12)

# Extraer las predicciones puntuales y sus fechas correspondientes
nuevos_valores <- pronostico_objeto$mean
nuevas_fechas <- as.Date(pronostico_objeto$date[1:12], format = "%Y-%m") + months(0:11)

# Crear dataframe para el resultado final con formato YYYY-MM-DD y columna 'pronostico'
resultado_df <- data.frame(fecha = format(nuevas_fechas, "%Y-%m-%d"), 
                           pronostico = round(nuevos_valores, 2))

# Guardar en CSV
write.csv(resultado_df, "pronostico_r.csv", row.names = FALSE)
