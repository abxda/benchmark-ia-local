import pandas as pd
from openpyxl import Workbook
from openpyxl.utils.dataframe import dataframe_to_rows

# Leer el archivo CSV
ventas = pd.read_csv("ventas.csv")

# Calcular las ventas totales por región
ventas_totales = ventas.groupby('region')['ventas'].sum().reset_index()
ventas_totales.columns = ['region', 'ventas_totales']

# Crear un nuevo archivo Excel con una hoja llamada 'Resumen'
wb = Workbook()
ws = wb.active
ws.title = "Resumen"

# Agregar los datos al archivo Excel
for r in dataframe_to_rows(ventas_totales, index=False, header=True):
    ws.append(r)

# Guardar el archivo Excel
wb.save("reporte_r.xlsx")

print("Archivo reporte_r.xlsx generado correctamente.")