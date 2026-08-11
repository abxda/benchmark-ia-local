#!/usr/bin/env python3
"""Script que lee ventas.csv y genera reporte.xlsx con resumen por region."""

import pandas as pd

def main():
    # Leer el CSV
    df = pd.read_csv('ventas.csv')

    # Calcular la suma de ventas por region
    resumen = df.groupby('region')['ventas'].sum().reset_index()
    resumen.columns = ['region', 'ventas_totales']

    # Crear el archivo Excel con la hoja 'Resumen'
    with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
        resumen.to_excel(writer, sheet_name='Resumen', index=False)

if __name__ == '__main__':
    main()