# Script de pronóstico con ARIMA (forecast)
# Lee serie_mensual.csv, convierte a ts con frecuencia mensual,
# ajusta auto.arima y pronostica 12 meses.

library(forecast)

# 1) Leer la serie
datos <- read.csv("serie_mensual.csv")
serie <- datos$valor

# 2) Convertir a objeto ts con frecuencia mensual
origen <- as.Date(min(datos$fecha))
final  <- as.Date(max(datos$fecha))
start  <- as.POSIXlt(origen)
serie  <- ts(serie, start = c(start$year, start$month), frequency = 12)

# 3) Ajustar el modelo ARIMA mediante búsqueda automática
modelo <- auto.arima(serie)

# 4) Generar el pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# 5) Obtener las fechas de los próximos 12 meses (YYYY-MM-DD)
ult <- length(serie)
fechas_pron <- seq(
  from = as.Date(final),
  to   = as.Date(final) + 11,
  by   = 1
)
fechas_pron <- format(fechas_pron, "%Y-%m-%d")

# 6) Media puntual de cada horizonte (forecast() devuelve un único valor por paso)
media_puntual <- as.numeric(pronostico$mean)

# 7) Guardar el resultado
resultado <- data.frame(fecha = fechas_pron, pronostico = media_puntual)
write.csv(resultado, "pronostico_r.csv", row.names = FALSE, quote = FALSE)

cat("Pronóstico de 12 meses generado y guardado en pronostico_r.csv\n")
print(resultado)
