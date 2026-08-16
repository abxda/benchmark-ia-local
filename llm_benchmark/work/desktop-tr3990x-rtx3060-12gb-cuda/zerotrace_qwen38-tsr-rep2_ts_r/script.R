# Pronóstico de 12 meses con ARIMA (paquete forecast)

library(forecast)

# 1. Carga los datos
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
stopifnot(all(c("fecha", "valor") %in% names(datos)))

# 2. Ordena por fecha y convierte a ts con frecuencia mensual (12)
datos <- datos[order(datos$fecha), ]
ts_serie <- ts(datos$valor, frequency = 12)

# 3. Ajusta el modelo ARIMA
modelo <- auto.arima(ts_serie)
cat("Modelo seleccionado: ", as.character(modelo), " AIC:", round(AIC(modelo), 2), "\n")

# 4. Pronostico de 12 meses
pronostico <- forecast(modelo, h = 12)
media <- as.numeric(pronostico$mean)

# 5. Fechas de los 12 meses siguientes al ultimo mes observado
# (formato YYYY-MM-DD, primer dia del mes)
ultima_fecha <- max(as.Date(datos$fecha))
fechas <- as.Date(sprintf("%d-01-01",
                           seq(as.integer(format(ultima_fecha, "%Y")) + 1,
                                 by = 1, length.out = 12)))

resultado <- data.frame(fecha = format(fechas, "%Y-%m-%d"),
                         pronostico = round(media, 2))

# 6. Guarda el resultado
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)
cat("Pronostico guardado en pronostico_r.csv\n")
