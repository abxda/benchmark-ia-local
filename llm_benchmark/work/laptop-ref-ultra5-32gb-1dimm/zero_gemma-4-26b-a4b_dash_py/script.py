import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def generate_dashboard():
    try:
        # Leer los datos
        df = pd.read_csv('ventas.csv')
        
        # 1. Ventas totales por región (Barras)
        ventas_region = df.groupby('region')['ventas'].sum().reset_index()
        
        # 2. Ventas totales por mes (Línea)
        ventas_mes = df.groupby('mes')['ventas'].sum().reset_index()
        # Asegurar que los meses estén ordenados cronológicamente si es necesario
        ventas_mes = ventas_mes.sort_values('mes')

        # Crear subplots: 2 filas, 1 columna
        fig = make_subplots(
            rows=2, cols=1,
            subplot_titles=("Ventas Totales por Región", "Ventas Totales por Mes"),
            vertical_spacing=0.15
        )

        # Añadir gráfica de barras
        fig.add_trace(
            go.Bar(x=ventas_region['region'], y=ventas_region['ventas'], name='Región'),
            row=1, col=1
        )

        # Añadir gráfica de líneas
        fig.add_trace(
            go.Scatter(x=ventas_mes['mes'], y=ventas_mes['ventas'], mode='lines+markers', name='Mes'),
            row=2, col=1
        )

        # Actualizar diseño
        fig.update_layout(height=800, title_text="Dashboard de Ventas", showlegend=False)

        # Guardar el dashboard
        fig.write_html('dashboard.html', include_plotlyjs='cdn')
        print("Dashboard generado exitosamente: dashboard.html")

    except Exception as e:
        print(f"Error al generar el dashboard: {e}")

if __name__ == "__main__":
    generate_dashboard()
