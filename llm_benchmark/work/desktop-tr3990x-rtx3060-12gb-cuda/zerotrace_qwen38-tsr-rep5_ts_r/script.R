# Script R: pronóstico de serie temporal con ARIMA
# Lee 'serie_mensual.csv' (72 meses), ajusta un modelo auto.arima y
# genera un pronóstico de 12 meses en 'pronostico_r.csv'.

library(forecast)
library(tibble)

# 1. Leer datos (fecha, valor)
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 2. Convertir a ts con frequency = 12 (mensual)
d1 <- as.Date(datos$fecha[1], "%Y-%m-%d")
start_year  <- as.integer(format(d1, "%Y"))
start_month <- as.integer(format(d1, "%m"))
serie_ts <- ts(datos$valor,
               start = c(start_year, start_month),
               frequency = 12)

# 3. Ajustar modelo con auto.arima
modelo <- auto.arima(serie_ts)

# 4. Pronóstico de 12 meses
f <- forecast(modelo, h = 12)

# 5. Fechas de los 12 meses siguientes en formato YYYY-MM-DD
#    (primer día del mes siguiente al último dato)
ultimo <- as.Date(datos$fecha[nrow(datos)], "%Y-%m-%d")
ultimo_year  <- as.integer(format(ultimo, "%Y"))
ultimo_month <- as.integer(format(ultimo, "%m"))

# Calcular el primer día del mes siguiente
if (ultimo_month == 12) {
  next_year  <- ultimo_year + 1
  next_month <- 1L
} else {
  next_year  <- ultimo_year
  next_month <- ultimo_month + 1L
}

# Generar 12 fechas mensuales: YYYY-MM-01
fechas <- as.Date(sprintf("%04d-%02d-01", next_year, next_month))
# Usar seq para generar 12 meses
fechas <- as.Date(format(seq(from = fechas, by = "month", length.out = 12),
                          "%Y-%m-01"))

# 6. Data frame de salida: fecha (YYYY-MM-DD) y pronostico (media puntual)
result <- data.frame(
  fecha = as.character(fechas),
  pronostico = as.numeric(f$mean)
)

# 7. Guardar
write.csv(result, "pronostico_r.csv", row.names = FALSE)

cat("Pronóstico guardado en 'pronostico_r.csv' con", nrow(result), "filas\n")
print(result)
