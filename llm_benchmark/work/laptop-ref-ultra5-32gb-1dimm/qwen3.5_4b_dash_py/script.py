import pandas as pd
import numpy as np
from io import StringIO
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Simulación de datos si 'ventas.csv' no existe o para asegurar que el script funcione en cualquier entorno.
# En un entorno real, se debería usar: df = pd.read_csv('ventas.csv')
data_str = """region,mes,ventas
Norte,Enero,1200
Norte,Febrero,1500
Norte,Marzo,1300
Sur,Enero,800
Sur,Febrero,900
Sur,Marzo,1100
Este,Enero,600
Este,Febrero,700
Este,Marzo,800
Oeste,Enero,400
Oeste,Febrero,500
Oeste,Marzo,600"""

# Crear DataFrame simulado (o leer el archivo real si está disponible)
try:
    df = pd.read_csv('ventas.csv')
except FileNotFoundError:
    # Si no existe, creamos uno basado en los datos de prueba para que el script sea funcional
    print("Archivo ventas.csv no encontrado. Generando datos simulados.")
    df = pd.DataFrame(data_str.split('\n')[1:], header=0)

# Asegurar columnas correctas y convertir a numérico si es necesario
df['ventas'] = pd.to_numeric(df['ventas'], errors='coerce')
df.dropna(inplace=True) # Eliminar filas con valores nulos en ventas

# 1. Gráfica de Barras: Ventas totales por región
region_sales = df.groupby('region')['ventas'].sum().reset_index()
fig_bars = go.Figure(data=[go.Bar(
    x=region_sales['region'], 
    y=region_sales['ventas']
)])

# 2. Gráfica de Línea: Ventas totales por mes
meses_unicos = df['mes'].unique().tolist() # ['Enero', 'Febbrero', ...] (dependiendo del orden)
df_sorted_by_month = df.sort_values(by='mes')
monthly_sales = df_sorted_by_month.groupby('mes')['ventas'].sum().reset_index()

fig_line = go.Figure(data=[go.Scatter(
    x=monthly_sales['mes'], 
    y=monthly_sales['ventas']
)])

# Crear subplots con make_subplots para combinar ambas gráficas en un solo archivo HTML
fig_combined = make_subplots(rows=2, cols=1)

# Añadir gráfica de barras (fila 0)
fig_combined.add_trace(go.Bar(
    x=region_sales['region'], 
    y=region_sales['ventas']
), row=1, col=1)

# Añadir gráfica de línea (fila 2)
fig_combined.add_trace(go.Scatter(
    x=monthly_sales['mes'], 
    y=monthly_sales['ventas']
), row=2, col=1)

# Personalizar títulos y etiquetas para mejorar la presentación
fig_combined.update_layout(
    title_text="Dashboard de Ventas",
    height=800, # Aumentar altura para que ambas gráficas se vean bien juntas
    showlegend=False,
    xaxis_title='Región',
    yaxis_title='Ventas Totales'
)

# Actualizar títulos individuales si es necesario (opcional pero recomendado con subplots)
fig_combined.update_traces(
    marker_color='#1f77b4', # Color azul para barras
    hovertemplate='<br>Valor: %{y:.2f}', 
    row=1, col=1
)

# Para la gráfica de línea usar un color diferente o el mismo (Plotly maneja bien los colores por defecto en subplots si no se especifica explícitamente por trace individual a veces, pero aquí lo dejamos genérico para que Plotly asigne automáticamente o usamos update_traces globalmente)
fig_combined.update_layout(
    xaxis2_title='Mes', # Asegurar título del eje X de la segunda gráfica
    yaxis2_title='Ventas Totales'
)

# Escribir el archivo HTML final con los scripts necesarios en línea (CDN)
fig_combined.write_html('dashboard.html', include_plotlyjs='cdn')
print("Dashboard generado exitosamente: dashboard.html")
