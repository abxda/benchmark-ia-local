import pandas as pd

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Agrupar por región y sumar las ventas
resumen = df.groupby('region')['ventas'].sum().reset_index()

# Renombrar la columna de ventas para que coincida con el requerimiento
resumen = resumen.rename(columns={'ventas': 'ventas_totales'})

# Guardar en un archivo Excel con una hoja llamada 'Resumen'
resumen.to_excel('reporte.xlsx', sheet_name='Resumen', index=False)

print("Archivo 'reporte.xlsx' creado exitosamente con el resumen de ventas por región.")