import pandas as pd
from openpyxl import Workbook

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Calcular la suma de ventas por región
df_agregado = df.groupby('region')['ventas'].sum().reset_index()
df_agregado.columns = ['region', 'ventas_totales']

# Crear el archivo Excel con una hoja llamada 'Resumen'
with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
    df_agregado.to_excel(writer, sheet_name='Resumen', index=False)

print("Reporte generado exitosamente: reporte.xlsx")
print(f"Total de regiones: {len(df_agregado)}")
print("\nContenido del reporte:")
print(df_agregado.to_string())
