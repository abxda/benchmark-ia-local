library(writexl)
library(dplyr)

ventas <- read.csv("ventas.csv")
resumen <- ventas %>%
  group_by(region) %>%
  summarise(ventas_totales = sum(ventas)) %>%
  ungroup()

write_xlsx(resumen, "reporte_r.xlsx", sheet_name = "Resumen")
