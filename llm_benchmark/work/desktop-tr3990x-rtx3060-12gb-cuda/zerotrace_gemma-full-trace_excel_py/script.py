import pandas as pd

def main():
    # Leer el archivo CSV
    try:
        df = pd.read_csv('ventas.csv')
    except FileNotFoundError:
        print("Error: El archivo 'ventas.csv' no existe.")
        return

    # Agrupar por region y sumar las ventas
    resumen = df.groupby('region')['ventas'].sum().reset_index()
    
    # Renombrar la columna de ventas a ventas_totales
    resumen.columns = ['region', 'ventas_totales']

    # Guardar en un archivo Excel con una hoja llamada 'Resumen'
    try:
        with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
            resumen.to_excel(writer, sheet_name='Resumen', index=False)
        print("Archivo 'reporte.xlsx' creado exitosamente.")
    except Exception as e:
        print(f"Error al crear el archivo Excel: {e}")

if __name__ == "__main__":
    main()
