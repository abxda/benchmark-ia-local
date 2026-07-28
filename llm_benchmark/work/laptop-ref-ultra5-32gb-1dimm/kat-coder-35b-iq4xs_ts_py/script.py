import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing

df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'], index_col='fecha')
model = ExponentialSmoothing(df['valor'], trend='add', seasonal='add', seasonal_periods=12)
fit = model.fit()
forecast = fit.forecast(12)
last_date = df.index[-1]
future_dates = pd.date_range(start=last_date + pd.offsets.MonthBegin(1), periods=12, freq='MS')
result = pd.DataFrame({'fecha': future_dates, 'pronostico': forecast.values})
result.to_csv('pronostico_py.csv', index=False)
