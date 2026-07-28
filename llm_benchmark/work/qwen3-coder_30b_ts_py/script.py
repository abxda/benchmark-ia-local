import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer los datos
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'], index_col='fecha')

# Ajustar el modelo Holt-Winters aditivo
model = ExponentialSmoothing(df['valor'], trend='add', seasonal='add', seasonal_periods=12)
fitted_model = model.fit()

# Generar pronóstico de 12 meses
forecast = fitted_model.forecast(steps=12)

# Crear DataFrame con fechas y pronósticos
last_date = df.index[-1]
future_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=12, freq='MS')
pronostico_df = pd.DataFrame({'fecha': future_dates, 'pronostico': forecast})

# Guardar en archivo CSV
pronostico_df.to_csv('pronostico_py.csv', index=False)
