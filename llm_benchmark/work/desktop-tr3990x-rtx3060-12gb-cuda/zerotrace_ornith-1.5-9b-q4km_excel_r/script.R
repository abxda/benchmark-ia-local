# Leer ventas.csv y crear reporte_r.xlsx con resumen de ventas por region
library(writexl)

# Leer el archivo CSV
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Calcular la suma de ventas por region
resumen <- aggregate(ventas ~ region, data = ventas, FUN = sum)
names(resumen)[2] <- "ventas_totales"

# Mostrar el resumen
print(resumen)

# Crear el archivo Excel con la hoja 'Resumen'.
# En writexl 2.0.0 el nombre de la hoja se deriva del nombre del archivo,
# asi que se escribe como "Resumen.xlsx" y luego se copia a "reporte_r.xlsx"
write_xlsx(resumen, "Resumen.xlsx")
file.copy("Resumen.xlsx", "reporte_r.xlsx", overwrite = TRUE)

cat("Archivo creado: reporte_r.xlsx\n")
