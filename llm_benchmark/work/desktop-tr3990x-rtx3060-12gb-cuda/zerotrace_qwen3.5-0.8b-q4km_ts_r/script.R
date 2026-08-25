# Script completo para generar un R script que lee serie_mensual.csv,
# convierta a ts con frequency=12, ajusta con auto.arima (forecast)
# y guarda en pronostico_r.csv

# Importar la serie
# Nota: La serie debe ser lista para leer directamente (sin wrapper en R)
# Usaré read.csv y convertir a vector de fecha
df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE, row.names = FALSE)
df$fecha <- as.Date(df$fecha)

# Convierte a TSV para poder convencer a ts con frequency=12
ts_data <- tapply(df$fecha, df$fecha, FUN = function(x) as.POSIXct(x))

# Aplicar auto.arima para auto-resolvimiento
forecast_result <- forecast(ts_data, auto = "auto", frequency = 12, order = c(0, 0, 1))

# Guardar el resultado
write.csv(forecast_result$predictions, "pronostico_r.csv", row.names = FALSE)

# Verificar si el archivo se creó correctamente
if (!file.exists("pronostico_r.csv")) {
  stop("No se pudo crear pronostico_r.csv. El script no funcionó correctamente.")
}

cat("✓ Script ejecutado correctamente. Archivo pronostico_r.csv creado.\n")
