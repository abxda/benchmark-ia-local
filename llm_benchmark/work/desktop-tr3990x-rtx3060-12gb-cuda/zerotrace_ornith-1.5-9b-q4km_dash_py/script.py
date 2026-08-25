import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots


def main():
    # Leer el archivo CSV
    df = pd.read_csv("ventas.csv")

    # Ventas totales por region
    ventas_por_region = df.groupby("region")["ventas"].sum()

    # Ventas totales por mes
    ventas_por_mes = df.groupby("mes")["ventas"].sum()

    # Crear subplots: barras por region (fila superior), linea por mes (fila inferior)
    fig = make_subplots(
        rows=2,
        cols=1,
        shared_xaxes=False,
        row_heights=[0.5, 0.5],
        vertical_spacing=0.08,
    )

    # Grafica 1: Barras de ventas totales por region (fila superior)
    fig.add_trace(
        go.Bar(
            x=ventas_por_region.index,
            y=ventas_por_region.values,
            name="Ventas por region",
            marker_color="#4472C4",
        ),
        row=1,
        col=1,
    )
    fig.update_layout(
        title="Ventas Totales por Region",
        xaxis_title="Region",
        yaxis_title="Ventas Totales",
        barmode="relative",
    )

    # Grafica 2: Linea de ventas totales por mes (fila inferior)
    fig.add_trace(
        go.Scatter(
            x=ventas_por_mes.index,
            y=ventas_por_mes.values,
            name="Ventas por mes",
            mode="lines",
            line=dict(color="#ED7D31", width=3),
        ),
        row=2,
        col=1,
    )
    fig.update_layout(
        title="Ventas Totales por Mes",
        xaxis_title="Mes",
        yaxis_title="Ventas Totales",
        showlegend=False,
    )

    # Configuracion general del dashboard
    fig.update_layout(
        height=600,
        showlegend=True,
        margin=dict(l=50, r=50, t=80, b=50),
    )

    # Guardar como HTML usando CDN
    fig.write_html("dashboard.html", include_plotlyjs="cdn")


if __name__ == "__main__":
    main()
