#!/usr/bin/env python3
"""Script para leer ventas.csv y generar el reporte Excel reporte.xlsx.

Intento:
- Leer ventas.csv con columnas: region, mes, ventas
- Calcular suma por region
- Crear archivo Excel reporte.xlsx con una hoja llamada 'Resumen'
- Filtrar exactamente dos columnas: region y ventas_totales
- Guardar con openpyxl

Nota: Esta es una implementación básica. Para el reporte completo
se necesitarían librerías adicionales como reportlab o reportable.
"""

import os
import sys
from pathlib import Path

# Importar pandas y openpyxl
try:
    import pandas as pd
    from openpyxl import load_workbook
    print("✓ pandas y openpyxl importados correctamente")
except ImportError as e:
    print(f"✗ Error al importar librerías: {e}")
    sys.exit(1)

# Verificar si el directorio existe
working_dir = Path.cwd()
if not working_dir.exists():
    print(f"✗ El directorio de trabajo {working_dir} no existe")
    sys.exit(1)

# Verificar si el archivo CSV existe
csv_path = working_dir / "ventas.csv"
if not csv_path.exists():
    print(f"✗ El archivo CSV {csv_path} no existe")
    sys.exit(1)

# Leer el CSV
print("⏹ Leer ventas.csv...")
try:
    df = pd.read_csv(csv_path)
    print("✓ CSV leer exitoso")
except Exception as e:
    print(f"✗ Error al leer el CSV: {e}")
    sys.exit(1)

# Crear DataFrame
df = pd.DataFrame(df)

# Crear DataFrame
# Usar 'region' como columna para usar la primera columna
df = df[['region', 'ventas_totales']]

# Crear hoja Excel
wb = load_workbook('reporte.xlsx')
ws = wb.active

# Crear hoja nueva
ws.new_sheet('Resumen')

# Crear columnas nuevas
ws.cell('region').value = df['region'].tolist()
ws.cell('ventas_totales').value = df['ventas_totales'].tolist()

# Guardar el archivo
wb.save(working_dir / 'reporte.xlsx')
print(f"✓ Reporte Excel creado: {working_dir / 'reporte.xlsx'}")
print(f"  - Folha: 'Resumen'")
print(f"  - Columnas: 'region' y 'ventas_totales'")

# Verificar resultados
print("\n" + "="*60)
print("VERIFICACIÓN DEL RESULTADO")
print("="*60)
print(f"\\nVentas totales por región: {df['ventas_totales'].tolist()}")
print(f"\\nTotal de ventas: {df['ventas_totales'].sum()}")
print(f"\\nTotal de filas: {len(df)}")

# Verificar columnas
print(f"\\nColumnas de la hoja 'Resumen':")
print(f"  - region: {ws.column('region').name}")
print(f"  - ventas_totales: {ws.column('ventas_totales').name}")

# Verificar tipos de datos
print(f"\\nTipos de datos:")
print(f"  - region: {df['region'].dtype}")
print(f"  - ventas_totales: {df['ventas_totales'].dtype}")

# Verificar tipos de datos en las columnas originales
print(f"\\nColumnas originales:")
print(f"  - ventas: {df['ventas'].dtype}")
print(f"  - region: {df['region'].dtype}")
print(f"  - mes: {df['mes'].dtype}")

print("\n" + "="*60)
print("PROCESO COMPLETO")
print("="*60)
