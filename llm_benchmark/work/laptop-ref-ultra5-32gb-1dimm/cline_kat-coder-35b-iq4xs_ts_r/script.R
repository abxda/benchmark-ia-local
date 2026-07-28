# Script de pronóstico con ARIMA
# Lee serie_mensual.csv, ajusta auto.arima y genera pronóstico de 12 meses

# Cargar paquete forecast
library(forecast)

# Leer datos
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
datos$fecha <- as.Date(datos$fecha)

# Crear serie temporal con frecuencia 12 (mensual)
serie_ts <- ts(datos$valor, start = c(2020, 1), frequency = 12)

# Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Generar fechas para los próximos 12 meses (usando base R)
ultima_fecha <- max(datos$fecha)
anno <- as.numeric(format(ultima_fecha, "%Y"))
mes <- as.numeric(format(ultima_fecha, "%m"))
fechas_pred <- character(12)
for (i in 1:12) {
  m <- mes + i
  a <- anno
  while (m > 12) {
    m <- m - 12
    a <- a + 1
  }
  fechas_pred[i] <- paste0(a, "-", sprintf("%02d", m), "-01")
}

# Crear data frame de salida
resultado <- data.frame(
  fecha = fechas_pred,
  pronostico = as.numeric(pronostico$mean)
)

# Guardar resultado
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

cat("Pronóstico guardado en 'pronostico_r.csv'\n")
print(modelo)
cat("\n")
print(resultado)
