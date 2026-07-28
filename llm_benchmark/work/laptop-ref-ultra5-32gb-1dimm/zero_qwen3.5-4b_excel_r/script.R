# Script R para generar reporte de ventas por region
# Lee ventas.csv y crea un Excel con suma de ventas por region

# Cargar paquetes
library("writexl")
library("readxl")

# Leer el archivo CSV usando la función base R
ventas <- read.csv("ventas.csv")

# Sumar ventas por region
ventas_por_region <- tapply(ventas$ventas, ventas$region, sum)

# Convertir a data frame
resumen <- data.frame(
  region = names(ventas_por_region),
  ventas_totales = as.numeric(ventas_por_region)
)

# Verificar los resultados
cat("Resultados intermedios:\n")
print(resumen)

# Escribir al Excel con hoja llamada 'Resumen' usando writexl
writexl(resumen, file = "reporte_r.xlsx", sheet_name = "Resumen")

cat("\nReporte generado exitosamente: reporte_r.xlsx\n")
cat("Contenido de la hoja 'Resumen':\n")
print(resumen)
