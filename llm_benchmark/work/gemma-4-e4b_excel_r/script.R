library(readr)
library(writexl)
library(dplyr)

# Leer el archivo CSV
ventas_data <- read_csv("ventas.csv")

# Calcular la suma de ventas por región
resumen_ventas <- ventas_data %>%
  group_by(region) %>%
  summarise(ventas_totales = sum(ventas)) %>%
  ungroup()

# Crear el archivo Excel
write_xlsx(resumen_ventas, "reporte_r.xlsx", sheet_name = "Resumen")
