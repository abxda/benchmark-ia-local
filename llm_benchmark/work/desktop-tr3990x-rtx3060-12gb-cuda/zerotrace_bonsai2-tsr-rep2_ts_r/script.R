# Script de pronóstico con ARIMA (auto.arima) sobre serie_mensual.csv
# Salida: pronostico_r.csv con columnas fecha (YYYY-MM-DD) y pronostico

library(forecast)

# 1) Leer los datos
df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
df$fecha <- as.Date(df$fecha, format = "%Y-%m-%d")
df <- df[order(df$fecha), ]

# 2) Convertir a series temporal mensual (frequency = 12)
serie <- ts(df$valor,
            start = c(as.integer(format(min(df$fecha), "%Y")),
                      as.integer(format(min(df$fecha), "%m"))),
            frequency = 12)

# 3) Ajustar el modelo con auto.arima
modelo <- auto.arima(serie, ic = "aicc", stepwise = TRUE, seasonal = TRUE)
print(modelo)

# 4) Pronóstico de 12 meses (media puntual)
pron <- forecast(modelo, h = 12)

# 5) Fechas: los 12 meses siguientes a la última observación
#     (2025-12 -> 2026-01 ... 2026-12) con formato YYYY-MM-DD
ult <- as.Date(end(serie))
nuevas <- format(seq(ult, length.out = 12, by = "1 month"),
                 "%Y-%m-%d")

# 6) Guardar
resultado <- data.frame(fecha = nuevas, pronostico = pron$mean)
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)
cat("Guardado en pronostico_r.csv\n")
print(resultado)
