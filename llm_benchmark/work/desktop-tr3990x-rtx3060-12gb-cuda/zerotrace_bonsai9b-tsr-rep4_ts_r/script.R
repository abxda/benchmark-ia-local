# Script R para análisis de serie temporal con ARIMA

# Cargar datos
datos <- read.csv("serie_mensual.csv")

# Convertir a ts con frecuencia mensual (12 meses por año)
ts_data <- as.ts(datos$valor, frequency = 12, start = as.Date("2020-01-01"))

# Modelar con auto.arima (usando forecast::auto.arima)
modelo <- forecast::auto.arima(ts_data, seasonal = TRUE, stepwise = TRUE)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Preparar resultados
resumen <- cbind(
  Fecha = seq(as.Date("2026-01-01"), by = "month", length.out = 12),
  Pronostico = as.numeric(pronostico$mean)
)

# Guardar en CSV
write.csv(resumen, "pronostico_r.csv", row.names = FALSE)

print("Pronóstico generado y guardado en 'pronostico_r.csv'")
print(head(resumen))
print(paste("Fila:", nrow(resumen)))
