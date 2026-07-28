import pandas as pd

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Agrupar por 'region' y sumar las 'ventas'
resumen = df.groupby('region')['ventas'].sum().reset_index()

# Crear un nuevo ExcelWriter usando openpyxl como motor de escritura
with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
    resumen.to_excel(writer, sheet_name='Resumen', index=False)
