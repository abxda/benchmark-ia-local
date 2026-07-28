# Script R: Lee ventas.csv y genera reporte_r.xlsx con resumen por región
# Usamos writexl (ya instalado) para escribir el Excel

# Cargar librería
library(writexl)

# Leer el CSV
df <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Agrupar ventas por región
resumen <- aggregate(ventas ~ region, data = df, FUN = sum)
names(resumen)[names(resumen) == "ventas"] <- "ventas_totales"

# Escribir Excel
write_xlsx(list("Resumen" = resumen), path = "reporte_r.xlsx")
