#!/usr/bin/env Rscript

# Pronostico de serie mensual con auto.arima (paquete forecast)
# Lee serie_mensual.csv, ajusta un modelo ARIMA, pronostica 12 meses
# y guarda en pronostico_r.csv (fecha, pronostico).

suppressPackageStartupMessages(library(forecast))

# --- 1. Leer los datos ---
datos <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# --- 2. Convertir la columna de fecha ---
datos$fecha <- as.Date(datos$fecha)

# --- 3. Validar que tenemos 72 observaciones ---
if (nrow(datos) != 72) {
  stop("La serie debe contener exactamente 72 meses; se encontraron ",
       nrow(datos))
}

# --- 4. Convertir a objeto ts con frecuencia mensual (12) ---
serie <- ts(datos$valor, start = c(2020, 1), frequency = 12)

# --- 5. Ajustar el modelo ARIMA ---
modelo <- auto.arima(serie)

# --- 6. Generar el pronostico de 12 meses ---
futuro <- 12
pron <- forecast(modelo, h = futuro)

# --- 7. Preparar las fechas de los meses siguientes ---
# Usar el componente Year.Mo de la fecha base y avanzar un periodo entero en
# la frecuencia del ts, evitando que by="month" repita el dia del mes.
start_mo <- start(serie)
fechas_futuro <- seq(
  from = start_mo[1] + start_mo[2],   # mes siguiente a la fecha base
  by   = start_mo[2],                # frecuencia (12)
  length.out = futuro
)

# --- 8. Extraer la media puntual (predicción) ---
pronostico <- as.numeric(pron$mean)

# --- 9. Construir el data.frame de salida ---
resultado <- data.frame(
  fecha      = as.character(fechas_futuro),
  pronostico = pronostico,
  stringsAsFactors = FALSE
)

# --- 10. Guardar el resultado ---
write.csv(resultado, "pronostico_r.csv", row.names = FALSE)

# --- Informe en consola ---
cat("Serie: ", length(serie), " meses, frequency =", frequency(serie), "\n")
cat("Modelo auto.arima: ", deparse(modelo$call$series), "\n")
cat("Pronostico de ", futuro, " meses:\n")
print(resultado)

# write.csv ya guardado; el informe solo es informativo
