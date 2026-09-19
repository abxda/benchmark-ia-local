# script.R
# Prueba de auto.arima sobre serie_mensual.csv (72 meses), pronóstico de 12 meses

library(forecast)
library(dplyr)

# 1. Leer datos
df <- read.csv("serie_mensual.csv")
df$fecha <- as.Date(df$fecha)
df <- arrange(df, fecha)

# 2. Convertir a ts (freq = 12)
min_f <- min(df$fecha)
serie_ts <- ts(df$valor, start = c(as.numeric(format(min_f, "%Y")), as.integer(format(min_f, "%m"))), frequency = 12)

# 3. Modelo ARIMA automático
modelo <- auto.arima(serie_ts, seasonal = TRUE)

# 4. Pronóstico 12 meses
pron <- forecast(modelo, h = 12)

# 5. Fechas de los 12 meses siguientes a la última fecha observada
ultima_fecha <- max(df$fecha)
nuevas_fechas <- seq(from = ultima_fecha, length.out = 13, by = "month")[-1]
nuevas_fechas <- as.Date(nuevas_fechas)

# 6. Resultado final: fecha (YYYY-MM-DD) y pronóstico puntual (media)
res <- data.frame(
  fecha = format(nuevas_fechas, "%Y-%m-%d"),
  pronostico = as.numeric(pron$mean)
)

# 7. Guardar
write.csv(res, "pronostico_r.csv", row.names = FALSE)

cat("Modelo:", str(modelo, max.lines = 2), "\n")
print(res)
cat("Guardado en pronostico_r.csv\n")
