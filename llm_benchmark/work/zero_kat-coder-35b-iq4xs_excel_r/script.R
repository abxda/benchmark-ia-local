# Leer ventas.csv y crear reporte Excel con resumen por región
library(writexl)

df <- read.csv("ventas.csv", stringsAsFactors = FALSE)
summary <- aggregate(ventas ~ region, data = df, FUN = sum)
names(summary) <- c("region", "ventas_totales")
write_xlsx(summary, path = "reporte_r.xlsx")
print(summary)
cat("Archivo creado: reporte_r.xlsx\n")
