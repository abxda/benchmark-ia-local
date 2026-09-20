import pandas as pd

# Leer el CSV
df = pd.read_csv('ventas.csv')

# Sumar ventas por region
resumen = df.groupby('region')['ventas'].sum().reset_index()
resumen.columns = ['region', 'ventas_totales']

# Guardar como Excel con una hoja 'Resumen'
resumen.to_excel('reporte.xlsx', index=False, sheet_name='Resumen')

print('Reporte creado exitosamente')