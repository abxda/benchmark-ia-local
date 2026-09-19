# Script de R: lectura de serie mensual, ajuste con auto.arima y pronóstico de 12 meses
library(forecast)
library(readr)

# --- 1. Lectura del archivo de entrada ---
df <- read_csv("serie_mensual.csv")
stopifnot(all(c("fecha", "valor") %in% names(df)))

df$fecha <- as.Date(df$fecha)
df <- df[order(df$fecha), ]
stopifnot(nrow(df) == 72)

# --- 2. Conversión a serie temporal con frequency = 12 (mensual) ---
serie <- ts(df$valor,
            start = c(as.integer(format(df$fecha[1], "%Y")),
                      as.integer(format(df$fecha[1], "%m")) - 1),
            frequency = 12)
stopifnot(length(serie) == 72)

# --- 3. Ajuste del modelo con auto.arima ---
fit <- auto.arima(serie, trace = FALSE)

# --- 4. Pronóstico de los 12 meses siguientes ---
pr <- forecast(fit, h = 12)

# Generar las 12 fechas siguientes al último dato de la serie (2025-12 -> 2026-01 ... 2026-12)
ultimo_dato <- format(tail(serie, 1), "%Y-%m")
# Sumar un mes al último dato y obtener la secuencia de 12 meses
fechas <- as.Date(
  seq(start = as.Date(paste0(ultimo_dato, "-01")) + 1,
      by = "month",
      length.out = 12)
)

# --- 5. Guardar en CSV con columnas 'fecha' (YYYY-MM-DD) y 'pronostico' (media puntual) ---
resultado <- data.frame(
  fecha = format(fechas, "%Y-%m-%d"),
  pronostico = as.numeric(pr$mean),
  stringsAsFactors = FALSE
)

write_csv(resultado, "pronostico_r.csv")

cat("Pronóstico de 12 meses guardado en 'pronostico_r.csv'\n")
print(resultado)
