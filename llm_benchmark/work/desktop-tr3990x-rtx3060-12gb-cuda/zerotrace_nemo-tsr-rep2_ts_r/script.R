# Script R para leer serie mensual, ajustar modelo ARIMA y generar pronóstico

# Cargar librerías necesarias
library(forecast)
library(lubridate)

# Leer el archivo CSV
datos <- read.csv("serie_mensual.csv", header = TRUE, stringsAsFactors = FALSE)

# Convertir la columna fecha a formato Date
datos$fecha <- as.Date(datos$fecha)

# Verificar el rango de fechas
cat("Rango de fechas:", min(datos$fecha), "a", max(datos$fecha), "\n")

# Convertir a serie de tiempo con frecuencia 12 (datos mensuales)
# Usamos start desde el primer mes del dataset
ts_data <- ts(datos$valor, frequency = 12, start = c(2020, 1))

# Ajustar modelo auto.arima
modelo <- auto.arima(ts_data)

# Mostrar resumen del modelo
cat("\nResumen del modelo auto.arima:\n")
print(summary(modelo))

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Mostrar resultados del pronóstico
cat("\nResultados del pronóstico de 12 meses:\n")
print(pronostico)

# Crear datos de fechas para los próximos 12 meses
# El último mes del dataset es diciembre 2025
ultimo_mes <- as.Date("2025-12-01")
# Generar secuencia de meses siguientes
fechas_pronostico <- seq(from = ultimo_mes, by = "month", length.out = 12 + 1)[2:(12 + 1)]
# Formato YYYY-MM-DD
fechas_formateadas <- format(fechas_pronostico, "%Y-%m-%d")

# Crear data frame con resultados
resultado <- data.frame(
  fecha = fechas_formateadas,
  pronostico = as.numeric(pronostico$mean)
)

# Guardar resultados en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

cat("\nArchivo 'pronostico_r.csv' guardado exitosamente.\n")
cat("Columnas:", colnames(resultado), "\n")