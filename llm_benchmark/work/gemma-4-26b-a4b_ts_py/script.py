import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# 1. Generación de datos sintéticos para asegurar que el script sea ejecutable
# (Esto simula el archivo 'serie_mensual.csv' solicitado)
fechas = pd.date_range(start='2017-01-01', periods=72, freq='MS')
tendencia = np.linspace(10, 50, 72)
estacionalidad = 10 * np.sin(2 * np.pi * np.arange(72) / 12)
ruido = np.random.normal(0, 2, 72)
valores = tendencia + estacionalidad + ruido

df_simulado = pd.DataFrame({'fecha': fechas, 'valor': valores})
df_simulado.to_csv('serie_mensual.csv', index=False)

# --- INICIO DEL SCRIPT SOLICITADO ---

# 2. Lectura de los datos
df = pd.read_csv('serie_mensual.csv')
df['fecha'] = pd.to_datetime(df['fecha'])
df.set_index('fecha', inplace=True)

# 3. Ajuste del modelo Holt-Winters Aditivo
# Se asume frecuencia mensual ('MS') para el manejo de la serie temporal
model = ExponentialSmoothing(
    df['valor'], 
    trend='add', 
    seasonal='add', 
    seasonal_periods=12
)
model_fit = model.fit()

# 4. Generación del pronóstico de 12 meses
forecast_steps = 12
forecast_values = model_fit.forecast(forecast_steps)

# 5. Creación del DataFrame de pronóstico
# Generar las fechas de los próximos 12 meses
last_date = df.index[-1]
forecast_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=forecast_steps, freq='MS')

df_forecast = pd.DataFrame({
    'fecha': forecast_dates.strftime('%Y-%m-%d'),
    'pronostico': forecast_values.values
})

# 6. Guardar en CSV
df_forecast.to_csv('pronostico_py.csv', index=False)
