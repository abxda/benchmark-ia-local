# Script para procesar ventas y crear reporte Excel
library(openxlsx)

# Leer el archivo ventas.csv
ventas <- read.csv("ventas.csv")

# Calcular ventas totales por región
ventas_totales <- aggregate(ventas$ventas, by=list(region=ventas$region), FUN=sum)

# Renombrar la columna para que coincida con el requerido
colnames(ventas_totales) <- c("region", "ventas_totales")

# Crear archivo Excel con la hoja 'Resumen'
write.xlsx(ventas_totales, "reporte_r.xlsx", sheetName = "Resumen")

cat("Archivo reporte_r.xlsx creado exitosamente con la hoja 'Resumen'\n")