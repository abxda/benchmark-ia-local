# Script R para leer ventas.csv y crear reporte_r.xlsx
# Autor: Zero Agent
# Fecha: 2025

# Cargar paquetes
library(writexl)

# Leer el archivo CSV
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Crear el dataframe de resumen con suma de ventas por region
resumen <- data.frame(
  region = ventas$region,
  ventas_totales = ventas$ventas
)

# Ordenar por region (opcional, para consistencia)
resumen <- resumen[order(resumen$region), ]

# Escribir en Excel con una sola hoja llamada 'Resumen'
writexl(
  data = resumen,
  file = "reporte_r.xlsx",
  sheet = "Resumen"
)

# Confirmación
cat("Archivo 'reporte_r.xlsx' creado exitosamente.\n")
cat("Contenido:\n")
print(resumen)
