import csv
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import os

# Leer datos de ventas.csv
datos = []
with open('ventas.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        datos.append({
            'region': row['region'],
            'mes': row['mes'],
            'ventas': float(row['ventas'])
        })

# Calcular ventas totales por región
ventas_por_region = {}
for d in datos:
    region = d['region']
    if region not in ventas_por_region:
        ventas_por_region[region] = 0
    ventas_por_region[region] += d['ventas']

# Calcular ventas totales por mes
ventas_por_mes = {}
for d in datos:
    mes = d['mes']
    if mes not in ventas_por_mes:
        ventas_por_mes[mes] = 0
    ventas_por_mes[mes] += d['ventas']

# Crear subplots con 1 fila, 2 columnas
fig = make_subplots(
    rows=1, cols=2,
    subplot_titles=['Ventas Totales por Región', 'Ventas Totales por Mes'],
    horizontal_spacing=0.1
)

# Gráfico 1: Barras de ventas totales por región
regiones = list(ventas_por_region.keys())
ventas_region = list(ventas_por_region.values())
fig.add_trace(
    go.Bar(x=regiones, y=ventas_region, name='Ventas Región'),
    row=1, col=1
)

# Gráfico 2: Línea de ventas totales por mes
meses = sorted(ventas_por_mes.keys(), key=lambda x: float(x.split('-')[1]) if '-' in x else x)
ventas_mes = [ventas_por_mes[m] for m in meses]
fig.add_trace(
    go.Scatter(x=meses, y=ventas_mes, mode='lines+markers', name='Ventas Mes'),
    row=1, col=2
)

# Actualizar layout
fig.update_layout(
    title_text='Dashboard de Ventas',
    showlegend=False,
    height=500,
    width=1000
)

# Actualizar ejes
fig.update_xaxes(title_text="Región", row=1, col=1)
fig.update_yaxes(title_text="Ventas Totales", row=1, col=1)
fig.update_xaxes(title_text="Mes", row=1, col=2)
fig.update_yaxes(title_text="Ventas Totales", row=1, col=2)

# Escribir HTML con CDN externo
fig.write_html('dashboard.html', include_plotlyjs='cdn')

print("Dashboard generado exitosamente: dashboard.html")