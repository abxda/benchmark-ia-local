# Cargar librerías necesarias
library(writexl)
library(readxl)
library(openxlsx)

# Leer el archivo CSV
ventas <- read.csv("ventas.csv")

# Calcular las ventas totales por región
ventas_totales <- aggregate(ventas$ventas, by=list(Region=ventas$region), FUN=sum)

# Renombrar la columna para que coincida con el requerimiento
colnames(ventas_totales) <- c("region", "ventas_totales")

# Crear el archivo Excel con la hoja 'Resumen'
write_xlsx(ventas_totales, "reporte_r.xlsx", sheet = "Resumen")

print("Script ejecutado correctamente. Archivo reporte_r.xlsx generado.")