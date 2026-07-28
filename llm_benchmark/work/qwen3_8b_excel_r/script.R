library(writexl)
ventas <- read_csv("ventas.csv")
ventas_agrupadas <- ventas %>% group_by(region) %>% summarise(ventas_totales = sum(ventas))
write_xlsx(ventas_agrupadas, path = "reporte_r.xlsx", sheet = "Resumen")
