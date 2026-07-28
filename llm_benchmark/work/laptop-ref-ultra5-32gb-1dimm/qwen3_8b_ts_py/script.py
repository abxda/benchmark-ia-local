import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer datos
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'], index_col='fecha')

# Ajustar modelo Holt-Winters aditivo
model = ExponentialSmoothing(df['valor'], trend='add', seasonal='add', seasonal_periods=12)
results = model.fit()

# Generar pronóstico para los próximos 12 meses
forecast = results.forecast(steps=12)

# Crear fechas futuras
forecast.index = pd.date_range(start=df.index[-1], periods=13, freq='M')[1:]

# Guardar pronóstico en CSV
forecast.to_csv('pronostico_py.csv', index_label='fecha', header=['pronostico'])
