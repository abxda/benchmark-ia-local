import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Calcular ventas totales por región
ventas_por_region = df.groupby('region')['ventas'].sum().reset_index()

# Calcular ventas totales por mes
ventas_por_mes = df.groupby('mes')['ventas'].sum().reset_index()

# Crear subplots
fig = make_subplots(
    rows=1,
    cols=2,
    subplot_titles=('Ventas Totales por Región', 'Ventas Totales por Mes'),
    column_widths=[0.5, 0.5]
)

# Gráfico de barras: Ventas por región
fig.add_trace(
    go.Bar(x=ventas_por_region['region'], y=ventas_por_region['ventas'], name='Ventas por Región'),
    row=1,
    col=1
)

# Gráfico de línea: Ventas por mes
fig.add_trace(
    go.Scatter(x=ventas_por_mes['mes'], y=ventas_por_mes['ventas'], mode='lines+markers', name='Ventas por Mes'),
    row=1,
    col=2
)

# Actualizar diseño
fig.update_layout(
    title_text="Dashboard de Ventas",
    height=400,
    showlegend=False
)

# Guardar el dashboard en un archivo HTML
fig.write_html('dashboard.html', include_plotlyjs='cdn')
