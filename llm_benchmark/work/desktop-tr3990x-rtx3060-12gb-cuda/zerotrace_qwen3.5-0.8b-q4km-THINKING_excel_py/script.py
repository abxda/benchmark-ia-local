import pandas as pd
from openpyxl import load_workbook
import os

# Read the CSV file
df = pd.read_csv('/mnt/data_4tb/IA-Local/benchmark-ia-local/llm_benchmark/work/desktop-tr3990x-rtx3060-12gb-cuda/zerotrace_qwen3.5-0.8b-q4km-THINKING_excel_py/ventas.csv')

# Merge by region to get total sales
df['region'] = df['region'].astype(str)
df['ventas_totales'] = df.groupby('region')['ventas'].sum()

# Write to Excel file
wb = load_workbook('/mnt/data_4tb/IA-Local/benchmark-ia-local/llm_benchmark/work/desktop-tr3990x-rtx3060-12gb-cuda/zerotrace_qwen3.5-0.8b-q4km-THINKING_excel_py/reporte.xlsx')
ws = wb.active
sheet = ws.active_sheet  # Fixed: active_sheet instead of activeSheet
sheet.clear()
sheet.append(df.to_excel('/mnt/data_4tb/IA-Local/benchmark-ia-local/llm_benchmark/work/desktop-tr3990x-rtx3060-12gb-cuda/zerotrace_qwen3.5-0.8b-q4km-THINKING_excel_py/reporte.xlsx', sheet_name='Resumen', excel_write=True))
wb.save('/mnt/data_4tb/IA-Local/benchmark-ia-local/llm_benchmark/work/desktop-tr3990x-rtx3060-12gb-cuda/zerotrace_qwen3.5-0.8b-q4km-THINKING_excel_py/reporte.xlsx')
