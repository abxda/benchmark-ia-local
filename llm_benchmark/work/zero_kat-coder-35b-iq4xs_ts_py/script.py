import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer la serie histórica
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'])
df = df.sort_values('fecha').reset_index(drop=True)

# Ajustar Holt-Winters aditivo
model = ExponentialSmoothing(
    df['valor'],
    trend='add',
    seasonal='add',
    seasonal_periods=12
)
fitted = model.fit()

# Pronóstico de 12 meses
forecast = fitted.forecast(12)

# Construir fechas futuras (meses siguientes)
last_date = df['fecha'].iloc[-1]
future_dates = pd.date_range(start=last_date + pd.offsets.MonthBegin(1), periods=12, freq='MS')

# Guardar resultado
out = pd.DataFrame({'fecha': future_dates, 'pronostico': forecast})
out['fecha'] = out['fecha'].dt.strftime('%Y-%m-%d')
out.to_csv('pronostico_py.csv', index=False)

print(out.to_string(index=False))
