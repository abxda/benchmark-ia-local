import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer la serie temporal
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'])

# Ajustar modelo Holt-Winters aditivo
model = ExponentialSmoothing(
    df['valor'],
    trend='add',
    seasonal='add',
    seasonal_periods=12,
    initialization_method='estimated'
)

result = model.fit()

# Generar pronóstico de 12 meses
forecast = result.forecast(12)

# Crear fechas para los 12 meses siguientes
last_date = df['fecha'].iloc[-1]
future_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=12, freq='MS')

# Guardar resultado
out = pd.DataFrame({
    'fecha': future_dates.strftime('%Y-%m-%d'),
    'pronostico': forecast.values
})

out.to_csv('pronostico_py.csv', index=False)
print(out)
