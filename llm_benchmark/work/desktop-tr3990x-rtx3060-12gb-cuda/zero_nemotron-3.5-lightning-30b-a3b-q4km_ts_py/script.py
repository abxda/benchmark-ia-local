#!/usr/bin/env python3
import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

# Leer los datos
df = pd.read_csv('serie_mensual.csv', parse_dates=['fecha'])
print("Datos cargados:")
print(df.head())

# Ajustar modelo Holt-Winters aditivo
model = ExponentialSmoothing(df['valor'], trend='add', seasonal='add', seasonal_periods=12)
modelo_ajustado = model.fit()

# Pronosticar 12 meses
pronostico = modelo_ajustado.forecast(12)
print("\nPronóstico de 12 meses:")
print(pronostico)

# Generar fechas para el pronóstico
ultima_fecha = df['fecha'].max()
fechas_pronostico = pd.date_range(start=ultima_fecha + pd.DateOffset(months=1), periods=12, freq='ME')
print("\nFechas de pronóstico:")
for f in fechas_pronostico:
    print(f)

# Crear DataFrame con resultados
resultados = pd.DataFrame({
    'fecha': fechas_pronostico.strftime('%Y-%m-%d'),
    'pronostico': pronostico.values
})

# Guardar en CSV
resultados.to_csv('pronostico_py.csv', index=False)
print("\nResultados guardados en 'pronostico_py.csv':")
print(resultados)