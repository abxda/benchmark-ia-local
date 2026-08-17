import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer el archivo CSV
df = pd.read_csv('serie_mensual.csv')

# Asegurar que 'fecha' sea datetime
df['fecha'] = pd.to_datetime(df['fecha'])

# Ordenar por fecha
df = df.sort_values('fecha').reset_index(drop=True)

# Verificar que se cargaron correctamente los datos
print(f"Datos cargados: {len(df)} registros")
print(f"Columnas: {df.columns.tolist()}")
print(f"\nPrimeros 10 registros:")
print(df.head(10))

# Ajustar modelo Holt-Winters aditivo
model = ExponentialSmoothing(
    df['valor'],
    trend='add',
    seasonal='add',
    seasonal_periods=12
)
fit_model = model.fit()

# Generar pronostico de 12 meses
forecast = fit_model.forecast(12)

# Crear fechas futuras (meses siguientes en formato YYYY-MM-DD)
last_date = df['fecha'].max()
next_dates = pd.date_range(start=last_date + pd.Timedelta(days=1), periods=12, freq='ME')

# Crear DataFrame de pronostico
forecast_df = pd.DataFrame({
    'fecha': next_dates,
    'pronostico': forecast
})

# Guardar en CSV
forecast_df.to_csv('pronostico_py.csv', index=False)

print(f"\nPronostico generado:")
print(f"Fecha ultima del historico: {last_date}")
print(f"Fecha primera del pronostico: {next_dates[0]}")
print(f"\nResultados del pronostico:")
print(forecast_df)
print(f"\nArchivo guardado: pronostico_py.csv")
