#!/usr/bin/env Rscript

# =============================================================================
# Script para leer serie_mensual.csv, construir modelo con forecast, y generar
# pronostico de 12 meses.
# =============================================================================

# --- 1. Leer datos ---
library(readr)

# Read CSV file (columnas: fecha, valor)
# The file has: fecha (date), valor (numeric)
data <- read.csv("serie_mensual.csv", header=TRUE, sep=(",", "	"))

# Convert to data frame
df_data <- data.frame(
  fecha = data$fecha,
  valor = data$valor
)

# Extract date column
df_data$date <- as.Date(df_data\$fecha)

# Convert to data frame
df_data2 <- as.data.frame(df_data)

# --- 2. Crear datos temporales para la serie TS ---
ts_data <- as_tsed_data(df_data)

# --- 3. Ajustar modelo con auto.arima ---
# Auto.arima devuelve un vector de coeficientes y predicción
pred_ac <- forecast(ts_data, auto.arima)
coef <- pred_ac[["model"]$coefficients]
pred <- pred_ac[["model"]$pred]

# --- 4. Guardar archivo de resultados ---
# Crear archivo con fecha y valores del modelo
fecha <- as.Date(ts_data$end_date)
nombre_pronostico <- "PRONOSTICO_R_12MESES"
archivo <- paste0("pronostico_r.csv")
write.csv(as.data.frame(coef), file = archivo, row.names = FALSE)
cat("Archivo 'pronostico_r.csv' generado:", file, "\n")

# --- 5. Verificar columnas del archivo de salida ---
if (file.exists(archivo)) {
  df_output <- read.csv(archivo)
  
  # Verificar columnas requeridas
  if (n列(col) != 2) {
    stop("Archivo de salida no cumple exactamente lo pedido: debe tener columnas 'fecha' y 'pronostico'.")
  }
  
  if (n列(col) != 2) {
    stop("Archivo de salida no cumple exactamente lo pedido: debe tener columnas 'fecha' y 'pronostico'.")
  }
  
  if (!col("fecha") == "factor") {
    stop("La columna 'fecha' debe ser 'factor'.")
  }
  
  if (!col("pronostico") == "factor") {
    stop("La columna 'pronostico' debe ser 'factor'.")
  }
  
  if (col("fecha") == "factor") {
    if (col("pronostico") == "factor") {
      # Verificar que el primer mes no esté en la misma fecha
      # (Opcional, si el usuario no especifica el primer mes, se mantiene el orden)
      if (n列(col) > 1) {
        first_month <- ts_data$end_date
      } else {
        first_month <- ts_data$end_date
      }
      
      if (col("fecha") == "factor") {
        if (first_month %in% col("fecha")) {
          stop("El primer mes no coincide con 'factor'.")
        }
      }
    }
  }
  
  cat("✅ Archivo de salida 'pronostico_r.csv' creado correctamente.\n")
} else {
  stop("Archivo 'pronostico_r.csv' no existe para guardar.", warn = TRUE)
}

# --- 6. Ejecutar el comando de forecast para generar el pronóstico ---
# El prompt debe llamar a forecast() que ya está instalado
# Nota: forecast() devuelve un vector de coeficientes y predicción.
# El usuario pide 'la media puntual'. En el contexto de un modelo auto.arima,
# 'media puntual' puede referirse a la parte de predicción.
#
# Para mayor precisión, se puede ajustar el tiempo de ventana si se desea:
# time_window <- 24  # días

# Ejemplo de cómo llamar a forecast() directamente (usando el prompt):
# forecast(ts_data)  # Devuelve un vector de coeficientes y predicción

# Para obtener solo la media puntual (predicción) que se espera:
# predictancia <- forecast(ts_data, auto.arima)[["model"]$pred]
# predictancia <- predictancia %>% filter(factor == "pred")
# media_puntual <- predictancia[["model"]$coefficients]
#
# El prompt solicitado fue: "genera un pronostico de 12 meses con forecast() y guardalo en 'pronostico_r.csv' con columnas 'fecha' (meses siguientes en formato YYYY-MM-DD) y 'pronostico' (la media puntual)"

# Nota: Este es un ejemplo conceptual. En producción, se puede usar:
# predictancia <- forecast(ts_data, auto.arima)[["model"]$pred]
# predictancia <- predictancia %>% filter(factor == "pred")
# media_puntual <- predictancia[["model"]$coefficients]

# Ejecutando el comando de forecast
# forecast(ts_data)
