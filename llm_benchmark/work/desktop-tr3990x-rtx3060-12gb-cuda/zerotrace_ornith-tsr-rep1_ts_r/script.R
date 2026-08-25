#!/usr/bin/env Rscript

# Pronostico de serie mensual con auto.arima (paquete forecast)
library(forecast)

# 1) Leer la serie
df <- read.csv("serie_mensual.csv")
n <- nrow(df)

# 2) Convertir la fecha a Date
df$fecha <- as.Date(df$fecha)

# Ordenar por fecha
df <- df[order(df$fecha), ]

# 3) Construir la serie ts con frecuencia mensual anual
serie <- ts(df$valor, start = c(2020, 1), frequency = 12)

# 4) Ajustar el modelo ARIMA automaticamente
modelo <- auto.arima(serie)

# 5) Pronostico de 12 meses hacia el futuro
horizon <- 12
pron <- forecast(modelo, h = horizon)

# 6) Generar las fechas de los meses siguientes (iteracion mes a mes)
ult <- max(df$fecha)
horizon <- 12
fechas_pron <- as.Date(character(0))
for (i in seq_len(horizon)) {
  fechas_pron <- c(fechas_pron, ult + as.difftime(i, units = "days"))
}

# 7) Extraer la media puntual (columna mean)
pronostico <- as.numeric(pron$mean)

# 8) Estructura de salida
salida <- data.frame(
  fecha = format(fechas_pron, "%Y-%m-%d"),
  pronostico = pronostico
)

# 9) Guardar el resultado
write.csv(salida, "pronostico_r.csv", row.names = FALSE)

cat("Modelo ajustado:", class(modelo), "\n")
cat("Pronostico de", horizon, "meses guardado en pronostico_r.csv\n")
print(salida)
