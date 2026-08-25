import pandas as pd

# Leer el archivo de ventas
df = pd.read_csv("ventas.csv")

# Agrupar por region y sumar las ventas
resumen = df.groupby("region")["ventas"].sum().reset_index()
resumen = resumen.rename(columns={"ventas": "ventas_totales"})
resumen = resumen[["region", "ventas_totales"]]

# Escribir el resultado en un archivo Excel
with pd.ExcelWriter("reporte.xlsx", engine="openpyxl") as writer:
    resumen.to_excel(writer, sheet_name="Resumen")

print("Archivo 'reporte.xlsx' creado exitosamente.")
print(resumen)
