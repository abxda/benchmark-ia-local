# Script R: Pronóstico con ARIMA automático
# Lee serie_mensual.csv y genera un forecast de 12 meses con auto.arima

# Cargar el paquete forecast
library(forecast)

# Leer el archivo CSV con stringsAsFactors=FALSE para evitar problemas
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Convertir la columna fecha a formato Date
# El formato del archivo es YYYY-MM-DD, usamos %Y-%m-%d
datos$fecha <- as.Date(datos$fecha, format = "%Y-%m-%d")

# Verificar que la serie tiene 72 observaciones
if (nrow(datos) != 72) {
  stop("El archivo debe contener exactamente 72 observaciones.")
}

# Convertir a objeto ts con frecuencia anual (12)
# start = c(año, mes) del primer mes
# Extraer año y mes directamente del string original
# YYYY-MM-DD -> año en posiciones 1-4, mes en posiciones 6-7
fecha_str <- datos$fecha[1]
start_anio <- as.integer(substr(fecha_str, start = 1, stop = 4))
start_mes <- as.integer(substr(fecha_str, start = 6, stop = 7))

cat("Fecha de inicio:", as.character(datos$fecha[1]), "\n")
cat("start_anio:", start_anio, "\n")
cat("start_mes:", start_mes, "\n")

serie <- ts(datos$valor, frequency = 12, start = c(start_anio, start_mes))

# Ajustar modelo ARIMA con auto.arima
modelo <- auto.arima(serie, seasonal = TRUE, allowmean = TRUE, stepwise = TRUE)

# Generar forecast de 12 meses
pronosticos <- forecast(modelo, h = 12)

# Preparar el resultado: fechas y predicciones (media puntual)
resultado <- data.frame(
  fecha = format(seq(as.Date(format(max(datos$fecha), "%Y-%m"), days = 0, length.out = 12, by = "month")), "%Y-%m-%d"),
  pronostico = pronosticos$mean
)

# Guardar en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# Mostrar resultado en consola
cat("\nPronóstico de 12 meses:\n")
print(resultado)
cat("\nArchivo 'pronostico_r.csv' guardado correctamente.\n")
