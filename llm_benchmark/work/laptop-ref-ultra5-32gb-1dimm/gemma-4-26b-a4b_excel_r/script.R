library(readxl)
library(writexl)
library(dplyr)

# Leer el archivo CSV
df <- read.csv("ventas.csv")

# Procesar los datos: sumar ventas por región
resumen <- df %>%
  group_by(region) %>%
  summarise(ventas_totales = sum(ventas, na.rm = TRUE)) %>%
  ungroup()

# Crear el archivo Excel con la hoja 'Resumen'
# Nota: writexl usa el nombre del objeto como nombre de hoja por defecto si se pasa una lista
write_xlsx(list(Resumen = resumen), "reporte_r.xlsx")
