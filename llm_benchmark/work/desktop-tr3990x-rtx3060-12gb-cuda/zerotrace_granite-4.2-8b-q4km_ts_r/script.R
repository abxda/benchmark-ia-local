library(forecast)
library(lubridate)

# Leer la serie
data <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Extraer la columna 'fecha' y 'valor'
fecha <- as.Date(data$fecha, format = "%Y-%m-%d")
valor <- data$valor

# Crear el objeto ts con frequency=12 (mensual, estacionalidad anual)
start_year <- year(min(fecha))
start_month <- month(min(fecha))
ts_datos <- ts(valor, start = c(start_year, start_month), frequency = 12)

# Ajustar modelo con auto.arima
modelo <- auto.arima(ts_datos)
print(modelo)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12, level = 80)
print(pronostico)

# Generar fechas para los 12 meses siguientes (comenzando el mes siguiente al último mes del dato)
ultima_fecha <- max(fecha)
próxima_fecha <- ultima_fecha + months(1)

# Crear fechas para los próximos 12 meses
fechas_pronostico <- seq(from = próxima_fecha, by = "1 month", length.out = 12)

# pronostico$mean incluye el punto actual (actualizado) como el primer elemento
# pronostico$mean[2:13] corresponde a los próximos 12 meses (incluye el mes actual + siguientes 12)
# pero los siguientes 12 meses son pronostico$mean[2:13] (13 elementos total, el primero es actualizado)
pronostico_csv <- data.frame(
  fecha = as.character(fechas_pronostico, format = "%Y-%m-%d"),
  pronostico = pronostico$mean[2:13]
)

# Guardar el archivo
write.csv(pronostico_csv, "pronostico_r.csv", row.names = FALSE)

# Mostrar el CSV resultante
print(pronostico_csv)