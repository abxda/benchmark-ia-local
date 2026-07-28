import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer el archivo CSV
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'])
df = df.sort_values('fecha').reset_index(drop=True)

# Configurar el modelo Holt-Winters aditivo
model = ExponentialSmoothing(
    df['valor'],
    trend='add',
    seasonal='add',
    seasonal_periods=12,
    use_brute=True
)

# Ajustar el modelo
fit = model.fit(optimized=True)

# Generar pronóstico para los próximos 12 meses
last_date = df['fecha'].max()
forecast_dates = pd.date_range(start=last_date + pd.offsets.MonthBegin(1), periods=12, freq='MS')
forecast_values = fit.forecast(steps=12)

# Crear el DataFrame de pronóstico
forecast_df = pd.DataFrame({
    'fecha': forecast_dates.strftime('%Y-%m-%d'),
    'pronostico': forecast_values
})

# Guardar el pronóstico en un archivo CSV
forecast_df.to_csv('pronostico_py.csv', index=False)
