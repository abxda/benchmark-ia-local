import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Grafica 1: Barras de ventas totales por región
ventas_por_region = df.groupby('region')['ventas'].sum().sort_values(ascending=False)

fig_bar = go.Figure()
fig_bar.add_trace(go.Bar(
    x=ventas_por_region.index,
    y=ventas_por_region.values,
    marker_color='steelblue'
))
fig_bar.update_layout(
    title='Ventas Totales por Región',
    xaxis_title='Región',
    yaxis_title='Ventas',
    template='plotly_white'
)

# Grafica 2: Línea de ventas totales por mes
ventas_por_mes = df.groupby('mes')['ventas'].sum()
ventas_por_mes.index = pd.to_datetime(ventas_por_mes.index)

fig_line = go.Figure()
fig_line.add_trace(go.Scatter(
    x=ventas_por_mes.index,
    y=ventas_por_mes.values,
    mode='lines+markers',
    line=dict(color='firebrick', width=2),
    marker=dict(size=8)
))
fig_line.update_layout(
    title='Ventas Totales por Mes',
    xaxis_title='Mes',
    yaxis_title='Ventas',
    template='plotly_white'
)

# Crear subplots
fig = make_subplots(
    rows=2, cols=1,
    subplot_titles=('Ventas Totales por Región', 'Ventas Totales por Mes'),
    vertical_spacing=0.15
)

# Agregar las trazas
fig.add_trace(fig_bar.data[0], row=1, col=1)
fig.add_trace(fig_line.data[0], row=2, col=1)

# Actualizar diseño general
fig.update_layout(
    height=900,
    showlegend=False,
    title_text='Dashboard de Ventas',
    title_x=0.5,
    title_font_size=20
)

# Guardar como HTML
fig.write_html('dashboard.html', include_plotlyjs='cdn')

print('Dashboard generado exitosamente en dashboard.html')
