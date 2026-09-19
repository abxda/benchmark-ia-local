# Leer ventas.csv, agrupar por region y escribir reporte_r.xlsx (hoja 'Resumen')

library(readxl)
library(writexl)

# Leer el archivo de ventas desde el directorio actual
ventas <- read.csv("ventas.csv")

# Calcular la suma de ventas por region
resumen <- data.frame(
  region = names(tapply(ventas$ventas, ventas$region, sum)),
  ventas_totales = tapply(ventas$ventas, ventas$region, sum)
)

# Ordenar por region
resumen <- ordenar(resumen, by = 1)

# Escribir el archivo Excel
write_xlsx(resumen, path = "reporte_r.xlsx", sheet = "Resumen")

cat("Archivo reporte_r.xlsx generado correctamente.\n")
cat("Contenido de la hoja 'Resumen':\n")
print(resumen)
