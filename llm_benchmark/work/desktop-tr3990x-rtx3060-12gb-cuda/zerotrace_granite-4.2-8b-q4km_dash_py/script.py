import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Leer el archivo ventas.csv
df = pd.read_csv('ventas.csv', parse_dates=['mes'])

# (1) Ventas totales por region
df_region = df.groupby('region')['ventas'].sum().reset_index()
region_trace = go.Bar(x=df_region['region'], y=df_region['ventas'], name='Ventas totales')

# (2) Ventas totales por mes - ordenamos por mes para que la línea sea temporal
df_mes = df.groupby('mes')['ventas'].sum().reset_index()
df_mes_sorted = df_mes.sort_values('mes')
mes_trace = go.Scatter(x=df_mes_sorted['mes'], y=df_mes_sorted['ventas'], mode='lines', name='Ventas totales')

# Crear subplots con plotly.subplots - use 'bar' and 'scatter' as subplot types
fig = make_subplots(specs=[
    [{'type': 'bar'}],      # Subplot 1: barras por region
    [{'type': 'scatter'}]  # Subplot 2: línea por mes (scatter with lines mode)
], rows=2, cols=1,
    subplot_titles=["Ventas totales por Región", "Ventas totales por Mes"])

# Añadir la barra al subplot 1
fig.add_trace(region_trace, row=1, col=1)
# Añadir la línea al subplot 2  
fig.add_trace(mes_trace, row=2, col=1)

# Ajustar títulos de subplots y ejes
fig.update_layout(title_text="Dashboard de Ventas")

# Actualizar título de ejes por subplot
fig.update_xaxes(title_text='Región', row=1, col=1)
fig.update_xaxes(title_text='Mes', row=2, col=1)
fig.update_yaxes(title_text='Ventas (brutos)', row=1, col=1)
fig.update_yaxes(title_text='Ventas (brutos)', row=2, col=1)

# Escribir el dashboard HTML
fig.write_html('dashboard.html', include_plotlyjs='cdn')

print("Dashboard generado como 'dashboard.html'")
