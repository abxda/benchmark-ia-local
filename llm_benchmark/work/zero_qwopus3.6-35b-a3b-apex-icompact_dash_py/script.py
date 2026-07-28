import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd

df = pd.read_csv('ventas.csv')
df['mes'] = pd.to_datetime(df['mes'], format='%Y-%m')

# --- Gráfica 1: Barras de ventas totales por región ---
ventas_region = df.groupby('region')['ventas'].sum().reset_index()
ventas_region = ventas_region.sort_values('ventas', ascending=True)
fig1 = px.bar(ventas_region, x='region', y='ventas', text=ventas_region['ventas'].round(2),
              title='Ventas Totales por Región',
              labels={'region': 'Región', 'ventas': 'Ventas Totales'})
fig1.update_traces(texttemplate='%{text:.2f}', textposition='outside')

# --- Gráfica 2: Línea de ventas totales por mes ---
ventas_mes = df.groupby('mes')['ventas'].sum().reset_index()
ventas_mes = ventas_mes.sort_values('mes')
fig2 = px.line(ventas_mes, x='mes', y='ventas',
               title='Ventas Totales por Mes',
               labels={'mes': 'Mes', 'ventas': 'Ventas Totales'})
fig2.update_traces(mode='lines+markers')

# --- Subplots ---
fig = make_subplots(rows=2, cols=1, specs=[[{"type": "bar"}], [{"type": "scatter"}]],
                    subplot_titles=['Ventas Totales por Región', 'Ventas Totales por Mes'])

fig.add_trace(go.Bar(x=ventas_region['region'], y=ventas_region['ventas'],
                      text=ventas_region['ventas'].round(2), textposition='outside'),
              row=1, col=1)
fig.add_trace(go.Scatter(x=ventas_mes['mes'], y=ventas_mes['ventas'],
                         mode='lines+markers', name='Ventas'),
              row=2, col=1)

fig.update_layout(height=700, width=900, title_text='Dashboard de Ventas')
fig.update_xaxes(title_text='Región', row=1, col=1)
fig.update_xaxes(title_text='Mes', row=2, col=1, type='date')
fig.update_yaxes(title_text='Ventas Totales', row=1, col=1)
fig.update_yaxes(title_text='Ventas Totales', row=2, col=1)

fig.write_html('dashboard.html', include_plotlyjs='cdn')
print('dashboard.html generado con éxito')
