import pandas as pd
from openpyxl import Workbook

df = pd.read_csv('ventas.csv')
resumen = df.groupby('region', as_index=False)['ventas'].sum()
resumen.columns = ['region', 'ventas_totales']

wb = Workbook()
ws = wb.active
ws.title = 'Resumen'
ws.append(list(resumen.columns))
for _, row in resumen.iterrows():
    ws.append(list(row))

wb.save('reporte.xlsx')
