import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots


def main():
    df = pd.read_csv("ventas.csv")

    # Ventas totales por region (barras)
    ventas_region = df.groupby("region")["ventas"].sum().reset_index()
    ventas_region = ventas_region.sort_values("ventas", ascending=False).reset_index(drop=True)

    # Ventas totales por mes (linea)
    ventas_mes = (
        df.groupby("mes")["ventas"]
        .sum()
        .reset_index()
        .sort_values("mes")
        .reset_index(drop=True)
    )

    fig = make_subplots(
        rows=1,
        cols=2,
        specs=[
            [
                {"type": "xy"},
                {"type": "xy"},
            ]
        ],
        subplot_titles=("Ventas totales por región", "Ventas totales por mes"),
        horizontal_spacing=0.05,
    )

    # Subplot 1: barras de ventas totales por region
    fig.add_trace(
        go.Bar(
            x=ventas_region["region"],
            y=ventas_region["ventas"],
            name="Ventas totales por región",
        ),
        row=1,
        col=1,
    )

    # Subplot 2: linea de ventas totales por mes
    fig.add_trace(
        go.Scatter(
            x=ventas_mes["mes"],
            y=ventas_mes["ventas"],
            mode="lines+markers",
            name="Ventas totales por mes",
        ),
        row=1,
        col=2,
    )

    fig.update_layout(
        title="Dashboard de ventas",
        height=500,
        width=1000,
        xaxis_title="Mes",
        yaxis_title="Ventas",
    )
    fig.update_xaxes(rangebreaks=[], row=1, col=2, type="category")

    fig.write_html("dashboard.html", include_plotlyjs="cdn")
    print("dashboard.html generado correctamente.")


if __name__ == "__main__":
    main()
