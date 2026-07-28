library(openxlsx)

# Leer el CSV
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Agrupar ventas por región
ventas_totales <- aggregate(ventas ~ region, data = ventas, FUN = sum)
names(ventas_totales)[2] <- "ventas_totales"

# Crear workbook con hoja "Resumen"
wb <- createWorkbook()
addWorksheet(wb, "Resumen")
writeData(wb, "Resumen", ventas_totales)
saveWorkbook(wb, "reporte_r.xlsx", overwrite = TRUE)

cat("Hecho. Archivo 'reporte_r.xlsx' generado.\n")
