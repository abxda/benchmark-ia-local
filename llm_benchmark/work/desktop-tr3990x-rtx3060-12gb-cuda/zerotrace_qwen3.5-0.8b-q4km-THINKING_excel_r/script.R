# Script para generar el reporte de ventas por región
# Lectura del archivo ventas.csv
# Agrupación por región
# Generación de Excel con hoja 'Resumen'
# columnas: region, ventas_totales

# Variables
region_list <- c()
for (row in read.csv("mercados")) {
  region <- row$region
  sales <- row$ventas
  if (!is.na(sales)) {
    region_list <- c(region_list, region)
  }
}

# Cálculo de ventas totales por región
by_region <- aggregate(sales ~ region, data = region_list, types = "int")

# Preparación del archivo de Excel
out <- write.xlsx("reporte_r.xlsx", 
                   sheet = "Resumen",
                   sheet_header = TRUE,
                   sheet_rows = 0,
                   sheet_cols = 0,
                   sheet_cols_min = 3,
                   sheet_cols_max = 100,
                   sheet_columns = "region, ventas_totales",
                   sheet_rows = 1,
                   sheet_rows_max = 10,
                   sheet_rows_min = 1,
                   sheet_rows_max = 20)

# Verificación
cat("Archivo Excel creado: reporte_r.xlsx\n")
cat("Columnas del archivo:\n")
for (col in names(out)) {
  cat(sprintf("  %s: %s\n", col, paste(out$sheet_cols[col], collapse = ", ")))
}

# Mostrar resumen del archivo
print(as.data.frame(out, sheet = "Resumen", sheet_rows = 1, sheet_rows_min = 1))

# Verificar que el archivo Excel fue creado correctamente
if (!file.exists("reporte_r.xlsx")) {
  cat("❌ ERROR: El archivo reporte_r.xlsx no se creó correctamente\n")
  quit()
}
