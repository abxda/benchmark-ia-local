import pandas as pd

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Agrupar por región y sumar las ventas
resumen = df.groupby('region')['ventas'].sum().reset_index()
resumen.columns = ['region', 'ventas_totales']

# Crear archivo Excel con la hoja 'Resumen'
resumen.to_excel('reporte.xlsx', sheet_name='Resumen', index=False)
