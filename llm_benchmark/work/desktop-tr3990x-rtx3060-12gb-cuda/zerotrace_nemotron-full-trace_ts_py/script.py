#!/usr/bin/env python3
"""Script para ajustar modelo Holt-Winters aditivo y generar pronóstico de 12 meses."""

import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# 1. Leer datos
df = pd.read_csv('serie_mensual.csv')
print("Datos leídos:")
print(df.head())

# 2. Preparar serie temporal
# La columna 'fecha' ya tiene formato YYYY-MM-DD, la establecemos como índice
ts = df.set_index('fecha')['valor']
print("\nSerie temporal:")
print(ts)

# 3. Ajustar modelo Holt-Winters aditivo
model = ExponentialSmoothing(
    ts,
    trend='add',
    seasonal='add',
    seasonal_periods=12
)
fit = model.fit()
print("\nModelo ajustado:")
print(fit.summary())

# 4. Generar pronóstico de 12 meses
forecast = fit.forecast(12)
print("\nPronóstico de 12 meses:")
print(forecast)

# 5. Crear dataframe de fechas futuras
ultima_fecha = pd.to_datetime(df['fecha'].max())
fechas_futuras = pd.date_range(
    start=ultima_fecha + pd.offsets.MonthBegin(1),
    periods=12,
    freq='MS'
)

# 6. Guardar resultados
resultados = pd.DataFrame({
    'fecha': fechas_futuras.strftime('%Y-%m-%d'),
    'pronostico': forecast.values
})

resultados.to_csv('pronostico_py.csv', index=False)
print("\nResultados guardados en 'pronostico_py.csv':")
print(resultados)