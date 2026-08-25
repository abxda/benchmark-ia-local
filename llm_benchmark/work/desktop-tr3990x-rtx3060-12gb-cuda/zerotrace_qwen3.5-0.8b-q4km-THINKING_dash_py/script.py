import csv
import plotly.express as px
from plotly.subplots import make_subplots

# Read data from CSV
region = []
mes = []
ventas = []

with open('ventas.csv', 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
        region.append(row['region'])
        mes.append(row['mes'])
        ventas.append(float(row['ventas']))

# Create subplots
fig = make_subplots(rows=2, cols=2, rows_maj=1, cols_maj=1, 
                      ipspitch_layout="grid",
                      subplot_titles=(
                          f"Ventas Totales por Region",
                          f"Ventas Totales por Mes"
                      ))

# Plot 1: Barras de ventas totales por region
fig.add_trace(
    px.bar(ventas, x=region, y=1, name='Ventas Totales por Region'),
    row=1, col=1
)

# Plot 2: Línea de ventas totales por mes
fig.add_trace(
    px.line(ventas, x=mes, y=1, name='Ventas Totales por Mes'),
    row=1, col=2
)

# Add layout
fig.update_layout(
    title_text="Dashboard de Ventas",
    height=600,
    width=1000,
    plot_bgcolor='white',
    text_bgcolor='white',
    paper_bgcolor='white',
    showlegend=True,
    showlegendtext=False
)

# Write HTML file
fig.write_html('dashboard.html', include_plotlyjs='cdn', file_format='html')

print("Dashboard generated successfully!")
print("Files created:")
print("  - ventas.csv")
print("  - dashboard.html")
