import pandas as pd
import plotly.express as px
from plotly.subplots import make_subplots

df = pd.read_csv('ventas.csv')
fig = make_subplots(rows=1, cols=2, subplot_titles=['Ventas totales por region', 'Ventas totales por mes'])

# Gráfica 1: Barras por region
regions = df['region'].unique()
fig.add_trace(px.bar(x=regions, y=df.groupby('region')['ventas'].sum(), labels={'ventas': 'Ventas (M$)'}, orientation='h'), row=1, col=1)

# Gráfica 2: Línea por mes
fig.add_trace(px.line(df, x='mes', y='ventas', title='Ventas totales por mes'), row=1, col=2)

fig.write_html('dashboard.html', include_plotlyjs='cdn')
print('Dashboard guardado')
