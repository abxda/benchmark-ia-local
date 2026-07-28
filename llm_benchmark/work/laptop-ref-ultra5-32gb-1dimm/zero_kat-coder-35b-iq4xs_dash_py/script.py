import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

df = pd.read_csv('ventas.csv')

# Gráfica 1: barras de ventas totales por región
ventas_por_region = df.groupby('region')['ventas'].sum().reset_index()
fig1 = go.Figure(data=[
    go.Bar(x=ventas_por_region['region'], y=ventas_por_region['ventas'],
           marker_color='steelblue')
])
fig1.update_layout(title='Ventas Totales por Región', xaxis_title='Región',
                   yaxis_title='Ventas')

# Gráfica 2: línea de ventas totales por mes
ventas_por_mes = df.groupby('mes')['ventas'].sum().reset_index()
ventas_por_mes['mes'] = pd.to_datetime(ventas_por_mes['mes'])
fig2 = go.Figure(data=[
    go.Scatter(x=ventas_por_mes['mes'], y=ventas_por_mes['ventas'],
               mode='lines+markers', line=dict(color='coral'))
])
fig2.update_layout(title='Ventas Totales por Mes', xaxis_title='Mes',
                   yaxis_title='Ventas')

# Subplots
fig = make_subplots(rows=2, cols=1,
                    subplot_titles=('Ventas Totales por Región', 'Ventas Totales por Mes'))
fig.add_trace(fig1.data[0], row=1, col=1)
fig.add_trace(fig2.data[0], row=2, col=1)

fig.update_layout(height=800, showlegend=False,
                  title_text='Dashboard de Ventas')
fig.write_html('dashboard.html', include_plotlyjs='cdn')
print('Dashboard generado: dashboard.html')
