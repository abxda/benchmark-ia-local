# Script R: Leer serie mensual, ajustar modelo auto.arima y generar pronóstico

# Cargar librerías necesarias
library(forecast)

# Leer el archivo CSV
datos <- read.csv("serie_mensual.csv", header = TRUE)

# Verificar estructura
head(datos)

# Convertir a serie temporal con frequency=12
# Asumimos que los datos comienzan en enero 2020
serie_ts <- ts(datos$valor, start = c(2020, 1), frequency = 12)

# Ajustar modelo auto.arima
ajuste <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses
pronostico <- forecast(ajuste, h = 12)

# Ver resultados
print(pronostico)

# Extraer la media puntual
medias <- pronostico$mean

# Las fechas ya vienen en el objeto forecast$mean como objeto Time-Series
# Accedemos a los atributos para obtener las fechas

# Los atributos del objeto Time-Series containen la información de inicio y frecuencia
inicio <- attr(pronostico$mean, "start")
fin <- attr(pronostico$mean, "end")
frecuencia <- attr(pronostico$mean, "frequency")

# Crear secuencia de fechas desde el inicio hasta el fin con la frecuencia adecuada
fechas_prognostico <- seq(from = inicio, by = 1/frecuencia, length.out = length(pronostico$mean))

# Formatear como YYYY-MM-DD
fechas_formateadas <- format(fechas_prognostico, "%Y-%m-%d")

# Crear data frame con resultados
resultado <- data.frame(
  fecha = fechas_formateadas,
  pronostico = as.numeric(pronostico$mean)
)

# Guardar resultados
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# Mostrar resultado
print(resultado)