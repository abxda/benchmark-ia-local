#!/usr/bin/env python3
import pandas as pd

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Calcular la suma de ventas por region
resumen = df.groupby('region')['ventas'].sum().reset_index()
resumen.columns = ['region', 'ventas_totales']

# Guardar en un archivo Excel con la hoja 'Resumen'
resumen.to_excel('reporte.xlsx', sheet_name='Resumen', index=False)

print("Archivo reporte.xlsx creado exitosamente.")