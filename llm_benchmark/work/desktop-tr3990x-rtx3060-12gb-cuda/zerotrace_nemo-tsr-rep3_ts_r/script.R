# Script R: leer serie mensual, ajustar ARIMA y pronosticar

# 1. Cargar librerías
library(forecast)

# 2. Leer el CSV
datos <- read.csv("serie_mensual.csv", header = TRUE, stringsAsFactors = FALSE)

# 3. Convertir a serie temporal con frecuencia 12
# La fecha ya está en formato Date, usamos ts() a partir del valor
serie <- ts(datos$valor, frequency = 12, start = c(2020, 1))

# 4. Ajustar modelo auto.arima
ajuste <- auto.arima(serie)

# 5. Generar pronóstico de 12 meses
pronostico <- forecast(ajuste, h = 12)

# 6. Preparar datos para salida
# Los próximos 12 meses empezando después del último dato
ultima_fecha <- as.Date(tail(datos$fecha, 1))
# Calcular el primer mes de pronóstico (siguiente mes después de la última fecha)
primer_proximo <- format(ultima_fecha, "%Y-%m-01")
# Crear secuencia de 12 meses siguientes
fechas_proximo <- seq(from = as.Date(paste0(primer_proximo, " 01")),
                      by = "month", length.out = 12)

# Crear data frame con fecha (formato YYYY-MM-DD) y valor puntual (media)
resultado <- data.frame(
  fecha = format(fechas_proximo, "%Y-%m-%d"),
  pronostico = as.numeric(pronostico$mean)
)

# 7. Guardar resultado
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

cat("Script completado. Resultados guardados en pronostico_r.csv\n")
print(head(resultado))