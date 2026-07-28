import pandas as pd

def main():
    try:
        # Leer el archivo CSV
        df = pd.read_csv('ventas.csv')
        
        # Agrupar por región y sumar las ventas
        resumen = df.groupby('region')['ventas'].sum().reset_index()
        
        # Renombrar la columna de ventas a ventas_totales
        resumen = resumen.rename(columns={'ventas': 'ventas_totales'})
        
        # Crear el archivo Excel con la hoja 'Resumen'
        with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
            resumen.to_excel(writer, sheet_name='Resumen', index=False)
            
        print("Archivo 'reporte.xlsx' creado con éxito.")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
