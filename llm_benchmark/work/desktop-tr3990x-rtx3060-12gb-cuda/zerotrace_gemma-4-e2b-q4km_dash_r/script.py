import pandas as pd
import matplotlib.pyplot as plt
import os

# 1. Read the data
try:
    data = pd.read_csv('ventas.csv')
except FileNotFoundError:
    print("Error: ventas.csv not found. Please ensure the file is in the current directory.")
    exit()

# Ensure 'mes' is treated as a categorical/factor for correct plotting
data['mes'] = data['mes'].astype('category')

# --- Plot 1: Bar chart of total sales by region ---
plt.figure(figsize=(8, 5))
region_sales = data.groupby('region')['ventas'].sum().sort_values(ascending=False)
region_sales.plot(kind='bar', color='skyblue')
plt.title('Ventas Totales por Región')
plt.xlabel('Región')
plt.ylabel('Ventas')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig('dashboard_r_barras.png', dpi=100)

# --- Plot 2: Line plot of total sales by month ---
plt.figure(figsize=(8, 5))
# Group by month and sum sales
monthly_sales = data.groupby('mes')['ventas'].sum().sort_index()
monthly_sales.plot(kind='line', marker='o', color='darkred')
plt.title('Ventas Totales por Mes')
plt.xlabel('Mes')
plt.ylabel('Ventas')
plt.xticks(rotation=45, ha='right')
plt.grid(True)
plt.tight_layout()
plt.savefig('dashboard_r_linea.png', dpi=100)

print("Scripts ejecutados exitosamente. Se han generado dashboard_r_barras.png y dashboard_r_linea.png.")