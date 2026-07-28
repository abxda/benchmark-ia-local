import pandas as pd
import plotly.express as px
from plotly.subplots import make_subplots
import io

# Leer el CSV
df = pd.read_csv('ventas.csv')

# Grafica 1: Barras de ventas totales por region
fig1 = px.bar(df, x='region', y='ventas', title='Ventas Totales por Region',
              labels={'ventas': 'Ventas'},
              height=400,
              width=600)

# Grafica 2: Linea de ventas totales por mes
# Agrupar por mes y sumas las ventas
df_mensual = df.groupby('mes')['ventas'].sum().reset_index()
fig2 = px.line(df_mensual, x='mes', y='ventas', title='Ventas Totales por Mes',
               labels={'ventas': 'Ventas'},
               height=400,
               width=600)

# Crear subplots con dos graficas
fig = make_subplots(
    rows=2, cols=1,
    subplot_titles=('Ventas Totales por Region', 'Ventas Totales por Mes'),
    vertical_spacing=0.15,
    row_heights=[0.5, 0.5],
    column_widths=[1]
)

# Agregar la primera grafica al subplot 1,1
fig.add_trace(fig1.data[0], row=1, col=1)

# Agregar la segunda grafica al subplot 2,1
fig.add_trace(fig2.data[0], row=2, col=1)

# Actualizar layout
fig.update_layout(
    title_text='Dashboard de Ventas',
    height=800,
    showlegend=False,
    font=dict(family='Arial', size=12),
    title_x=0.5,
    title_y=0.98
)

# Actualizar ejes
fig.update_xaxes(title_text='Region/Mes', row=1, col=1)
fig.update_yaxes(title_text='Ventas', row=1, col=1)
fig.update_xaxes(title_text='Mes', row=2, col=1)
fig.update_yaxes(title_text='Ventas', row=2, col=1)

# Guardar como HTML
fig.write_html('dashboard.html', include_plotlyjs='cdn')

print("Dashboard generado exitosamente en 'dashboard.html'")
