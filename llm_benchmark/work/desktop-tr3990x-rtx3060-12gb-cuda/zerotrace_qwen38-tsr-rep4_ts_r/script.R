# Pronóstico de 12 meses con auto.arima (paquete forecast)
library(forecast)

# 1) Leer serie_mensual.csv (columnas: fecha, valor)
datos <- read.csv("serie_mensual.csv")

# 2) Convertir a ts con frequency = 12
serie <- ts(datos$valor, frequency = 12)

# 3) Ajustar modelo ARIMA
modelo <- auto.arima(serie)

# 4) Pronóstico de 12 meses
pron <- forecast(modelo, 12)
medias <- as.numeric(pron$mean)

# Fechas de los 12 meses siguientes a la serie (enero-diciembre 2026)
fechas <- sprintf("%04d-%02d-01", 2026, 1:12)

# 5) Guardar resultado
resultado <- data.frame(
  fecha = fechas,
  pronostico = round(medias, 2)
)

write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

cat("Modelo:", paste(names(coef(modelo)), collapse = " "), "\n")
print(head(resultado, 3))
cat("Filas:", nrow(resultado), "\n")
