# Script de R para generar el reporte de ventas y verificar
# Este script lee ventas.csv y genera reporte_r.xlsx usando openxlsx

# Asegurarse de que los paquetes están instalados
if (!requireNamespace("readr", quietly = TRUE)) {
  install.packages("readr")
}
if (!requireNamespace("openxlsx", quietly = TRUE)) {
  install.packages("openxlsx")
}
library(readr)
library(openxlsx)

# 1. Leer el archivo CSV
tryCatch({
  ventas_data <- read_csv("ventas.csv")
}, error = function(e) {
  stop(paste("Error al leer ventas.csv:", e$message))
})

# 2. Calcular la suma de ventas por región
# Columnas esperadas: region, mes, ventas
# Agrupamos por region y sumamos ventas
reporte_resumen <- aggregate(ventas ~ region, data = ventas_data, FUN = sum)
# Renombrar la columna de ventas sumadas a ventas_totales
colnames(reporte_resumen)[colnames(reporte_resumen) == "ventas"] <- "ventas_totales"

# 3. Crear el archivo Excel
output_filename <- "reporte_r.xlsx"
sheet_name <- "Resumen"

tryCatch({
  # Crear un libro de trabajo
  wb <- createWorkbook()
  # Añadir la hoja y escribir los datos
  addWorksheet(wb, sheetName = sheet_name)
  writeData(wb, sheet = sheet_name, x = reporte_resumen)
  # Guardar el libro de trabajo
  saveWorkbook(wb, file = output_filename)
  print("--- Generación Exitosa ---")
  print(paste("Reporte generado exitosamente:", output_filename))

  # 4. Verificación
  print("--- Verificación ---")
  # Leer el archivo que acabamos de crear para verificar su contenido
  wb_verify <- loadWorkbook(output_filename)
  
  # Verificar nombre de hoja
  sheet_names <- getSheetNames(wb_verify)
  print(paste("Nombres de hojas encontradas:", paste(sheet_names, collapse=", ")))
  
  # Verificar contenido de la hoja 'Resumen'
  data_verified <- getSheetData(wb_verify, sheet = sheet_name)
  
  # Verificar columnas: debe tener 'region' y 'ventas_totales'
  col_names <- colnames(data_verified)
  print(paste("Columnas en la hoja 'Resumen':", paste(col_names, collapse=", ")))
  
  # Verificar el contenido (primera fila de datos)
  print("Primeras filas de la hoja 'Resumen' (datos):")
  print(head(data_verified))
  
  # Devolver el libro de trabajo para asegurar que el proceso finaliza
  detachWorkbook(wb_verify)
  
}, error = function(e) {
  stop(paste("Error durante la generación/verificación del Excel:", e$message))
})