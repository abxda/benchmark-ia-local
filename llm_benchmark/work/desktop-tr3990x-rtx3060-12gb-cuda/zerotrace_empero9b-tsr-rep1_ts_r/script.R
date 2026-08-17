# ============================================================
# Script R: Pronóstico de serie mensual con auto.arima
# ============================================================

# Carga de librerías
library(forecast)

# --- 1. Leer el archivo CSV ---
serie <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# --- 2. Convertir a objeto ts con frecuencia mensual (frequency = 12) ---
serie_ts <- ts(serie$valor,
                frequency = 12,
                start = c(2020, 1))

# --- 3. Ajustar modelo con auto.arima ---
modelo <- auto.arima(serie_ts, stepwise = TRUE, approximation = FALSE)

# --- 4. Generar pronóstico de 12 meses ---
pronostico_obj <- forecast(modelo, h = 12)

# --- 5. Extraer la media puntual y crear dataframe de resultado ---
pronostico <- data.frame(
  fecha = as.character(pronostico_obj$mean),
  pronostico = pronostico_obj$mean
)

# --- 6. Guardar resultado en archivo CSV ---
write.csv(pronostico, "pronostico_r.csv", row.names = FALSE)

# --- 7. Verificación de salida ---
cat("Resultado del modelo:\n")
print(modelo)
cat("\nPronóstico de 12 meses:\n")
print(pronostico)
cat("\nArchivo guardado: pronostico_r.csv\n")
