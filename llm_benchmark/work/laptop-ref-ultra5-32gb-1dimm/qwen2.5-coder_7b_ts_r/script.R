library(forecast)

# Leer la serie de tiempo desde el archivo CSV
datos <- read.csv('serie_mensual.csv')

# Convertir la columna 'fecha' a formato Date
datos$fecha <- as.Date(datos$fecha, format = "%Y-%m")

# Crear una serie temporal con frecuencia anual (12 meses)
ts_serie <- ts(datos$valor, start = year(min(datos$fecha)), frequency = 12)

# Ajustar el modelo ARIMA usando auto.arima
modelo_arima <- auto.arima(ts_serie)

# Generar un pronóstico de 12 meses
pronostico <- forecast(modelo_arima, h = 12)

# Crear un dataframe con las fechas y los valores del pronóstico
fechas_pronostico <- seq(max(datos$fecha), by = "month", length.out = 12)
valores_pronostico <- as.numeric(pronostico$mean)
pronostico_df <- data.frame(fecha = fechas_pronostico, pronostico = valores_pronostico)

# Formatear las fechas en el formato YYYY-MM-DD
pronostico_df$fecha <- format(pronostico_df$fecha, "%Y-%m")

# Guardar el pronóstico en un archivo CSV
write.csv(pronostico_df, 'pronostico_r.csv', row.names = FALSE)
