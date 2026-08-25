# Script: pronostico de serie mensual con ARIMA (forecast)
# Lee serie_mensual.csv, ajusta auto.arima y genera 12 meses de pronostico.

# --- 1. Cargar paquete y leer datos ---
library(forecast)

df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# --- 2. Convertir la fecha a tipo Date ---
df$fecha <- as.Date(df$fecha)

# --- 3. Construir objeto ts con frecuencia mensual (12) ---
anio_inicial <- as.integer(substr(df$fecha[1], 1, 4))
ts_data <- ts(df$valor, start = c(anio_inicial, 1), frequency = 12)

# --- 4. Ajustar modelo ARIMA automaticamente ---
fit <- auto.arima(ts_data)

# --- 5. Generar pronostico de 12 meses ---
pron <- forecast(fit, h = 12)

# La media puntual corresponde a pron["mean"]
pronostico_vals <- pron[["mean"]]

# --- 6. Obtener las fechas pronosticadas (12 meses siguientes) ---
# La serie parte en 2020-01 (indice 1); el indice global define ano y mes.
a_ini <- as.integer(substr(df$fecha[1], 1, 4))   # 2020

fechas_pron <- as.Date(character(12))
for (i in 1:12) {
  idx_total <- length(df$fecha) + i             # indice global de la serie (73..84)
  anio <- a_ini + floor((idx_total - 1) / 12)   # 2020 + k anos completos
  mes  <- ((idx_total - 1) %% 12) + 1            # 1..12
  fechas_pron[i] <- as.Date(sprintf("%04d-%02d-01", anio, mes), format = "%Y-%m-%d")
}

# --- 7. Escribir resultados en pronostico_r.csv ---
salida <- data.frame(fecha = format(fechas_pron, "%Y-%m-%d"),
                     pronostico = pronostico_vals)
write.csv(salida, "pronostico_r.csv", row.names = FALSE)

cat("Modelo ajustado:", class(fit)[1], "\n")
cat("Ultimo mes observado:", format(df$fecha[length(df$fecha)], "%Y-%m"), "\n")
cat("Filas de pronostico:", nrow(salida), "\n")
print(salida)
