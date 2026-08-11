# Script R: Ajuste de modelo ARIMA y pronóstico mensual

# Limpiar entorno
rm(list = ls())

# Cargar librerías necesarias
library(forecast)
library(lubridate)

# 1. Leer el archivo CSV
datos <- read.csv("serie_mensual.csv", header = TRUE, stringsAsFactors = FALSE)

# 2. Convertir la columna fecha a objeto Date
datos$fecha <- as.Date(datos$fecha)

# 3. Convertir la serie a objeto ts con frequency = 12 (datos mensuales)
# Usamos la variable valor y la convertimos a ts empezando en enero 2020
serie_ts <- ts(datos$valor, frequency = 12, start = c(2020, 1))

# 4. Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# 5. Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# 6. Preparar datos para salida
# Las fechas pronosticadas comienzan después del último dato (enero 2025 + 1 mes = febrero 2025)
# El objeto forecast tiene fechas en $mean, pero las generaremos manualmente

ultima_fecha <- tail(datos$fecha, 1)
# Generar secuencia de 12 meses siguientes
fechas_proy <- seq(from = ultima_fecha + months(1), by = "month", length.out = 12)

# Crear data frame con fecha (formato YYYY-MM-DD) y el pronóstico puntual (media)
resultado <- data.frame(
  fecha = format(fechas_proy, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico$mean)
)

# 7. Guardar resultado en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# Mostrar resultados por consola
print("=== Modelo auto.arima ===")
print(summary(modelo))
print("=== Pronóstico de 12 meses ===")
print(resultado)