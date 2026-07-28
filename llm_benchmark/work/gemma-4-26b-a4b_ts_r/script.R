library(forecast)

# 1. Leer los datos
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
datos$fecha <- as.Date(datos$fecha)

# 2. Convertir a objeto de serie temporal (ts)
# Se asume que la serie empieza en la fecha mínima del dataset
fecha_inicio <- min(datos$fecha)
serie_ts <- ts(datos$valor, frequency = 12, start = c(as.numeric(format(fecha_inicio, "%Y")), as.numeric(format(fecha_inicio, "%m"))))

# 3. Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# 4. Generar pronóstico de 12 meses
pronostico_obj <- forecast(modelo, h = 12)

# 5. Preparar fechas futuras para el CSV
ultima_fecha <- max(datos$fecha)
fechas_futuras <- seq(ultima_fecha %m+% months(1), by = "month", length.out = 12)

# Nota: %m+% requiere el paquete lubridate para manejar desbordamientos de días correctamente
# Si no se desea usar lubridate, se puede usar seq.Date con cuidado
if (!requireNamespace("lubridate", quietly = TRUE)) install.packages("lubridate")
library(lubridate)

fechas_futuras <- seq(ultima_fecha + months(1), by = "month", length.out = 12)

# 6. Crear dataframe de salida
df_pronostico <- data.frame(
  fecha = format(fechas_futuras, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico_obj$mean)
)

# 7. Guardar en CSV
write.csv(df_pronostico, "pronostico_r.csv", row.names = FALSE)
