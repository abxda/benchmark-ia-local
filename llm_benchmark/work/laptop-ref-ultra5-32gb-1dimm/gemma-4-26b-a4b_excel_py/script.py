import pandas as pd

def generar_reporte():
    try:
        # Leer el archivo CSV
        df = pd.read_csv('ventas.csv')

        # Agrupar por región y sumar las ventas
        resumen = df.groupby('region')['ventas'].sum().reset_index()

        # Renombrar columnas según el requerimiento
        resumen.columns = ['region', 'ventas_totales']

        # Crear el archivo Excel con la hoja 'Resumen'
        with pd.ExcelWriter('reporte.xlsx', engine='openpyxl') as writer:
            resumen.to_excel(writer, sheet_name='Resumen', index=False)
            
    except FileNotFoundError:
        print("Error: El archivo 'ventas.csv' no existe.")
    except Exception as e:
        print(f"Error inesperado: {e}")

if __name__ == "__main__":
    generar_reporte()
