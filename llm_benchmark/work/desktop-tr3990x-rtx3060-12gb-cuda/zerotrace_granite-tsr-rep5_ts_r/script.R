library(forecast)

# Leer el archivo CSV
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Convertir la columna 'fecha' a Date y 'valor' a numeric
datos$fecha <- as.Date(datos$fecha)
datos$valor <- as.numeric(datos$valor)

# Crear el objeto ts con frequency=12 (mensual con estacionalidad anual)
# La serie tiene 72 meses de datos
ts_datos <- ts(datos$valor, start = c(min(as.numeric(substr(datos$fecha, 1, 4)), 1), 
                                       min(as.numeric(substr(datos$fecha, 6, 7))), 
                                       1), 
               frequency = 12)

# Ajustar modelo auto.arima
modelo <- auto.arima(ts_datos)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Obtener la media puntual del pronóstico
pronostico_media <- forecast:::mean_prediction(pronostico)

# Crear la serie de fechas para los 12 meses siguientes
# Comenzamos desde el mes siguiente al último mes del dataset
ultimo_mes <- as.numeric(substr(max(datos$fecha), 1, 7))  # YYYY-MM
prxima_fecha <- as.Date(paste(ultimo_mes, "01", "01", sep = ""), class = "Date")

# Generar fechas para los próximos 12 meses
fechas_pronostico <- seq(prxima_fecha, by = "1 month", length.out = 12)

# Extraer la media puntual del pronóstico para cada punto
# forecast$mean ya contiene la media puntual del pronóstico
pronostico_puntual <- pronostico$mean

# Crear dataframe de salida con columnas 'fecha' y 'pronostico'
resultado <- data.frame(
  fecha = format(fechas_pronostico, "%Y-%m-%d"),
  pronostico = pronostico_puntual
)

# Guardar en 'pronostico_r.csv'
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# Mostrar información breve
print(paste("Script ejecutado exitosamente. Pronóstico guardado en 'pronostico_r.csv'"))
print(head(resultado))
