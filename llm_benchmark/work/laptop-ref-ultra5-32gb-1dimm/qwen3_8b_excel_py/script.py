import pandas as pd

df = pd.read_csv('ventas.csv')
ventas_por_region = df.groupby('region')['ventas'].sum().reset_index()
ventas_por_region.to_excel('reporte.xlsx', sheet_name='Resumen', index=False, header=['region', 'ventas_totales'])
