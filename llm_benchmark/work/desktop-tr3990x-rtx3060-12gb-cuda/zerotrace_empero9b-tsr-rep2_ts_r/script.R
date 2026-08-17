#!/usr/bin/env Rscript
# ============================================================
# Script R: Pronóstico de serie mensual con auto.arima
# ============================================================

# Cargar librería
library(forecast)

# 1. LEER DATOS
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# 2. CONVERTIR A OBJETO ts
# frequency = 12 indica estacionalidad mensual (12 meses/año)
serie <- ts(datos$valor, start = c(2020, 1), frequency = 12)

# 3. AJUSTAR MODELO con auto.arima
modelo <- auto.arima(serie, stepwise = TRUE, approximation = TRUE)

# 4. GENERAR PRONÓSTICO DE 12 MESES
pronostico_obj <- forecast(modelo, h = 12)

# 5. EXTRAER FECHAS (meses siguientes al último dato)
# El último dato es 2025-12, los 12 meses siguientes son 2026-01 a 2026-12
fecha_base <- as.Date("2026-01-01")
fechas <- seq.Date(from = fecha_base, by = "month", length.out = 12)
nombres_fecha <- format(fechas, format = "%Y-%m-%d")

# 6. CREAR DATAFRAME DE RESULTADOS
resultado <- data.frame(
  fecha = nombres_fecha,
  pronostico = as.numeric(pronostico_obj$mean)
)

# 7. GUARDAR EN CSV
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# 8. MOSTRAR RESULTADO EN CONSOLA
cat("=== Resultado del pronóstico (12 meses) ===\n")
print(resultado)
