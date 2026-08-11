# Script R: Ajustar modelo auto.arima y generar pronóstico de 12 meses

# Cargar librerías
library(forecast)
library(lubridate)

# Leer el archivo CSV
datos <- read.csv("serie_mensual.csv", header = TRUE, stringsAsFactors = FALSE)

# Convertir la columna fecha a formato Date
datos$fecha <- as.Date(datos$fecha)

# Crear objeto de serie temporal con frecuencia 12 (mensual)
# El primer valor corresponde a enero 2020
serie_ts <- ts(datos$valor, start = c(2020, 1), frequency = 12)

# Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Extraer la media puntual (point forecast)
pronostico_media <- pronostico$mean

# Generar fechas para los 12 meses siguientes
# El último dato es diciembre 2025, entonces los pronósticos empiezan en enero 2026
ultimo_mes <- as.Date("2025-12-01")
fechas_pred <- seq(from = ultimo_mes, by = "month", length.out = 12 + 1)
fechas_pred <- fechas_pred[2:(12 + 1)]  # quitar el primer elemento que ya es el último mes observado
fechas_pred <- format(fechas_pred, "%Y-%m-%d")

# Crear data frame con resultados
resultado <- data.frame(
  fecha = fechas_pred,
  pronostico = as.numeric(pronostico_media)
)

# Guardar resultados en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# Mostrar resultados por consola
print("Modelo auto.arima ajustado:")
print(modelo)
print("Pronóstico de 12 meses:")
print(resultado)