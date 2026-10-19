# Script para crear reporte excel con ventas por region

# Leer el archivo CSV
ventas <- read.csv("ventas.csv")

# Agregar columna con el total de ventas por region
ventas$ventas_totales <- ave(ventas$ventas, ventas$region, FUN = sum)

# Crear el Excel con solo las columnas necesarias
sheet_name <- "Resumen"
reporte <- data.frame(region = ventas$region, 
                     ventas_totales = ventas$ventas_totales)

# Crear workbook con writexl
wb <- writexl()
wb$Sheet1 <- reporte
wb$OutputFile <- "reporte_r.xlsx"
wb$OutputSheet <- "Resumen"
write(xb, wb)

cat("Reporte creado exitosamente: reporte_r.xlsx\n")
cat("Hoja: ", sheet_name, "\n")
print(reporte)
