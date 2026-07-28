# Script de pronóstico de series de tiempo en R

# Cargar librerías necesarias
if (!requireNamespace("forecast", quietly = TRUE)) {
  install.packages("forecast")
}
library(forecast)

# 1. Leer el archivo CSV
# El archivo tiene 'fecha' (YYYY-MM-DD) y 'valor'
datos <- read.csv("serie_mensual.csv", header = TRUE)

# 2. Convertir la columna 'fecha' a formato de fecha
datos$fecha <- as.Date(datos$fecha, format = "%Y-%m-%d")

# 3. Crear el objeto de serie de tiempo (ts)
# La frecuencia es 12 (mensual)
# El inicio de la serie debe ser el primer mes de los datos
inicio_serie_ts <- c(as.numeric(format(min(datos$fecha), "%Y")), as.numeric(format(min(datos$fecha), "%m")))
serie_ts <- ts(datos$valor, start = c(inicio_serie_ts[1], inicio_serie_ts[2]), frequency = 12)

# 4. Ajustar el modelo auto.arima
modelo <- auto.arima(serie_ts)

# 5. Generar el pronóstico de 12 meses
horizonte <- 12
pronostico_obj <- forecast(modelo, h = horizonte)

# 6. Extraer los valores y fechas del pronóstico
predicciones <- pronostico_obj$mean

# Obtenemos la última fecha original
ultima_fecha_original <- max(datos$fecha)
# Calcular la fecha de inicio del pronóstico (el mes siguiente)
# Usamos la función seq.Date para encontrar el siguiente mes de manera robusta
fechas_pronostico <- seq.Date(from = as.Date(paste0(format(ultima_fecha_original, "%Y"), "-", format(ultima_fecha_original, "%m"), "-01")) + 1, by = "month", length.out = horizonte)

# Crear un dataframe para el resultado
resultado <- data.frame(
  fecha = fechas_pronostico,
  pronostico = as.numeric(predicciones) # Asegurar que es numérico
)

# 7. Guardar el pronóstico en 'pronostico_r.csv'
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

print("Script completado. El pronóstico ha sido guardado en 'pronostico_r.csv'.")