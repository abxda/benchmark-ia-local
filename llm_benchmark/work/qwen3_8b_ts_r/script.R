library(forecast)
datos <- read.csv("serie_mensual.csv")
datos$fecha <- as.Date(datos$fecha)
ts_datos <- ts(datos$valor, frequency = 12, start = c(year(datos$fecha[1]), month(datos$fecha[1])))
modelo <- auto.arima(ts_datos)
pronostico <- forecast(modelo, h = 12)
pronostico_df <- data.frame(fecha = as.Date(chron::chron(paste(year(pronostico$mean), month(pronostico$mean), sep = "-")), 
                            pronostico = as.numeric(pronostico$mean))
write.csv(pronostico_df, "pronostico_r.csv", row.names = FALSE)
