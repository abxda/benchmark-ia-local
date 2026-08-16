# Script: leer ventas.csv y generar reporte_r.xlsx
# Hoja 'Resumen' con columnas: region, ventas_totales

library(writexl)

# Leer el CSV
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Sumar ventas por region (una fila por region)
resumen <- aggregate(ventas ~ region, data = ventas, FUN = sum)[, c("region", "ventas")]
colnames(resumen) <- c("region", "ventas_totales")

# Ordenar por region para estabilidad
resumen <- resumen[order(resumen$region), ]

# Escribir Excel
writexl::write_xlsx(list("Resumen" = resumen), "reporte_r.xlsx")

cat("Reporte generado: reporte_r.xlsx\n")
