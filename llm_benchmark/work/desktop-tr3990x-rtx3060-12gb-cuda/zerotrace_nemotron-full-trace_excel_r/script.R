# Script R para leer ventas.csv y crear reporte_r.xlsx

# Cargar paquetes necesarios
library(openxlsx)

# Leer el archivo CSV
datos <- read.csv("ventas.csv", header = TRUE)

# Calcular ventas totales por región
resumen <- aggregate(ventas ~ region, data = datos, sum)

# Renombrar la columna de ventas a 'ventas_totales'
colnames(resumen)[2] <- "ventas_totales"

# Crear libro de Excel y agregar hoja 'Resumen'
wb <- createWorkbook()
addWorksheet(wb, "Resumen")
writeData(wb, resumen, sheet = "Resumen", startRow = 1, startCol = 1)

# Guardar el archivo
saveWorkbook(wb, "reporte_r.xlsx", overwrite = TRUE)