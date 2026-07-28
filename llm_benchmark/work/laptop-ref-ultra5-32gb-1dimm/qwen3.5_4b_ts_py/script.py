import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing
import numpy as np

# Cargar los datos del CSV
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'])
df.set_index('fecha', inplace=True)

# Ajustar el modelo Holt-Winters aditivo con estacionalidad anual (12 periodos)
modelo = ExponentialSmoothing(df['valor'], trend='add', seasonal='add', seasonal_periods=12, initialized_by_fit=False)
modelo.fit()

# Generar pronósticos para los siguientes 12 meses
n_steps = 12
forecast = modelo.forecast(steps=n_steps)

# Crear el DataFrame de resultados con las fechas futuras y valores pronosticados
resultados_df = pd.DataFrame({
    'fecha': [pd.Timestamp('today') + pd.DateOffset(days=i*30.445) for i in range(n_steps)], # Aproximación mensual para YYYY-MM-DD si la fecha original no es exacta, o usar offset mes por mes
    'pronostico': forecast.values
})

# Si se requiere que las fechas sean exactamente un mes después de la última fecha del dataset:
ultima_fecha = df.index[-1]
resultados_df['fecha'] = [pd.Timestamp(ultima_fecha) + pd.DateOffset(months=i+1) for i in range(n_steps)]

# Guardar en el archivo CSV especificado
resultados_df.to_csv('pronostico_py.csv', index=False)
