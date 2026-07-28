import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from datetime import datetime, timedelta
import numpy as np

# Leer el archivo CSV
df = pd.read_csv('serie_mensual.csv')

# Convertir la columna de fecha a tipo datetime
df['fecha'] = pd.to_datetime(df['fecha'])

# Ajustar el modelo Holt-Winters aditivo
model = ExponentialSmoothing(
    df['valor'],
    trend='add',
    seasonal='add',
    seasonal_periods=12
)

# Ajustar el modelo
fitted_model = model.fit()

# Generar pronóstico para los próximos 12 meses
forecast = fitted_model.forecast(steps=12)

# Crear fechas para el pronóstico
last_date = df['fecha'].max()
forecast_dates = []
for i in range(1, 13):
    next_month = last_date + pd.DateOffset(months=i)
    forecast_dates.append(next_month.strftime('%Y-%m-%d'))

# Crear DataFrame con el pronóstico
forecast_df = pd.DataFrame({
    'fecha': forecast_dates,
    'pronostico': forecast
})

# Guardar el pronóstico en un archivo CSV
forecast_df.to_csv('pronostico_py.csv', index=False)

print("Script ejecutado correctamente.")
print("Archivo 'pronostico_py.csv' generado con éxito.")