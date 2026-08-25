# -*- mode: r -*-
# Pronóstico de serie mensual con Auto-ARIMA (paquete forecast)

# 1) Cargar dependencias
library(forecast)

# 2) Leer los datos
serie <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 3) Convertir la columna de fecha a Date
serie$fecha <- as.Date(serie$fecha)

# 4) Verificar el tamaño de la muestra
if (nrow(serie) != 72) {
  stop(sprintf("Se esperaban 72 filas pero se encontraron %d.", nrow(serie)))
}

# 5) Ordenar por fecha (defensa, aunque ya llega ordenada)
serie <- serie[order(serie$fecha), ]

# 6) Convertir a objeto de serie temporal con frecuencia mensual (12)
ts_obj <- ts(serie$valor, start = c(2020, 1), frequency = 12)

# 7) Ajustar el modelo con auto.arima
modelo <- auto.arima(ts_obj)

# 8) Generar el pronóstico de 12 meses
pron <- forecast(modelo, h = 12)

# 9) Construir las fechas futuras (los 12 meses siguientes al último observado)
ultimo <- tail(serie$fecha, 1)
fechas_futuras <- seq(ultimo + 31 * 24 * 3600, by = 31 * 24 * 3600, length.out = 12)

# 10) Media puntual del pronóstico
media_puntual <- as.numeric(pron$mean)

# 11) Escribir el archivo de salida
salida <- data.frame(
  fecha      = format(fechas_futuras, "%Y-%m-%d"),
  pronostico = media_puntual
)

write.csv(salida, "pronostico_r.csv", row.names = FALSE)

# 12) Resumen en consola
cat("Modelo ajustado:", deparse(modelo$call$family), "\n")
cat("Pronóstico de", length(pron), "meses:\n")
print(pron)
cat("\nArchivo generado: pronostico_r.csv\n")
