import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer serie_mensual.csv (columnas: fecha, valor)
df = pd.read_csv("serie_mensual.csv", parse_dates=["fecha"])
s = df.set_index("fecha")["valor"]
# Índice mensual (los datos son 2020-01-01 ... 2025-12-01, uno por mes)
s.index = pd.to_datetime(s.index, format="%Y-%m-%d").to_period("M").to_timestamp(how="S")
s.index.name = "fecha"

# Holt-Winters aditivo: tendencia aditiva + estacionalidad aditiva (12 meses)
model = ExponentialSmoothing(
    s,
    trend="add",
    seasonal="add",
    seasonal_periods=12,
)
fit = model.fit(optimized=True)

# Pronóstico de los 12 meses siguientes (la serie termina en 2025-12,
# por lo que los meses siguientes son 2026-01 ... 2026-12)
fcast = fit.forecast(12)
out = pd.DataFrame({
    "fecha": fcast.index.strftime("%Y-%m-%d"),
    "pronostico": fcast.values,
})
out.to_csv("pronostico_py.csv", index=False)
print(out.to_string(index=False))
