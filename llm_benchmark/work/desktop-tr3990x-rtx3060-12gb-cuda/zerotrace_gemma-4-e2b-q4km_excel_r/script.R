# script.R

library(readr)
library(writexl)
library(dplyr)

# 1. Read the data
data <- read_csv("ventas.csv")

# 2. Calculate total sales per region
summary_data <- data %>%
  group_by(region) %>%
  summarise(ventas_totales = sum(ventas, na.rm = TRUE)) %>%
  ungroup()

# 3. Write the summary to an Excel file
write_xlsx(summary_data, "reporte_r.xlsx", sheet = "Resumen")

cat("Reporte generado exitosamente como reporte_r.xlsx con la hoja 'Resumen'.\n")