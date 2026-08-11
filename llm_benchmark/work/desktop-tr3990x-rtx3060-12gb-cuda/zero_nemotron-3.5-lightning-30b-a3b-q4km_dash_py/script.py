import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# Leer datos
df = pd.read_csv('ventas.csv')

# Calcular ventas totales por region
region_totals = df.groupby('region')['ventas'].sum().reset_index()

# Calcular ventas totales por mes
mes_totals = df.groupby('mes')['ventas'].sum().reset_index()

# Crear figura con subplots
fig = make_subplots(rows=2, cols=1, 
                    subplot_titles=['Ventas Totales por Región', 'Ventas Totales por Mes'])

# Grafica 1: Barras de ventas totales por region
fig.add_trace(go.Bar(x=region_totals['region'], y=region_totals['ventas'], name='Ventas por Región'), row=1, col=1)

# Grafica 2: Linea de ventas totales por mes
fig.add_trace(go.Scatter(x=mes_totals['mes'], y=mes_totals['ventas'], mode='lines+markers', name='Ventas por Mes'), row=2, col=1)

# Actualizar layout
fig.update_layout(height=600, title_text="Dashboard de Ventas")

# Guardar como HTML usando CDN
fig.write_html('dashboard.html', include_plotlyjs='cdn')

print("Dashboard generado exitosamente como 'dashboard.html'")