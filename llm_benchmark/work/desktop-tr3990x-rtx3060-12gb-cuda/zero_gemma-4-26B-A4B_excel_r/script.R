# script.R

# Cargar las librerías necesarias
if (!requireNamespace("writexl", quietly = TRUE)) install.packages("writexl")
if (!requireNamespace("readr", quietly = TRUE)) install.packages("readr")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")

library(readr)
library(dplyr)
library(writexl)

# Leer el archivo ventas.csv
ventas_df <- read_csv("ventas.csv")

# Calcular la suma de ventas por región
resumen <- ventas_df %>%
  group_by(region) %>%
  summarise(ventas_totales = sum(ventas, na.rm = TRUE)) %>%
  ungroup()

# Crear una lista con el dataframe y el nombre de la hoja
lista_hojas <- list("Resumen" = resumen)

# Escribir el archivo Excel
write_xlsx(lista_hojas, "reporte_r.xlsx")

cat("Proceso completado con éxito. Archivo 'reporte_r.xlsx' creado.\n")
