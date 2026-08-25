import pandas as pd

from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer la serie mensual
df = pd.read_csv("serie_mensual.csv")
df["fecha"] = pd.to_datetime(df["fecha"])
df = df.sort_values("fecha").reset_index(drop=True)

# Ajustar Holt-Winters aditivo con estacionalidad anual (12 meses)
model = ExponentialSmoothing(
    df["valor"],
    trend="add",
    seasonal="add",
    seasonal_periods=12,
).fit()

# Generar pronostico de 12 meses
horizon = 12
forecast = model.forecast(horizon)

# Fechas: meses siguientes al ultimo de la serie
next_dates = pd.date_range(
    start=df["fecha"].iloc[-1] + pd.offsets.MonthBegin(1),
    periods=horizon,
    freq="MS",
)

# Escribir pronostico
out = pd.DataFrame({
    "fecha": next_dates.strftime("%Y-%m-%d").tolist(),
    "pronostico": forecast.values,
})
out.to_csv("pronostico_py.csv", index=False)

print(f"Ultimo mes de la serie: {df['fecha'].iloc[-1].strftime('%Y-%m-%d')}")
print(f"Horizonte de pronostico: {horizon} meses")
print("\nTabla de pronostico:")
print(out.to_string(index=False))
