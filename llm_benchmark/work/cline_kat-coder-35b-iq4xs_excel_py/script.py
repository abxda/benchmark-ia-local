import pandas as pd

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Agrupar ventas por región
resultado = df.groupby('region', as_index=False)['ventas'].sum()
resultado.columns = ['region', 'ventas_totales']

# Guardar en Excel con openpyxl
resultado.to_excel('reporte.xlsx', sheet_name='Resumen', index=False, engine='openpyxl')

print("Archivo generado exitosamente: reporte.xlsx")
print(resultado.to_string(index=False))
