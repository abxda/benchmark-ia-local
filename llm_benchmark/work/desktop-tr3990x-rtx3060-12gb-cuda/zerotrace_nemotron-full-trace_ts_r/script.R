# Script R: leer serie, ajustar modelo ARIMA y generar pronóstico de 12 meses

# Cargar librerías
library(readr)
library(forecast)

# Leer los datos
datos <- read_csv("serie_mensual.csv", col_types = cols(fecha = col_date(format = "%Y-%m-%d"), valor = col_double()))

# Convertir a serie de tiempo con frecuencia 12 (anual)
serie_ts <- ts(datos$valor, frequency = 12, start = c(2020, 1))

# Ajustar modelo auto.arima
modelo <- auto.arima(serie_ts)

# Generar pronóstico de 12 meses
pronostico <- forecast(modelo, h = 12)

# Crear marco de datos con las fechas de los próximos 12 meses
# Los últimos datos van hasta 2025-12-01, así que el pronóstico empieza en 2026-01-01
fechas_pronostico <- seq(from = as.Date("2026-01-01"), by = "month", length.out = 12)

# Guardar resultados en CSV (formatear a 4 decimales)
resultado <- data.frame(fecha = fechas_pronostico, pronostico = round(pronostico$mean, 4))
write_csv(resultado, "pronostico_r.csv")

# Mostrar resultados por pantalla
print("Modelo auto.arima ajustado:")
print(modelo)
print("\nPronóstico de 12 meses:")
print(pronostico)
print("\nResultado guardado en pronostico_r.csv:")
print(resultado)