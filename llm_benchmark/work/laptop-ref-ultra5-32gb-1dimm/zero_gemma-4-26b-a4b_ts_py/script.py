import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing

def main():
    # Load the data
    try:
        df = pd.read_csv('serie_mensual.csv')
        df['fecha'] = pd.to_datetime(df['fecha'])
        df.set_index('fecha', inplace=True)
        # Ensure frequency is monthly
        df = df.asfreq('MS')
    except Exception as e:
        print(f"Error reading file: {e}")
        return

    # Fit Holt-Winters model
    # trend='add', seasonal='add', seasonal_periods=12
    try:
        model = ExponentialSmoothing(
            df['valor'],
            trend='add',
            seasonal='add',
            seasonal_periods=12
        ).fit()
    except Exception as e:
        print(f"Error fitting model: {e}")
        return

    # Forecast 12 months
    forecast_steps = 12
    forecast = model.forecast(forecast_steps)

    # Create forecast DataFrame
    # The index of forecast will be the dates
    forecast_df = pd.DataFrame({
        'fecha': forecast.index,
        'pronostico': forecast.values
    })

    # Format date as YYYY-MM-DD
    forecast_df['fecha'] = forecast_df['fecha'].dt.strftime('%Y-%m-%d')

    # Save to CSV
    try:
        forecast_df.to_csv('pronostico_py.csv', index=False)
        print("Successfully generated pronostico_py.csv")
    except Exception as e:
        print(f"Error saving file: {e}")

if __name__ == "__main__":
    main()
