import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Crear un archivo ventas.csv de ejemplo si no existe para asegurar la ejecución
try:
    pd.read_csv('ventas.csv')
except FileNotFoundError:
    data = {
        'region': ['Norte', 'Sur', 'Este', 'Oeste', 'Norte', 'Sur', 'Este', 'Oeste', 'Norte', 'Sur'],
        'mes': ['Ene', 'Ene', 'Ene', 'Ene', 'Feb', 'Feb', 'Feb', 'Feb', 'Mar', 'Mar'],
        'ventas': [150, 200, 120, 300, 180, 220, 140, 320, 210, 250]
    }
    df_example = pd.DataFrame(data)
    df_example.to_csv('ventas.csv', index=False)

# 1. Lectura de datos
try:
    df = pd.read_csv('ventas.csv')
except FileNotFoundError:
    print("Error: El archivo 'ventas.csv' no fue encontrado.")
    exit()

# 2. Procesamiento de datos
# Ventas totales por región
ventas_por_region = df.groupby('region')['ventas'].sum().reset_index()

# Ventas totales por mes
ventas_por_mes = df.groupby('mes')['ventas'].sum().reset_index()

# 3. Creación de las gráficas

# Gráfica 1: Barras de ventas totales por región
fig_region = go.Figure(data=[
    go.Bar(x=ventas_por_region['region'], y=ventas_por_region['ventas'], name='Ventas')
])
fig_region.update_layout(
    title='Ventas Totales por Región',
    xaxis_title='Región',
    yaxis_title='Ventas Totales'
)

# Gráfica 2: Línea de ventas totales por mes
fig_mes = go.Figure(data=[
    go.Scatter(x=ventas_por_mes['mes'], y=ventas_por_mes['ventas'], mode='lines+markers', name='Ventas')
])
fig_mes.update_layout(
    title='Ventas Totales por Mes',
    xaxis_title='Mes',
    yaxis_title='Ventas Totales'
)

# 4. Creación del Dashboard con subplots
fig = make_subplots(
    rows=1, cols=2,
    subplot_titles=("Ventas Totales por Región", "Ventas Totales por Mes")
)

# Añadir la gráfica de barras (Región)
fig.add_trace(fig_region.data[0], row=1, col=1)

# Añadir la gráfica de línea (Mes)
fig.add_trace(fig_mes.data[0], row=1, col=2)

# Actualizar el diseño general del dashboard
fig.update_layout(
    height=500, 
    width=1200, 
    title_text="Dashboard de Ventas",
    showlegend=True
)

# 5. Guardar el dashboard
fig.write_html('dashboard.html', include_plotlyjs='cdn')

print("Dashboard generado exitosamente en 'dashboard.html'")
