# Verificación del archivo Excel generado
library(openxlsx)

# Leer el archivo Excel creado
data <- read.xlsx("reporte_r.xlsx", sheet = "Resumen")
print("Contenido del archivo Excel:")
print(data)

# Verificar que tenga las columnas correctas
print("Nombres de columnas:")
print(colnames(data))

# Verificar que tenga 5 filas (una por región)
print(paste("Número de filas:", nrow(data)))