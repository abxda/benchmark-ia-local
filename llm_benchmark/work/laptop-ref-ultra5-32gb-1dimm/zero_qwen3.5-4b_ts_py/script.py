import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from datetime import datetime, timedelta

# Leer los datos
df = pd.read_csv('serie_mensual.csv')
df['fecha'] = pd.to_datetime(df['fecha'])

# Ajustar modelo Holt-Winters aditivo
# ExponentialSmoothing con trend='add', seasonal='add', seasonal_periods=12
model = ExponentialSmoothing(
    df['valor'],
    trend='add',
    seasonal='add',
    seasonal_periods=12
)

# Ajustar el modelo
model_fitted = model.fit()

# Generar pronóstico de 12 meses
forecast = model_fitted.forecast(steps=12)

# Crear el DataFrame de resultados
# Los siguientes 12 meses partiendo de la última fecha (2025-12-01)
ultimo_mes = df['fecha'].max().month
ultimo_anio = df['fecha'].max().year
fechas_futuras = []
for i in range(12):
    mes = ultimo_mes + i + 1
    if mes > 12:
        mes = mes - 12
        ultimo_anio += 1
    fecha = datetime(ultimo_anio, mes, 1)
    fechas_futuras.append(fecha)

resultados = pd.DataFrame({
    'fecha': fechas_futuras,
    'pronostico': forecast.values
})

# Guardar en archivo CSV
resultados.to_csv('pronostico_py.csv', index=False)

# Mostrar resultados
print("Modelo ajustado exitosamente")
print(f"\nPronóstico para los próximos 12 meses:")
print(resultados.to_string(index=False))
print(f"\nMSE del modelo: {model_fitted.sse:.4f}")
print(f"AIC del modelo: {model_fitted.aic:.4f}")
