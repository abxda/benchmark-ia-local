library(readxl)
library(writexl)

# Leer los datos desde 'ventas.csv'
datos <- read_csv("ventas.csv", col_types = cols(region = "text", mes = "date", ventas = "double"))

# Calcular la suma de ventas por región
resumen_ventas <- aggregate(ventas ~ region, data = datos, FUN = sum)

# Renombrar las columnas para coincidir con el requerimiento (region y ventas_totales)
nombres_columnes_resumen <- c("region", "ventas_totales")
colnames(resumen_ventas) <- nombres_columnes_resumen

# Crear un nuevo dataframe limpio solo con estas dos columnas si es necesario, 
# aunque aggregate ya devuelve las correctas. Aseguramos el orden exacto de los datos.
resumen_final <- resumen_ventas[, c("region", "ventas_totales")]

# Escribir en Excel 'reporte_r.xlsx' con la hoja llamada 'Resumen'
writexl("reporte_r.xlsx", resumo_final, sheet_name = "Resumen")
