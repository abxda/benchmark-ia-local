import pandas as pd
import numpy as np
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from datetime import timedelta

# --- Configuración ---
INPUT_FILE = 'serie_mensual.csv'
OUTPUT_FILE = 'pronostico_py.csv'
SEASONAL_PERIODS = 12
FORECAST_HORIZON = 12

# --- 1. Carga de datos ---
try:
    df = pd.read_csv(INPUT_FILE)
except FileNotFoundError:
    print(f"Error: El archivo '{INPUT_FILE}' no fue encontrado. Asegúrate de que el archivo exista.")
    exit()

# Asegurar que la columna 'fecha' sea de tipo datetime
df['fecha'] = pd.to_datetime(df['fecha'])

# Establecer la fecha como índice (necesario para series de tiempo)
df = df.set_index('fecha')

# Extraer la serie de valores
ts = df['valor']

# --- 2. Ajuste del modelo Holt-Winters Aditivo ---
try:
    # Ajustar el modelo Holt-Winters aditivo
    model = ExponentialSmoothing(
        ts,
        trend='add',
        seasonal='add',
        seasonal_periods=SEASONAL_PERIODS,
        initialization_method='estimated'
    )
    
    # Ajustar el modelo
    fit = model.fit()

    # --- 3. Generación del pronóstico ---
    # Generar pronósticos para los próximos 12 meses
    forecast = fit.forecast(FORECAST_HORIZON)

    # --- 4. Preparación de la salida ---
    
    # Determinar la fecha de inicio del pronóstico
    last_date = ts.index[-1]
    
    # Crear las fechas futuras (mes a mes)
    future_dates = [last_date + timedelta(days=30 * (i + 1)) for i in range(FORECAST_HORIZON)]
    
    # Crear el DataFrame de pronóstico
    forecast_df = pd.DataFrame({
        'fecha': future_dates,
        'pronostico': forecast.values
    })
    
    # Formatear la fecha al estándar YYYY-MM-DD
    forecast_df['fecha'] = forecast_df['fecha'].dt.strftime('%Y-%m-%d')

    # --- 5. Guardar el resultado ---
    forecast_df.to_csv(OUTPUT_FILE, index=False)
    print(f"Pronóstico generado y guardado exitosamente en '{OUTPUT_FILE}'")

except Exception as e:
    print(f"Ocurrió un error durante el ajuste o pronóstico del modelo: {e}")

