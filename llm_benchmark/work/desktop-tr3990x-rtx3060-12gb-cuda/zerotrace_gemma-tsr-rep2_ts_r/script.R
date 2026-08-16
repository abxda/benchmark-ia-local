library(forecast)

# 1. Leer el archivo CSV
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 2. Convertir la columna fecha a objetos Date
fechas <- as.Date(datos$fecha)

# 3. Convertir a objeto ts con frecuencia 12
serie_ts <- ts(datos$valor, start = c(as.numeric(format(fechas[1], "%Y")), 
                                      as.numeric(format(fechas[1], "%m"))), 
                frequency = 12)

# 4. Ajustar el modelo auto.arima
modelo <- auto.arima(serie_ts)

# 5. Generar pronóstico de 12 meses
pronostico_obj <- forecast(modelo, h = 12)

# 6. Preparar los datos para el guardado
# Calculamos la fecha de inicio del pronóstico (el mes siguiente al último de la serie)
mes_final <- as.numeric(format(max(fechas), "%m"))
anio_final <- as.numeric(format(max(fechas), "%Y"))

if (mes_final == 12) {
  fecha_inicio_pronostico <- as.Date(paste0(anio_final + 1, "-01-01"))
} else {
  fecha_inicio_pronostico <- as.Date(paste0(anio_final, "-", sprintf("%02d", mes_final + 1), "-01"))
}

fechas_pronostico <- seq(fecha_inicio_pronostico, by = "month", length.out = 12)

# Crear el dataframe de salida
df_pronostico <- data.frame(
  fecha = format(fechas_pronostico, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico_obj$mean)
)

# 7. Guardar en 'pronostico_r.csv'
write.csv(df_pronostico, "pronostico_r.csv", row.names = FALSE)
