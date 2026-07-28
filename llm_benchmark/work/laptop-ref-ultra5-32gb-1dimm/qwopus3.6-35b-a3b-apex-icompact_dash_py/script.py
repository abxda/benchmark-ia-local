import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

df = pd.read_csv('ventas.csv')

ventas_region = df.groupby('region')['ventas'].sum().reset_index()
ventas_mes = df.groupby('mes')['ventas'].sum().reset_index()

fig = make_subplots(rows=2, cols=1, subplot_titles=("Ventas Totales por Región", "Ventas Totales por Mes"))

fig.add_trace(go.Bar(x=ventas_region['region'], y=ventas_region['ventas'], name="Ventas por Región"), row=1, col=1)

fig.add_trace(go.Scatter(x=ventas_mes['mes'], y=ventas_mes['ventas'], mode='lines+markers', name="Ventas por Mes"), row=2, col=1)

fig.update_layout(height=800, title_text="Dashboard de Ventas")

fig.write_html('dashboard.html', include_plotlyjs='cdn')
