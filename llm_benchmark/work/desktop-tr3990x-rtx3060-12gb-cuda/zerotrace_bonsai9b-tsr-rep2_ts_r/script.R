# Script R para pronóstico de serie temporal
# Lee serie_mensual.csv, convierte a ts, ajusta modelo ARIMA, y genera pronóstico

# Cargar el paquete forecast
library(forecast)

# Leer los datos
datos <- read.csv("serie_mensual.csv", header = TRUE)

# Crear columna de fecha con formato correcto
datos$fecha <- as.Date(datos$fecha, format="%Y-%m")

# Convertir a ts (los datos están ya ordenados cronológicamente)
ts_obj <- as.ts(datos$valor, frequency = 12)

# Ajustar modelo ARIMA
modelo <- auto.arima(ts_obj, seasonal = TRUE)

# Obtener predicción usando forecast con predicción solo
predictions <- modelForecast(modelo)

# Extraer la media puntual
pronostico <- predictions$mean

# Crear dataframe de resultado - fechas de diciembre a noviembre del próximo año (2026)
resultado <- data.frame(
  fecha = as.Date(seq(from = as.Date("2025-12-01"), by = "month", length.out = 12)),
  pronostico = pronostico
)

# Verificar estructura
print("Estructura del resultado:")
print(resultado)

# Guardar en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

print("Script completado exitosamente!")
