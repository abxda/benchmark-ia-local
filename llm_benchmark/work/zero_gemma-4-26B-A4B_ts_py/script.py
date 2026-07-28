import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

def main():
    # 1. Leer el archivo CSV
    try:
        df = pd.read_csv('serie_mensual.csv')
    except Exception as e:
        print(f"Error leyendo el archivo: {e}")
        return

    # 2. Preprocesar los datos
    # Convertir 'fecha' a datetime
    df['fecha'] = pd.to_datetime(df['fecha'])
    # Establecer 'fecha' como índice y asegurar frecuencia mensual
    df.set_index('fecha', inplace=True)
    df.index.freq = 'MS'  # Month Start

    # 3. Ajustar el modelo Holt-Winters aditivo
    # trend='add', seasonal='add', seasonal_periods=12
    model = ExponentialSmoothing(
        df['valor'],
        trend='add',
        seasonal='add',
        seasonal_periods=12
    )
    model_fit = model.fit()

    # 4. Generar pronóstico de 12 meses
    forecast_steps = 12
    forecast = model_fit.forecast(forecast_steps)

    # 5. Crear el DataFrame de pronóstico con el formato solicitado
    # El índice de forecast ya contiene las fechas siguientes
    forecast_df = pd.DataFrame({
        'fecha': forecast.index.strftime('%Y-%m-%d'),
        'pronostico': forecast.values
    })

    # 6. Guardar en 'pronostico_py.csv'
    forecast_df.to_csv('pronostico_py.csv', index=False)
    print("Pronóstico generado y guardado en 'pronostico_py.csv'")

if __name__ == "__main__":
    main()
