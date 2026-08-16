import pandas as pd
import plotly.express as px
from plotly.subplots import make_subplots

df = pd.read_csv("ventas.csv")

region_totals = df.groupby("region")["ventas"].sum().reset_index()
month_totals = df.groupby("mes")["ventas"].sum().reset_index()

fig = make_subplots(rows=2, cols=1, subplot_titles=["Ventas por region", "Ventas por mes"])

fig.add_trace(
    px.bar(region_totals, x="region", y="ventas").data[0],
    row=1, col=1,
)

fig.add_trace(
    px.line(month_totals, x="mes", y="ventas").data[0],
    row=2, col=1,
)

fig.update_layout(height=700)
fig.write_html("dashboard.html", include_plotlyjs="cdn")
print("OK")
