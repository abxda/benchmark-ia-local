# Script R para generar reporte_r.xlsx
# Lee ventas.csv y crea Resumen con region y ventas_totales (suma por region)

# Leer el CSV
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Calcular ventas totales por region
resumen <- aggregate(ventas ~ region, data = ventas, sum)
# Renombrar la columna de ventas a ventas_totales
colnames(resumen) <- c("region", "ventas_totales")

# Escribir el Excel usando writexl
library(writexl)
writexl::write_xlsx(resumen, "reporte_r.xlsx", sheetName = "Resumen")

cat("Script ejecutado con éxito.\n")
cat("Contenido del resumen:\n")
print(resumen)