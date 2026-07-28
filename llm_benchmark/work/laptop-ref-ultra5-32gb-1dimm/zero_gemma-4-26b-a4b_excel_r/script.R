# Cargar librerías necesarias
library(readr)
library(dplyr)
library(writexl)

# Leer el archivo CSV
df <- read_csv("ventas.csv")

# Realizar la agregación
resumen <- df %>%
  group_by(region) %>%
  summarise(ventas_totales = sum(ventas, na.rm = TRUE)) %>%
  ungroup()

# Escribir el archivo Excel con la hoja 'Resumen'
# Nota: writexl usa el nombre del dataframe como nombre de la hoja si se pasa una lista
write_xlsx(list(Resumen = resumen), "reporte_r.xlsx")

cat("Proceso completado con éxito.\n")
