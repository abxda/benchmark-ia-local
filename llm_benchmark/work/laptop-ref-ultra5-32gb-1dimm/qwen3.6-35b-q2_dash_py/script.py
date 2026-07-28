import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

df = pd.read_csv('ventas.csv')

# Gráfica 1: Ventas totales por región
ventas_por_region = df.groupby('region')['ventas'].sum().reset_index()

# Gráfica 2: Ventas totales por mes
ventas_por_mes = df.groupby('mes')['ventas'].sum().reset_index()

# Crear subplots
fig = make_subplots(rows=2, cols=1, vertical_spacing=0.15)

# Agregar gráfica de barras
fig.add_trace(
    go.Bar(x=ventas_por_region['region'], y=ventas_por_region['ventas'], name='Ventas por Región'),
    row=1, col=1
)

# Agregar gráfica de línea
fig.add_trace(
    go.Scatter(x=ventas_por_mes['mes'], y=ventas_por_mes['ventas'], mode='lines+markers', name='Ventas por Mes'),
    row=2, col=1
)

# Configurar título y ejes
fig.update_layout(
    title_text='Dashboard de Ventas',
    height=800,
    width=1000
)

fig.update_xaxes(title_text='Región', row=1, col=1)
fig.update_yaxes(title_text='Ventas Totales', row=1, col=1)
fig.update_xaxes(title_text='Mes', row=2, col=1)
fig.update_yaxes(title_text='Ventas Totales', row=2, col=1)

# Guardar como HTML
fig.write_html('dashboard.html', include_plotlyjs='cdn')
