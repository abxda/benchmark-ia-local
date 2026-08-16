# Pronóstico de 12 meses con auto.arima (paquete forecast)
library(forecast)

# Leer datos (fecha, valor)
df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Convertir a serie temporal mensual (frequency = 12)
serie_ts <- ts(df$valor, frequency = 12)

# Ajustar modelo ARIMA por selección automática
fit <- auto.arima(serie_ts)

# Pronóstico de los 12 meses siguientes
f <- forecast(fit, h = 12)

# Fechas de los meses siguientes al último mes observado
ultima <- as.Date(df$fecha[72])
fechas <- as.Date(format(ultima + as.periods(1:12, months), "%Y-%m-%d"))

# Guardar resultado
out <- data.frame(
  fecha = as.character(fechas),
  pronostico = as.numeric(f$point)
)
write.csv(out, "pronostico_r.csv", row.names = FALSE)

cat("Modelo:", paste(names(coef(fit)), collapse = " "), "\n")
print(head(f$point, 3))
