import pandas as pd
import plotly.graph_objs as go
from plotly.subplots import make_subplots

# Leer el archivo CSV
df = pd.read_csv('ventas.csv')

# Calcular ventas totales por region y mes
total_ventas_region = df.groupby('region')['ventas'].sum().reset_index()
total_ventas_mes = df.groupby('mes')['ventas'].sum().reset_index()

# Crear subplots
fig = make_subplots(rows=1, cols=2, subplot_titles=("Ventas Totales por Region", "Ventas Totales por Mes"))

# Agregar gráfica de barras para ventas totales por region
fig.add_trace(go.Bar(x=total_ventas_region['region'], y=total_ventas_region['ventas'], name='Ventas'), row=1, col=1)

# Agregar gráfica de línea para ventas totales por mes
fig.add_trace(go.Scatter(x=total_ventas_mes['mes'], y=total_ventas_mes['ventas'], mode='lines+markers', name='Ventas'), row=1, col=2)

# Configurar diseño general del dashboard
fig.update_layout(title_text="Dashboard de Ventas", height=600, width=1200)

# Guardar el dashboard en un archivo HTML
fig.write_html('dashboard.html', include_plotlyjs='cdn')
