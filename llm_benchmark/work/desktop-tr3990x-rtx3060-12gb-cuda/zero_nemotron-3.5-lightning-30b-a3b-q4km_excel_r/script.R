#!/usr/bin/env Rscript
library(readxl)
library(writexl)

# Leer el archivo CSV del directorio actual
datos <- read.csv("ventas.csv", header = TRUE)

# Calcular la suma de ventas por region
resumen <- aggregate(ventas ~ region, data = datos, sum)

# Renombrar la columna de suma para que coincida con lo pedido
names(resumen)[2] <- "ventas_totales"

# Crear el archivo Excel con la hoja 'Resumen'
# writexl usa listas nombadas: el nombre de la lista es el nombre de la hoja
write_xlsx(list(Resumen = resumen), "reporte_r.xlsx")