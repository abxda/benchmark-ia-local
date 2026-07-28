import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def generate_dashboard():
    # 1. Leer el archivo CSV
    try:
        df = pd.read_csv('ventas.csv')
    except FileNotFoundError:
        print("Error: El archivo 'ventas.csv' no existe.")
        return

    # Asegurar que las columnas tengan el tipo correcto
    df['ventas'] = pd.to_numeric(df['ventas'])

    # 2. Preparar los datos para las gráficas
    # (1) Ventas totales por región
    ventas_region = df.groupby('region')['ventas'].sum().reset_index()

    # (2) Ventas totales por mes
    ventas_mes = df.groupby('mes')['ventas'].sum().reset_index()
    # Ordenar por mes (asumiendo formato YYYY-MM)
    ventas_mes = ventas_mes.sort_values('mes')

    # 3. Crear subplots
    # Usaremos 2 filas, 1 columna
    fig = make_subplots(
        rows=2, cols=1,
        subplot_titles=("Ventas Totales por Región", "Ventas Totales por Mes"),
        vertical_spacing=0.15
    )

    # Añadir gráfica de barras (Región)
    fig.add_trace(
        go.Bar(x=ventas_region['region'], y=ventas_region['ventas'], name='Ventas por Región'),
        row=1, col=1
    )

    # Añadir gráfica de líneas (Mes)
    fig.add_trace(
        go.Scatter(x=ventas_mes['mes'], y=ventas_mes['ventas'], mode='lines+markers', name='Ventas por Mes'),
        row=2, col=1
    )

    # Configurar el diseño general
    fig.update_layout(
        height=800,
        title_text="Dashboard de Ventas",
        showlegend=False
    )

    # 4. Guardar el resultado en un archivo HTML
    fig.write_html('dashboard.html', include_plotlyjs='cdn')
    print("Dashboard generado exitosamente en 'dashboard.html'.")

if __name__ == "__main__":
    generate_dashboard()
