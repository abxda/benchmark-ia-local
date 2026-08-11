# Script R: pronóstico con auto.arima

# Cargar librerías necesarias
library(forecast)

# Leer la serie temporal
datos <- read.csv("serie_mensual.csv", header = TRUE)

# Convertir a serie temporal con frecuencia 12
serie_ts <- ts(datos$valor, frequency = 12)

# Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Extraer la media puntual
pronostico_media <- pronostico$mean

# Crear fechas para los próximos 12 meses
# La última fecha en los datos es 2025-12-01
ultima_fecha <- as.Date("2025-12-01")
nuevas_fechas <- seq(from = ultima_fecha, by = "month", length.out = 12 + 1)[-1]  # -1 para quitar la primera (que es la última del histórico)

# Crear data.frame con resultados
resultado <- data.frame(
  fecha = format(nuevas_fechas, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico_media)
)

# Guardar resultado
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

cat("Script completado. Resultados guardados en pronostico_r.csv\n")
print(head(resultado))