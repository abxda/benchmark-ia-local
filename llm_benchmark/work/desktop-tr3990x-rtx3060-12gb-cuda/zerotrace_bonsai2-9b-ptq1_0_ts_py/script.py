#!/usr/bin/env python3
"""
Script para ajustar un modelo Holt-Winters aditivo y generar pronósticos.
Lectura: serie_mensual.csv (fecha, valor) - 72 meses de datos
Modelo: ExponentialSmoothing con trend='add', seasonal='add', seasonal_periods=12
Salida: pronostico_py.csv con columnas 'fecha', 'pronostico'
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')

from statsmodels.tsa.holtwinters import ExponentialSmoothing


def main():
    print("Leer series_mensual.csv...")
    try:
        df = pd.read_csv('serie_mensual.csv')
        print(f"Datos cargados: {len(df)} registros")
        print(df.head())
        print(df.tail())
        print(f"Columnas: {df.columns.tolist()}")
    except FileNotFoundError:
        print("ERROR: El archivo serie_mensual.csv no se encontró.")
        return
    except Exception as e:
        print(f"ERROR al leer el archivo: {e}")
        return

    if 'fecha' not in df.columns or 'valor' not in df.columns:
        print("ERROR: El archivo debe tener columnas 'fecha' y 'valor'.")
        return

    df = df.copy()
    df['fecha'] = pd.to_datetime(df['fecha'])
    df = df.sort_values('fecha')
    print(f"Datos ordenados por fecha")

    print("Ajustando modelo Holt-Winters...")
    try:
        model = ExponentialSmoothing(
            endog=df['valor'],
            trend='add',
            seasonal='add',
            seasonal_periods=12,
            initialization_method='method_of_moms',
            validation_periods=5
        )
        forecast_result = model.fit()
        print("Modelo entrenado exitosamente.")
        print(f"Estadísticas del modelo:\n{forecast_result.summary()}")
    except Exception as e:
        print(f"ERROR al ajustar el modelo: {e}")
        return

    print("Generando pronóstico de 12 meses...")
    try:
        forecast_periods = 12
        last_date = df['fecha'].iloc[-1]
        forecast_dates = [last_date + timedelta(days=30 * i) for i in range(forecast_periods)]
        forecast_dates = pd.to_datetime(forecast_dates)
        forecast_df = pd.DataFrame({'fecha': forecast_dates})
        forecast = forecast_result.forecast(forecast_periods)
        forecast_df['pronostico'] = forecast.values
        print(f"Generado {forecast_periods} pronosticos:")
        print(forecast_df)
        output_path = 'pronostico_py.csv'
        forecast_df.to_csv(output_path, index=False)
        print(f"Resultado guardado en {output_path}")
        print("\nContenido del archivo generado:")
        print(forecast_df)
        if not pd.api.files.exists(output_path):
            print("ERROR: El archivo pronostico_py.csv no fue generado correctamente.")
            return
        print("\nVERIFICACIÓN COMPLETADA - Script executed successfully!")
    except Exception as e:
        print(f"ERROR al generar o guardar el pronóstico: {e}")
        return

if __name__ == '__main__':
    main()
