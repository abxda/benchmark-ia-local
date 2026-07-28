library(writexl)
library(readxl)

# Leer el archivo CSV
datos <- read.csv("ventas.csv")

# Calcular ventas totales por región
resumen <- aggregate(ventas ~ region, data = datos, sum)

# Escribir en archivo Excel
write_xlsx(resumen, "reporte_r.xlsx", sheet = "Resumen")
