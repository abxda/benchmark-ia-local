import pandas as pd

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Agrupar por región y sumar las ventas
resumen = df.groupby('region')['ventas'].sum().reset_index()
resumen.columns = ['region', 'ventas_totales']

# Crear un archivo Excel con la hoja 'Resumen'
with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
    resumen.to_excel(writer, sheet_name='Resumen', index=False)
