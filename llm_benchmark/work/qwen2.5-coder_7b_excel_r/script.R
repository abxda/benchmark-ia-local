library(writexl)

# Leer el archivo CSV
datos <- read.csv("ventas.csv")

# Calcular la suma de ventas por región
resumen <- aggregate(ventas ~ region, data = datos, sum)

# Escribir el resumen en un archivo Excel
write_xlsx(resumen, "reporte_r.xlsx", sheet = "Resumen")
