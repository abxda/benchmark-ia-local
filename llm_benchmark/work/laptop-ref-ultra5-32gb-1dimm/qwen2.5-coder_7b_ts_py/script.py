import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Cargar los datos
data = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'], index_col='fecha')

# Ajustar el modelo Holt-Winters aditivo
model = ExponentialSmoothing(data['valor'], trend='add', seasonal='add', seasonal_periods=12)
fit_model = model.fit()

# Generar pronóstico de 12 meses
forecast = fit_model.forecast(12)

# Crear DataFrame para el pronóstico
forecast_df = pd.DataFrame(forecast, index=pd.date_range(start=data.index[-1] + pd.DateOffset(months=1), periods=12, freq='M'), columns=['pronostico'])

# Guardar el pronóstico en un archivo CSV
forecast_df.to_csv('pronostico_py.csv', date_format='%Y-%m-%d')
