import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

df = pd.read_csv('ventas.csv')

ventas_region = df.groupby('region')['ventas'].sum().reset_index()
ventas_mes = df.groupby('mes')['ventas'].sum().reset_index()

fig = make_subplots(rows=1, cols=2, specs=[[{"type": "bar"}, {"type": "scatter"}]])

fig.add_trace(go.Bar(x=ventas_region['region'], y=ventas_region['ventas'], name='Ventas por Región'), row=1, col=1)
fig.add_trace(go.Scatter(x=ventas_mes['mes'], y=ventas_mes['ventas'], mode='lines+markers', name='Ventas por Mes'), row=1, col=2)

fig.update_layout(title_text='Dashboard de Ventas', height=500)
fig.write_html('dashboard.html', include_plotlyjs='cdn')
