# script.R

# Cargar librerías necesarias
if (!requireNamespace("readxl", quietly = TRUE)) install.packages("readxl", repos='http://cran.us.r-project.org')
if (!requireNamespace("writexl", quietly = TRUE)) install.packages("writexl", repos='http://cran.us.r-project.org')

library(readxl)
library(writexl)

# 1. Leer el archivo ventas.csv
# Usamos read.csv de base para asegurar compatibilidad simple con el archivo proporcionado
df <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# 2. Procesar los datos: sumar ventas por region
# Usamos aggregate para evitar dependencias pesadas como dplyr si no es necesario,
# aunque dplyr es común, aggregate es base R y muy robusto para este caso.
resumen <- aggregate(ventas ~ region, data = df, FUN = sum)

# Renombrar la columna de ventas a ventas_totales
colnames(resumen)[colnames(resumen) == "ventas"] <- "ventas_totales"

# 3. Crear el archivo Excel con la hoja 'Resumen'
# writexl::write_xlsx acepta una lista de dataframes donde cada elemento es una hoja.
write_xlsx(list(Resumen = resumen), "reporte_r.xlsx")

cat("Script ejecutado con éxito. Archivo 'reporte_r.xlsx' creado.\n")
