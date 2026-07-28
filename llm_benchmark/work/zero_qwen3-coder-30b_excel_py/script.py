import pandas as pd

# Leer el archivo ventas.csv
df = pd.read_csv('ventas.csv')

# Agrupar por región y sumar las ventas
resumen = df.groupby('region')['ventas'].sum().reset_index()

# Renombrar la columna de ventas para que se llame 'ventas_totales'
resumen = resumen.rename(columns={'ventas': 'ventas_totales'})

# Crear un archivo Excel con una hoja llamada 'Resumen'
with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
    resumen.to_excel(writer, sheet_name='Resumen', index=False)

print("Archivo 'reporte.xlsx' generado exitosamente.")