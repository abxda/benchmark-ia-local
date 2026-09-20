import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer serie_mensual.csv
df = pd.read_csv('serie_mensual.csv')
df['fecha'] = pd.to_datetime(df['fecha'])
df = df.sort_values('fecha').reset_index(drop=True)

# Extraer valores
y = df['valor'].values

# Configuración del modelo Holt-Winters aditivo
seasonal_periods = 12  # 12 meses de estacionalidad anual

# Ajustar el modelo
model = ExponentialSmoothing(
    y,
    trend='add',
    seasonal='add',
    seasonal_periods=seasonal_periods
)
fit = model.fit()

# Pronosticar 12 meses
forecast_steps = 12
forecast = fit.forecast(steps=forecast_steps)

# Generar fechas para los pronósticos (siguientes meses después de la última fecha en los datos)
last_date = df['fecha'].iloc[-1]
forecast_dates = [last_date + pd.DateOffset(months=i+1) for i in range(forecast_steps)]

# Guardar pronóstico
pronostico_df = pd.DataFrame({
    'fecha': forecast_dates,
    'pronostico': forecast
})
pronostico_df['fecha'] = pronostico_df['fecha'].dt.strftime('%Y-%m-%d')
pronostico_df.to_csv('pronostico_py.csv', index=False)

print("Pronóstico generado en 'pronostico_py.csv':")
print(pronostico_df)
