# script.R
# Leer serie_mensual.csv
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Asegurarse de que las columnas estén en los tipos correctos
datos$fecha <- as.Date(datos$fecha)
datos$valor <- as.numeric(datos$valor)

# Ordenar por fecha (por si estuviera desordenada)
datos <- datos[order(datos$fecha), ]

# Crear ts con frequency = 12 (12 meses por año)
fecha_primero <- min(datos$fecha)
start_year <- as.integer(substr(format(fecha_primero, "%Y"), 1, 4))
ts_datos <- ts(datos$valor, start = c(start_year, 1), frequency = 12)

# Ajustar modelo con auto.arima
library(forecast)
modelo <- auto.arima(ts_datos)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Obtener las fechas para los 12 meses siguientes
fecha_ultimo <- max(datos$fecha)  # "2025-12-01"
year_ultimo <- as.integer(substr(format(fecha_ultimo, "%Y"), 1, 4))
month_ultimo <- as.integer(substr(format(fecha_ultimo, "%m"), 1, 2))
if (month_ultimo == 12) {
  start_pron <- as.Date(paste(year_ultimo + 1, "01", "01"))
} else {
  start_pron <- as.Date(paste(year_ultimo, month_ultimo + 1, "01"))
}
pronostico_fechas <- seq(start = start_pron, by = "1 month", length.out = 12)

# La media puntual del pronóstico está en pronostico$mean para los h puntos
pronostico_valores <- pronostico$mean[1:12]

# Guardar pronostico_r.csv con columnas 'fecha' y 'pronostico'
pronostico_df <- data.frame(
  fecha = pronostico_fechas,
  pronostico = pronostico_valores
)
write.csv(pronostico_df, "pronostico_r.csv", row.names = FALSE, quote = FALSE)

# Mostrar resumen
print(modelo)
print(head(pronostico_df))
