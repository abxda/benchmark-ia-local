import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from datetime import datetime, timedelta

# Leer el archivo CSV
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'], index_col='fecha')

# Ajustar el modelo Holt-Winters aditivo
model = ExponentialSmoothing(df['valor'], trend='add', seasonal='add', seasonal_periods=12)
fitted_model = model.fit()

# Generar pronóstico de 12 meses
forecast = fitted_model.forecast(steps=12)

# Crear fechas para el pronóstico
last_date = df.index[-1]
forecast_dates = [(last_date + timedelta(days=30*i)).strftime('%Y-%m-%d') for i in range(1, 13)]

# Guardar el pronóstico en un archivo CSV
forecast_df = pd.DataFrame({'fecha': forecast_dates, 'pronostico': forecast})
forecast_df.to_csv('pronostico_py.csv', index=False)
