import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def main():
    # Leer los datos
    try:
        df = pd.read_csv('ventas.csv')
    except Exception as e:
        print(f"Error al leer ventas.csv: {e}")
        return

    # 1. Preparar datos para ventas por región (Barras)
    ventas_region = df.groupby('region')['ventas'].sum().reset_index()

    # 2. Preparar datos para ventas por mes (Línea)
    # Nota: Para que el orden de los meses sea correcto, idealmente deberíamos tener una lógica de orden.
    # Por simplicidad y dado que es un script genérico, usaremos el orden que aparezca o definiremos uno.
    meses_orden = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
    
    # Convertir mes a categórico para asegurar el orden en el gráfico
    df['mes'] = pd.Categorical(df['mes'], categories=meses_orden, ordered=True)
    ventas_mes = df.groupby('mes')['ventas'].sum().reset_index()

    # Crear subplots: 1 fila, 2 columnas
    fig = make_subplots(
        rows=1, cols=2,
        subplot_titles=("Ventas Totales por Región", "Ventas Totales por Mes")
    )

    # Añadir gráfico de barras (Región)
    fig.add_trace(
        go.Bar(x=ventas_region['region'], y=ventas_region['ventas'], name="Región"),
        row=1, col=1
    )

    # Añadir gráfico de líneas (Mes)
    fig.add_trace(
        go.Scatter(x=ventas_mes['mes'], y=ventas_mes['ventas'], mode='lines+markers', name="Mes"),
        row=1, col=2
    )

    # Actualizar diseño
    fig.update_layout(
        title_text="Dashboard de Ventas",
        showlegend=False,
        height=500
    )

    # Guardar el resultado
    fig.write_html('dashboard.html', include_plotlyjs='cdn')
    print("Dashboard generado exitosamente en 'dashboard.html'")

if __name__ == "__main__":
    main()
