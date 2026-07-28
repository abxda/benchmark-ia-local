import pandas as pd
import openpyxl

def generar_reporte(archivo_entrada, archivo_salida, hoja_nombre):
    """
    Lee ventas.csv, calcula las ventas totales por región y guarda el resumen en un archivo Excel.
    """
    try:
        # 1. Leer el archivo CSV
        df_ventas = pd.read_csv(archivo_entrada)
        
        # 2. Calcular la suma de ventas por región
        # Asumiendo que las columnas son 'region', 'mes', 'ventas'
        try:
            ventas_totales = df_ventas.groupby('region')['ventas'].sum().reset_index()
            ventas_totales.columns = ['region', 'ventas_totales']
        except KeyError as e:
            print(f"Error: La columna esperada no fue encontrada en {archivo_entrada}. Asegúrate de que existen 'region', 'mes', y 'ventas'. Error: {e}")
            return False

        # 3. Guardar en un archivo Excel
        try:
            # Usamos pandas para escribir el DataFrame en Excel, que maneja openpyxl por defecto
            with pd.ExcelWriter(archivo_salida, engine='openpyxl') as writer:
                ventas_totales.to_excel(writer, sheet_name=hoja_nombre, index=False)
            
            print(f"Éxito: El reporte ha sido creado en '{archivo_salida}' en la hoja '{hoja_nombre}'.")
            return True
        except Exception as e:
            print(f"Error al escribir el archivo Excel: {e}")
            return False

    except FileNotFoundError:
        print(f"Error: El archivo de entrada '{archivo_entrada}' no fue encontrado.")
        return False
    except Exception as e:
        print(f"Ocurrió un error inesperado: {e}")
        return False

if __name__ == "__main__":
    INPUT_FILE = 'ventas.csv'
    OUTPUT_FILE = 'reporte.xlsx'
    SHEET_NAME = 'Resumen'
    
    # Verificar si pandas y openpyxl están instalados (aunque se espera que sí)
    try:
        import pandas
        import openpyxl
    except ImportError:
        print("Error: Pandas o openpyxl no están instalados. Por favor, ejecuta 'pip install pandas openpyxl'")
        exit(1)
        
    if generar_reporte(INPUT_FILE, OUTPUT_FILE, SHEET_NAME):
        print("Proceso completado con éxito.")
    else:
        print("Proceso fallido. Revisar errores anteriores.")