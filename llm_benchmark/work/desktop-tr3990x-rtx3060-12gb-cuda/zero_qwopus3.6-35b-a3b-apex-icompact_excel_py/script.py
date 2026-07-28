import pandas as pd

# Leer el CSV
df = pd.read_csv('ventas.csv')

# Agrupar por región y sumar ventas
resumen = df.groupby('region', as_index=False)['ventas'].sum()
resumen.columns = ['region', 'ventas_totales']

# Guardar en Excel con openpyxl
resumen.to_excel('reporte.xlsx', sheet_name='Resumen', index=False, engine='openpyxl')
print("reporte.xlsx generado correctamente.")
