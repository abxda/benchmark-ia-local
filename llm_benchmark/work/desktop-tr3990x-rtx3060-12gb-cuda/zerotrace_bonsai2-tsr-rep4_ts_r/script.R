# script.R
# Prueba de pronóstico con auto.arima sobre serie_mensual.csv (72 meses).
library(forecast)

# 1. Leer la serie
data <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
data$fecha <- as.Date(data$fecha)
data <- data[order(data$fecha), ]

# 2. Convertir a ts con frequency = 12
serie <- ts(data$valor,
            start = c(as.integer(format(data$fecha[1], "%Y")),
                      as.integer(format(data$fecha[1], "%m")) - 1),
            frequency = 12)

# 3. Ajustar auto.arima
modelo <- auto.arima(serie, seasonal = TRUE, trace = FALSE)

# 4. Pronóstico de 12 meses (media puntual)
pron <- forecast(modelo, h = 12)

# 5. Fechas de los próximos 12 meses (primer día de mes, YYYY-MM-DD)
# El último mes observado termina en la fecha (año, mes) de tail(time(serie))
# time(serie) es numeric: convertir al string %Y-%m-01 y luego a Date
# Usar as.POSIXct para evitar el formato default de 'format' en numeric
ultima <- format(tail(time(serie), 1), "%Y-%m-01")
# Generar 12 fechas a partir de la última observada + 1 mes
nuevas_fechas <- seq(from = as.Date(ultima, origin = "1970-01-01"),
                     length.out = 13, by = "month")
nuevas_fechas <- format(nuevas_fechas[-1], "%Y-%m-%d")
# Forzar día 1
nuevas_fechas <- sub("^([0-9]{4}-[0-9]{2})-[0-9]{2}$", "\\1-01", nuevas_fechas)

# 6. Guardar
salida <- data.frame(
  fecha = nuevas_fechas,
  pronostico = unname(pred(pron))
)

write.csv(salida, "pronostico_r.csv", row.names = FALSE)

cat("Modelo ajustado:", summary(modelo)$aicc, sep = "  ")
cat("\nPronóstico escrito a pronostico_r.csv")
