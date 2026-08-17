# Script R: Pronóstico con ARIMA sobre serie mensual
# Lee serie_mensual.csv, ajusta auto.arima, pronostica 12 meses y guarda resultados

# Carga de librerías
library(forecast)

# Lectura de los datos
datos <- read.csv("serie_mensual.csv")

# Conversión a objeto ts con frecuencia 12 (mensual, estacionalidad anual)
serie <- ts(datos$valor, frequency = 12)

# Ajuste del modelo con auto.arima
modelo <- auto.arima(serie, seasonal = TRUE, stepwise = TRUE)

# Generación del pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Construcción del dataframe de resultados con formato YYYY-MM-DD
resultados <- data.frame(
  fecha = format(
    as.Date("2025-01-01") + (1:12) * 30,
    format = "%Y-%m-%d"
  ),
  pronostico = round(as.numeric(pronostico$mean), 2)
)

# Guardar el archivo de salida
write.csv(resultados, "pronostico_r.csv", row.names = FALSE)

# Mostrar resultados en consola
print(resultados)
