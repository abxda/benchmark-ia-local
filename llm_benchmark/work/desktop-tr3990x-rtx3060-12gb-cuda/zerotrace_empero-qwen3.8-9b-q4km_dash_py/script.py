import pandas as pd
import plotly.express as px
from plotly.subplots import make_subplots
import plotly.io as pio

# Leer el archivo CSV
df = pd.read_csv("ventas.csv")

# Crear subplots: 2 filas, 1 columna
fig = make_subplots(
    rows=2,
    cols=1,
    specs=[[{"type": "bar"}], [{"type": "scatter"}]],
    subplot_titles=("Ventas Totales por Region", "Ventas Totales por Mes"),
    vertical_spacing=0.2
)

# Grafica 1: Barras de ventas totales por region
fig.add_trace(
    px.bar(
        df,
        x="region",
        y="ventas",
        title="Ventas Totales por Region",
    ).data[0],
    row=1,
    col=1
)

# Grafica 2: Linea de ventas totales por mes
fig.add_trace(
    px.line(
        df,
        x="mes",
        y="ventas",
        title="Ventas Totales por Mes",
    ).data[0],
    row=2,
    col=1
)

# Guardar en un solo archivo HTML
fig.write_html("dashboard.html", include_plotlyjs="cdn")
print("Dashboard generado exitosamente: dashboard.html")
