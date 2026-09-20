# Cargar paquetes
library(forecast)

# Leer el archivo
data <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Extraer columnas
fecha <- data$fecha
valor <- data$valor

# Convertir fecha a Date y valor a numeric
fecha <- as.Date(fecha)
valor <- as.numeric(valor)

# Convertir a ts con frequency = 12 (12 meses por año)
# start debe ser c(year, month) del primer mes
start_year <- as.integer(substr(min(fecha), 1, 4))
start_month <- as.integer(substr(min(fecha), 6, 7))
serie_ts <- ts(valor, start = c(start_year, start_month), frequency = 12)

# Ajustar modelo con auto.arima
modelo <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Extraer fechas del pronóstico: las 12 siguientes fechas mensuales después del último punto
ultima_fecha <- max(fecha)  # Este debería ser una Date
# Las fechas del pronóstico comienzan el mes siguiente al último punto
pronostico_fechas <- seq(ultima_fecha, by = "month", length.out = 13)[2:13]
# [2:13] excluye la fecha del último punto y da las siguientes 12 fechas
# Por ejemplo, si ultima_fecha es 2025-12-01, entonces seq da 2025-12-01, 2026-01-01, ..., 2026-11-01, 2026-12-01; [2:13] da 2026-01-01 hasta 2026-12-01

# Extraer la media puntual del pronóstico
pronostico_vals <- pronostico$mean

# Crear el dataframe de salida (solo las fechas de pronóstico)
resultado <- data.frame(
  fecha = format(pronostico_fechas, "%Y-%m-%d"),
  pronostico = pronostico_vals
)

# Guardar en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE, quote = FALSE)

# Mostrar información para verificar
cat("Datos leídos:\n")
print(head(data))
cat("Fecha última:", ultima_fecha, "\n")
cat("Serie ts:\n")
print(serie_ts)
cat("Modelo auto.arima:\n")
print(modelo)
cat("Pronóstico:\n")
print(pronostico)
cat("Fecha del pronóstico:", format(pronostico_fechas, "%Y-%m-%d"), "\n")
cat("Archivo pronostico_r.csv generado:\n")
print(head(resultado))