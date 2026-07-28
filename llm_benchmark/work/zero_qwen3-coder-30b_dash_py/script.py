import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Leer el archivo ventas.csv
df = pd.read_csv('ventas.csv')

# Calcular ventas totales por región
ventas_por_region = df.groupby('region')['ventas'].sum().reset_index()

# Calcular ventas totales por mes
ventas_por_mes = df.groupby('mes')['ventas'].sum().reset_index()

# Crear subplots
fig = make_subplots(
    rows=2, cols=1,
    subplot_titles=('Ventas Totales por Región', 'Ventas Totales por Mes'),
    vertical_spacing=0.1
)

# Gráfica de barras: Ventas totales por región
fig.add_trace(
    go.Bar(
        x=ventas_por_region['region'],
        y=ventas_por_region['ventas'],
        name='Ventas por Región',
        marker_color='blue'
    ),
    row=1, col=1
)

# Gráfica de línea: Ventas totales por mes
fig.add_trace(
    go.Scatter(
        x=ventas_por_mes['mes'],
        y=ventas_por_mes['ventas'],
        mode='lines+markers',
        name='Ventas por Mes',
        line=dict(color='red')
    ),
    row=2, col=1
)

# Actualizar layout
fig.update_layout(
    title_text='Dashboard de Ventas',
    height=600,
    showlegend=False
)

# Guardar el dashboard como archivo HTML
fig.write_html('dashboard.html', include_plotlyjs='cdn')