import pandas as pd

try:
    # Leer el archivo CSV
    df_ventas = pd.read_csv('ventas.csv')

    # Calcular la suma de ventas por región
    df_resumen = df_ventas.groupby('region')['ventas'].sum().reset_index()
    df_resumen.rename(columns={'ventas': 'ventas_totales'}, inplace=True)

    # Crear el archivo Excel
    output_filename = 'reporte.xlsx'
    output_sheet_name = 'Resumen'

    # Escribir el DataFrame de resumen en el archivo Excel
    with pd.ExcelWriter(output_filename, engine='openpyxl') as writer:
        df_resumen.to_excel(writer, sheet_name=output_sheet_name, index=False)

    print(f"Reporte generado exitosamente en '{output_filename}' con la hoja '{output_sheet_name}'.")

except FileNotFoundError:
    print("Error: El archivo 'ventas.csv' no fue encontrado en el directorio actual.")
except Exception as e:
    print(f"Ocurrió un error: {e}")
