import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# 1. Crear un archivo de ejemplo para que el script sea ejecutable de inmediato
data = {
    'region': ['Norte', 'Sur', 'Este', 'Oeste', 'Norte', 'Sur', 'Este', 'Oeste', 'Norte', 'Sur'],
    'mes': ['Enero', 'Enero', 'Enero', 'Enero', 'Febrero', 'Febrero', 'Febrero', 'Febrero', 'Marzo', 'Marzo'],
    'ventas': [100, 150, 200, 120, 130, 170, 210, 140, 110, 160]
}
pd.DataFrame(data).to_csv('ventas.csv', index=False)

# 2. Leer los datos
df = pd.read_csv('ventas.csv')

# 3. Procesar datos para las gráficas
ventas_region = df.groupby('region')['ventas'].sum().reset_index()
ventas_mes = df.groupby('mes')['ventas'].sum().reset_index()

# Asegurar orden cronológico si es necesario (opcional, basado en los datos presentes)
meses_orden = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
ventas_mes['mes'] = pd.Categorical(ventas_mes['mes'], categories=meses_orden, ordered=True)
ventas_mes = ventas_mes.sort_values('mes')

# 4. Crear el Dashboard con Subplots
fig = make_subplots(
    rows=2, cols=1,
    subplot_titles=("Ventas Totales por Región", "Tendencia de Ventas por Mes"),
    vertical_spacing=0.15
)

# Gráfica 1: Barras por Región
fig.add_trace(
    go.Bar(x=ventas_region['region'], y=ventas_region['ventas'], name="Región"),
    row=1, col=1
)

# Gráfica 2: Línea por Mes
fig.add_trace(
    go.Scatter(x=ventas_mes['mes'], y=ventas_mes['ventas'], mode='lines+markers', name="Mes"),
    row=2, col=1
)

# 5. Configuración de diseño y exportación
fig.update_layout(
    height=800, 
    title_text="Dashboard de Ventas", 
    showlegend=False
)

fig.write_html('dashboard.html', include_plotlyjs='cdn')
