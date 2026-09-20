# Script R para pronóstico mensual usando auto.arima
# Lee serie_mensual.csv (columnas: fecha, valor; 72 meses de serie con tendencia y estacionalidad anual)
# Convierte a ts con frequency=12
# Ajusta modelo con auto.arima del paquete forecast
# Genera pronóstico de 12 meses con forecast()
# Guarda en pronostico_r.csv con columnas 'fecha' (meses siguientes en formato YYYY-MM-DD) y 'pronostico' (media puntual)

# Cargar paquetes
library(forecast)

# Leer el CSV
data <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Extraer columnas
fecha_raw <- data$fecha
valor <- data$valor

# Convertir fecha a Date
fecha <- as.Date(fecha_raw, format = "%Y-%m-%d")

# Extraer la serie de valores (debe ser numérica)
valor_num <- as.numeric(valor)

# Convertir a ts con frequency=12
# Calcular start: año y mes del primer punto usando funciones base
first_date <- min(fecha)
start_year <- as.integer(format(first_date, "%Y"))
start_month <- as.integer(format(first_date, "%m"))
ts_obj <- ts(valor_num, start = c(start_year, start_month), frequency = 12)

# Mostrar info
print(paste("Serie ts:", start(ts_obj), ":", end(ts_obj), "frequency:", frequency(ts_obj)))

# Ajustar modelo con auto.arima
model <- auto.arima(ts_obj)
print(paste("Modelo ajustado:", model$model))

# Generar pronóstico de 12 meses
pronostico <- forecast(model, h = 12)

# Obtener la media puntual (forecast$mean)
pronostico_valores <- pronostico$mean

# Generar fechas para los 12 meses siguientes (desde el mes siguiente al último)
last_date <- end(ts_obj)[1]  # Date del último punto
last_year <- as.integer(format(last_date, "%Y"))
last_month <- as.integer(format(last_date, "%m"))

if (last_month == 12) {
  # El último mes es diciembre, el siguiente mes es enero del año siguiente
  next_year <- last_year + 1
  first_next_month <- 1
} else {
  # El siguiente mes es el mes siguiente del mismo año
  next_year <- last_year
  first_next_month <- last_month + 1
}

# Generar fechas desde el mes siguiente
prxima_date <- as.Date(paste(next_year, first_next_month, "01"))
fechas_pronostico <- seq(from = prxima_date, by = "1 month", length.out = 12)

# Verificar longitudes
if (length(fechas_pronostico) != length(pronostico_valores)) {
  stop("Error: longitud de fechas y pronóstico no coinciden")
}

# Guardar resultado en pronostico_r.csv
resultado <- data.frame(fecha = format(fechas_pronostico, "%Y-%m-%d"), pronostico = pronostico_valores, stringsAsFactors = FALSE)
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# Mostrar archivo resultante
print("pronostico_r.csv generado:")
print(print(resultado))
