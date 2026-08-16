import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

def main():
    # Leer los datos
    try:
        df = pd.read_csv('serie_mensual.csv')
        df['fecha'] = pd.to_datetime(df['fecha'])
        df.set_index('fecha', inplace=True)
        
        # Asegurar frecuencia mensual (MS = Month Start)
        df.index = df.index.to_period('M').to_timestamp()
    except Exception as e:
        print(f"Error leyendo el archivo: {e}")
        return

    # Ajustar el modelo Holt-Winters aditivo
    # trend='add', seasonal='add', seasonal_periods=12
    try:
        model = ExponentialSmoothing(
            df['valor'],
            trend='add',
            seasonal='add',
            seasonal_periods=12
        )
        model_fit = model.fit()
    except Exception as e:
        print(f"Error ajustando el modelo: {e}")
        return

    # Generar pronóstico de 12 meses
    forecast = model_fit.forecast(12)
    
    # Crear DataFrame para el pronóstico
    # El índice de forecast será el periodo siguiente al último en df
    last_date = df.index[-1]
    forecast_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=12, freq='MS')
    
    df_forecast = pd.DataFrame({
        'fecha': forecast_dates.strftime('%Y-%m-%d'),
        'pronostico': forecast.values
    })

    # Guardar en 'pronostico_py.csv'
    try:
        df_forecast.to_csv('pronostico_py.csv', index=False)
        print("Pronóstico guardado exitosamente en 'pronostico_py.csv'")
    except Exception as e:
        print(f"Error guardando el archivo de salida: {e}")

if __name__ == "__main__":
    main()
