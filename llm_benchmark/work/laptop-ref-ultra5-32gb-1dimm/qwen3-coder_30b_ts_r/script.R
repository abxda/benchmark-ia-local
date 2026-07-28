library(forecast)

# Leer los datos
datos <- read.csv("serie_mensual.csv", header = TRUE)

# Convertir a ts con frecuencia 12
ts_data <- ts(datos$valor, start = c(2010, 1), frequency = 12)

# Ajustar modelo automático ARIMA
modelo <- auto.arima(ts_data)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Crear dataframe con fechas y pronósticos
ultima_fecha <- tail(datos$fecha, 1)
fecha_inicio <- as.Date(ultima_fecha) + 1
fechas <- seq(from = fecha_inicio, by = "month", length.out = 12)
fechas_formato <- format(fechas, "%Y-%m-%d")

# Extraer valores pronosticados
pronostico_valores <- pronostico$mean

# Crear dataframe final
resultado <- data.frame(
  fecha = fechas_formato,
  pronostico = pronostico_valores
)

# Guardar en archivo CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)
