library(readxl)
library(writexl)

datos <- read.csv("ventas.csv", stringsAsFactors = FALSE)
ventas_totales <- aggregate(ventas ~ region, data = datos, FUN = sum)
colnames(ventas_totales) <- c("region", "ventas_totales")
write_xlsx(ventas_totales, "reporte_r.xlsx", sheet_name = "Resumen")
