import pandas as pd
import plotly.express as px
import plotly.subplots as sp
import plotly.graph_objects as go

df = pd.read_csv('ventas.csv')
fig = sp.make_subplots(rows=1, cols=2, subplot_titles=('Ventas totales por región', 'Ventas totales por mes'))
fig.add_trace(px.bar(df, x='region', y='ventas', title='Ventas totales por región').data[0], row=1, col=1)
fig.add_trace(px.line(df, x='mes', y='ventas', title='Ventas totales por mes').data[0], row=1, col=2)
fig.update_layout(height=600, width=1200)
fig.write_html('dashboard.html', include_plotlyjs='cdn')
