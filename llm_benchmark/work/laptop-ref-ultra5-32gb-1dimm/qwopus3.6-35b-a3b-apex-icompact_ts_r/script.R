library(forecast)

# Leer el archivo CSV
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Convertir la columna de fecha a formato Date
datos$fecha <- as.Date(datos$fecha)

# Crear un objeto ts con frequency=12
serie_ts <- ts(datos$valor, start = c(year(datos$fecha[1]), month(datos$fecha[1])), frequency = 12)

# Ajustar un modelo ARIMA con auto.arima
modelo <- auto.arima(serie_ts)

# Generar un pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Crear un data frame con las fechas de los próximos 12 meses
# Calcular las fechas de los próximos 12 meses
fecha_inicial <- datos$fecha[1]
meses_siguientes <- seq(from = fecha_inicial, by = "month", length.out = 12)

# Formatear las fechas en formato YYYY-MM-DD
fechas_pronostico <- format(meses_siguientes, "%Y-%m-%d")

# Crear el data frame de pronóstico
pronostico_df <- data.frame(
  fecha = fechas_pronostico,
  pronostico = as.numeric(pronostico$mean)
)

# Guardar el data frame en un archivo CSV
write.csv(pronostico_df, "pronostico_r.csv", row.names = FALSE)
