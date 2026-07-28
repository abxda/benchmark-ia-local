import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer el archivo CSV
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'], index_col='fecha')

# Ajustar el modelo Holt-Winters aditivo
model = ExponentialSmoothing(
    df['valor'],
    trend='add',
    seasonal='add',
    seasonal_periods=12
)

# Ajustar el modelo
fitted_model = model.fit()

# Generar pronóstico de 12 meses
forecast = fitted_model.forecast(12)

# Crear las fechas de los próximos 12 meses
last_date = df.index[-1]
forecast_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=12, freq='MS')

# Crear el DataFrame de pronóstico
forecast_df = pd.DataFrame({
    'fecha': forecast_dates,
    'pronostico': forecast.values
})

# Guardar el pronóstico en un archivo CSV
forecast_df.to_csv('pronostico_py.csv', index=False)
