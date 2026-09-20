library(forecast)

# Leer el CSV
data <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Asegurarse de que fecha sea Date
data$fecha <- as.Date(data$fecha, format = "%Y-%m-%d")
data$valor <- as.numeric(data$valor)

# Ordenar por fecha si no está ordenado
data <- data[order(data$fecha), ]

# Extraer solo los valores
y <- data$valor

# Convertir a ts con frequency=12 (mensual con estacionalidad anual)
min_fecha <- min(data$fecha)
max_fecha <- max(data$fecha)
start_year <- as.integer(format(min_fecha, "%Y"))
start_month <- 1  # los datos comienzan en enero
ts_obj <- ts(y, start = c(start_year, start_month), frequency = 12)

# Ajustar auto.arima
fit <- auto.arima(ts_obj)

# Generar pronóstico de 12 meses
forecast_obj <- forecast(fit, h = 12)

# Extraer la media puntual del pronóstico (exactly 12 values)
pronostico <- forecast_obj$mean

# Generar las fechas para los próximos 12 meses a partir del mes siguiente al último mes en los datos
ultimo_mes <- max(data$fecha)  # Data.Date object
year_last <- as.integer(format(ultimo_mes, "%Y"))

# Mes siguiente al último mes es siempre 01 del año siguiente (si último es diciembre)
pronostico_fechas <- seq.Date(
  as.Date(sprintf("%d-01-01", year_last + 1)),  # 2026-01-01
  as.Date(sprintf("%d-01-01", year_last + 2)), # 2027-01-01 (inclusive)
  by = "month"
)
# pronostico_fechas tiene 13 elementos (de 2026-01-01 hasta 2027-01-01 inclusive)
# Pero pronostico tiene solo 12 elementos (h=12), así que tomamos los primeros 12
pronostico_fechas <- pronostico_fechas[1:12]

# Guardar en CSV con columnas 'fecha' y 'pronostico'
pronostico_df <- data.frame(
  fecha = pronostico_fechas,
  pronostico = pronostico
)
write.csv(pronostico_df, "pronostico_r.csv", row.names = FALSE)

# Mostrar información
print(paste("Última fecha de datos:", max(data$fecha)))
print(paste("Primeras 3 fechas de pronóstico:", pronostico_fechas[1:3]))
print(paste("Primeras 3 pronósticos:", pronostico[1:3]))
cat("\nDatos de pronóstico guardados en 'pronostico_r.csv'\n")
