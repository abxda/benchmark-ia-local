# Script de R para pronóstico de series temporales con Auto-ARIMA
# Lee serie_mensual.csv, ajusta modelo con auto.arima y genera pronóstico de 12 meses

library(forecast)

# 1. Leer los datos
data <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 2. Crear una serie temporal con frequency=12
ts_obj <- ts(data$valor, start = 2020, end = 2025, frequency = 12)

# 3. Ajustar modelo con auto.arima
modelo <- auto.arima(ts_obj, seasonal = TRUE, approximation = TRUE)

# 4. Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# 5. Preparar los meses futuros
# Obtener fecha final actual
fecha_actual <- as.Date("2025-12-01")

# Generar 12 fechas futuras en formato YYYY-MM-DD
meses_futuros <- seq(
  from = as.Date("2025-12-01"),
  by = "month",
  length.out = 12
)
formatas_fechas <- format(meses_futuros, format = "%Y-%m-%d")

# 6. Crear dataframe con resultados
resultado <- data.frame(
  fecha = formatas_fechas,
  pronostico = pronostico$mean
)

# 7. Guardar en archivo CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# 8. Imprimir resultados
cat("=== PRONÓSTICO GENERADO EXITOSAMENTE ===\n\n")
print(resultado)
cat("\n\nModelo utilizado:", modelo$order, "\n")
cat("RMS E:", pronostico$rme, "\n")
