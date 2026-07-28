import pandas as pd

df = pd.read_csv('ventas.csv')
resumen = df.groupby('region', as_index=False)['ventas'].sum()
resumen.to_excel('reporte.xlsx', sheet_name='Resumen', index=False)
