library(writexl)
library(readxl)

# Leer el archivo CSV
datos <- read_excel("ventas.csv")

# Calcular ventas totales por región
resumen <- aggregate(ventas ~ region, data = datos, sum)

# Crear el archivo Excel con la hoja "Resumen"
write_xlsx(list("Resumen" = resumen), "reporte_r.xlsx")
