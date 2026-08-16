# Ajuste de auto.arima (forecast) y pronóstico de 12 meses sobre serie_mensual.csv
library(forecast)

# 1) Lectura de la serie
df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
df$fecha <- as.Date(df$fecha)

# 2) Conversión a ts con frequency = 12 (mensual)
serie_ts <- ts(df$valor, start = c(as.integer(format(df$fecha[1], "%Y")), 1),
               frequency = 12)

# 3) Ajuste del modelo
modelo <- auto.arima(serie_ts)

# 4) Pronóstico de 12 meses
f <- forecast(modelo, 12)
h <- f$mean

# Fechas de los 12 meses siguientes: primer día de cada mes
last_date <- max(df$fecha)
fechas <- as.character(seq(last_date, by = "1 month", length.out = 13)[- (1:1)])

# 5) Guardar resultado
salida <- data.frame(fecha = fechas, pronostico = as.numeric(h))
write.csv(salida, "pronostico_r.csv", row.names = FALSE)
cat("Modelo:", as.character(modelo), "\n")
