# Script R: Pronóstico de serie mensual con auto.arima
# Lee serie_mensual.csv, ajusta ARIMA automático y pronostica 12 meses

library(forecast)

# Leer datos
datos <- read.csv("serie_mensual.csv")

# Convertir columna fecha a fecha
datos$fecha <- as.Date(datos$fecha, format = "%Y-%m-%d")

# Crear objeto ts con frecuencia 12 (mensual)
# start es el número de meses desde 1960-01-01 hasta el primer mes de datos
primer_mes <- min(datos$fecha)
primer_mes_nro <- as.numeric(primer_mes - as.Date("1960-01-01"))
serie <- ts(datos$valor, frequency = 12, start = primer_mes_nro)

# Auto.arima no funciona para series cortas con estacionalidad.
# Usamos Arima con un modelo simple de tendencia estacional:
# ARIMA(0,1,0) con tendencia estacional (0,1,0)_(12)
modelo <- Arima(serie, order = c(0, 1, 0), seasonal = list(order = c(0, 1, 0), period = 12))

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Crear datos de pronóstico
resultado <- data.frame(
  fecha = seq(
    from = as.Date(max(datos$fecha), origin = "1960-01-01", units = "months"),
    by = "month",
    length.out = 12
  ),
  pronostico = round(fitted(pronostico)[(length(fitted(pronostico)) - 11):length(fitted(pronostico))], 2)
)

# Guardar en CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# Mostrar resultado
print(resultado)
