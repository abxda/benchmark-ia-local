# Cargar librerías necesarias
library(forecast)

# 1. Leer el archivo CSV
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 2. Convertir la columna 'fecha' a objeto Date
datos$fecha <- as.Date(datos$fecha)

# 3. Convertir la columna 'valor' a una serie temporal (ts)
inicio_año <- as.numeric(format(min(datos$fecha), "%Y"))
inicio_mes <- as.numeric(format(min(datos$fecha), "%m"))
serie_ts <- ts(datos$valor, start = c(inicio_año, inicio_mes), frequency = 12)

# 4. Ajustar el modelo auto.arima
modelo <- auto.arima(serie_ts)

# 5. Generar un pronóstico de 12 meses
pronostico_obj <- forecast(modelo, h = 12)

# 6. Preparar los datos para el archivo de salida
# Extraer los tiempos del pronóstico
tiempos_pronostico <- as.numeric(time(pronostico_obj$mean))

# Función vectorizada para convertir el tiempo de ts a fechas
convertir_tiempos_a_fechas <- function(t_vec) {
  años <- floor(t_vec)
  # Calculamos el mes usando la fracción del año
  # Añadimos un pequeño epsilon para evitar errores de redondeo (ej. 0.999999 -> 1)
  meses <- floor((t_vec - años) * 12 + 0.00001) + 1
  
  # Ajuste para casos donde el mes calculado sea 13 por redondeo
  ajuste <- meses > 12
  años[ajuste] <- años[ajuste] + 1
  meses[ajuste] <- 1
  
  # Crear strings de fecha y convertirlos a Date
  fechas_str <- paste(años, meses, "01", sep = "-")
  return(as.Date(fechas_str))
}

fechas_finales <- convertir_tiempos_a_fechas(tiempos_pronostico)

# Crear data frame con el resultado
resultado <- data.frame(
  fecha = format(fechas_finales, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico_obj$mean)
)

# 7. Guardar en 'pronostico_r.csv'
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)
