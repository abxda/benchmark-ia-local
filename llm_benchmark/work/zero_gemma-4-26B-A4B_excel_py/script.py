import pandas as pd

def main():
    # Leer el archivo ventas.csv
    df = pd.read_csv('ventas.csv')
    
    # Agrupar por region y sumar ventas
    resumen = df.groupby('region')['ventas'].sum().reset_index()
    
    # Renombrar la columna de ventas a ventas_totales
    resumen.rename(columns={'ventas': 'ventas_totales'}, inplace=True)
    
    # Crear el archivo Excel con la hoja 'Resumen'
    with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
        resumen.to_excel(writer, sheet_name='Resumen', index=False)
    
    print("Archivo 'reporte.xlsx' creado exitosamente con la hoja 'Resumen'.")

if __name__ == "__main__":
    main()
