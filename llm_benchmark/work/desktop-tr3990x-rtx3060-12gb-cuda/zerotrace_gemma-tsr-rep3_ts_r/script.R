library(forecast)

# 1. Leer la serie mensual
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 2. Convertir a objeto ts con frequency = 12
fecha_inicio <- as.Date(datos$fecha[1])
serie_ts <- ts(datos$valor, start = c(as.numeric(format(fecha_inicio, "%Y")), 
                                      as.numeric(format(fecha_inicio, "%m"))), 
               frequency = 12)

# 3. Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# 4. Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# 5. Preparar datos para el CSV
ultimo_mes <- as.Date(datos$fecha[nrow(datos)])
fechas_pronostico <- seq(ultimo_mes, by = "month", length.out = 13)[-1]

# Crear dataframe de salida
df_pronostico <- data.frame(
  fecha = format(fechas_pronostico, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico$mean)
)

# 6. Guardar en pronostico_r.csv
write.csv(df_pronostico, "pronostico_r.csv", row.names = FALSE)
