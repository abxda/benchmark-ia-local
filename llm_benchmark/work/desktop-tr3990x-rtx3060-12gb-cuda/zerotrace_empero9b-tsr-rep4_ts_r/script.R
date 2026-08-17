# Script R: Pronóstico con auto.arima
# Lee serie_mensual.csv, ajusta modelo y genera pronóstico de 12 meses

# Cargar datos
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Convertir la columna fecha a objeto Date
datos$fecha <- as.Date(datos$fecha, format = "%Y-%m-%d")

# Convertir a objeto ts con frecuencia 12 (datos mensuales)
serie <- ts(datos$valor, frequency = 12, start = c(2020, 1))

# Ajustar modelo ARIMA con auto.arima
modelo <- auto.arima(serie, stepwise = TRUE, approximate = FALSE,
                      trace = FALSE, nstart = 10)

# Generar pronóstico de 12 meses
pronosticos <- forecast(modelo, h = 12)

# Extraer la media puntual de cada predicción
pronostico <- round(as.numeric(pronosticos$mean), 2)

# Generar las fechas futuras (meses siguientes al último dato)
ultimo_mes <- as.integer(max(datos$fecha))
fechas_futuras <- seq(as.Date(paste0(format(ultimo_mes, "%Y"), "-"), format = "%Y-%m-01"),
                       by = "month", length.out = 12)

# Crear dataframe de resultados
resultado <- data.frame(fecha = fechas_futuras, pronostico = pronostico)

# Guardar en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# Mostrar resultado
print("Pronóstico de 12 meses:")
print(resultado)
