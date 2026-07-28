import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer la serie
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'])
df = df.sort_values('fecha').reset_index(drop=True)

# Ajustar Holt-Winters aditivo
model = ExponentialSmoothing(
    df['valor'],
    trend='add',
    seasonal='add',
    seasonal_periods=12
).fit()

# Pronóstico de 12 meses
forecast = model.forecast(12)

# Fechas de pronóstico (meses siguientes)
last_date = df['fecha'].iloc[-1]
future_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=12, freq='MS')

# Guardar resultado
resultado = pd.DataFrame({
    'fecha': future_dates.strftime('%Y-%m-%d'),
    'pronostico': forecast.values
})
resultado.to_csv('pronostico_py.csv', index=False)

print("Pronóstico generado:")
print(resultado.to_string(index=False))
print(f"\nArchivo guardado: pronostico_py.csv")
