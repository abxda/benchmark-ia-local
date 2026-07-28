# Script R: resumen de ventas por región

library(writexl)

# Leer datos
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Agrupar por región y sumar ventas
resumen <- aggregate(ventas ~ region, data = ventas, FUN = sum)
names(resumen) <- c("region", "ventas_totales")

# Guardar como Excel
write_xlsx(resumen, "reporte_r.xlsx")

cat("Reporte generado exitosamente.\n")
