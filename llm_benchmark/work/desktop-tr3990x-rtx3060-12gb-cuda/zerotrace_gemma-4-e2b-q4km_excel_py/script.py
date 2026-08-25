import pandas as pd
import openpyxl

# 1. Read the CSV file
try:
    df = pd.read_csv('ventas.csv')
except FileNotFoundError:
    print("Error: 'ventas.csv' not found. Please ensure the file is in the current directory.")
    exit(1)
except Exception as e:
    print(f"Error reading CSV: {e}")
    exit(1)

# Ensure required columns exist
required_cols = ['region', 'mes', 'ventas']
if not all(col in df.columns for col in required_cols):
    print(f"Error: 'ventas.csv' must contain columns: {required_cols}")
    exit(1)

# 2. Calculate total sales per region
# Assuming 'ventas' column contains numerical data that can be summed.
regional_summary = df.groupby('region')['ventas'].sum().reset_index()
regional_summary.rename(columns={'ventas': 'ventas_totales'}, inplace=True)

# 3. Create or load the Excel file
output_file = 'reporte.xlsx'
try:
    # Create a new workbook
    workbook = openpyxl.Workbook()
    # Select the active sheet and rename it to 'Resumen'
    sheet = workbook.active
    sheet.title = 'Resumen'

    # Write data to the sheet
    # Write headers
    headers = ['region', 'ventas_totales']
    sheet.append(headers)

    # Write data rows
    for index, row in regional_summary.iterrows():
        sheet.append([row['region'], row['ventas_totales']])

    # Save the workbook
    workbook.save(output_file)
    print(f"Successfully created report: {output_file}")

except Exception as e:
    print(f"Error writing Excel file: {e}")
    exit(1)