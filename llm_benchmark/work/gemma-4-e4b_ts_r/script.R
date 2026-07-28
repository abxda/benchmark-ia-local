# Cargar librerías necesarias
library(forecast)
library(tseries)

# 1. Leer los datos
datos <- read.csv('serie_mensual.csv')

# 2. Convertir la serie a objeto ts
# Asumimos que la primera fecha es el inicio de la serie
# Creamos un vector de fechas para asegurar el orden correcto si es necesario,
# pero para ts, solo necesitamos la frecuencia y el número de observaciones.
serie_ts <- ts(datos$valor, start = c(format(as.Date(datos$fecha[1]), "%Y"), 1), frequency = 12)

# 3. Ajustar el modelo ARIMA usando auto.arima
modelo_arima <- auto.arima(serie_ts)

# 4. Generar el pronóstico de 12 meses
pronostico_obj <- forecast(modelo_arima, h = 12)

# 5. Extraer los valores pronosticados y las fechas futuras
# Extraer los valores medios puntuales
pronosticos_valores <- pronostico_obj$mean

# Generar las fechas futuras (los próximos 12 meses)
# Obtener la fecha de inicio de la serie original
fecha_inicio_serie <- as.Date(datos$fecha[nrow(datos)])
# Generar las fechas para los próximos 12 meses
fechas_futuras <- seq(from = fecha_inicio_serie + 1, by = "month", length.out = 12)

# Crear el dataframe de resultados
pronostico_df <- data.frame(
  fecha = format(fechas_futuras, "%Y-%m-%d"),
  pronostico = as.numeric(pronosticos_valores)
)

# 6. Guardar el pronóstico en CSV
write.csv(pronostico_df, 'pronostico_r.csv', row.names = FALSE)

# Opcional: Imprimir confirmación
# print("Pronóstico guardado en 'pronostico_r.csv'")
