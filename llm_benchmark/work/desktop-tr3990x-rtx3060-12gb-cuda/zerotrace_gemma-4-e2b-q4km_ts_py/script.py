import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from datetime import timedelta, date, datetime

# 1. Leer el archivo CSV
try:
    df = pd.read_csv('serie_mensual.csv')
except FileNotFoundError:
    print("Error: 'serie_mensual.csv' not found. Please ensure the file is in the current directory.")
    exit()

# Asegurarse de que las columnas existen y renombrarlas si es necesario (asumiendo nombres exactos)
if 'fecha' not in df.columns or 'valor' not in df.columns:
    print("Error: 'serie_mensual.csv' must contain 'fecha' and 'valor' columns.")
    exit()

# 2. Preparar los datos
# Convertir la columna 'fecha' a datetime y establecerla como índice
df['fecha'] = pd.to_datetime(df['fecha'])
df = df.sort_values(by='fecha').set_index('fecha')

# Asegurarse de que la frecuencia es mensual, si es necesario ajustar la frecuencia (aunque el modelo lo maneja)
# Para este caso, asumimos que los datos ya son mensuales.

# 3. Ajustar el modelo Holt-Winters Aditivo
# seasonal_periods=12 para estacionalidad anual
try:
    model = ExponentialSmoothing(
        df['valor'], 
        trend='add', 
        seasonal='add', 
        seasonal_periods=12
    ).fit()
    
    # 4. Generar pronóstico de 12 meses
    forecast_steps = 12
    forecast = model.forecast(forecast_steps)
    
    # 5. Crear DataFrame de pronóstico
    last_date = df.index[-1]
    future_dates = [last_date + timedelta(days=30*i) for i in range(1, forecast_steps + 1)] # Aproximación mensual
    
    forecast_df = pd.DataFrame({
        'fecha': [pd.to_datetime(d).strftime('%Y-%m-%d') for d in future_dates],
        'pronostico': forecast.values
    })
    
    # 6. Guardar el pronóstico
    forecast_df.to_csv('pronostico_py.csv', index=False)
    print("Pronóstico generado exitosamente en 'pronostico_py.csv'.")

except Exception as e:
    print(f"Ocurrió un error durante el ajuste del modelo o el pronóstico: {e}")