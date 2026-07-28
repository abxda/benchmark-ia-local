import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing
import numpy as np

# Read the CSV file
df = pd.read_csv('serie_mensual.csv')

# Convert fecha column to datetime
df['fecha'] = pd.to_datetime(df['fecha'])

# Set fecha as index
df.set_index('fecha', inplace=True)

try:
    # Fit Holt-Winters model with additive trend and seasonality
    model = ExponentialSmoothing(
        df['valor'],
        trend='add',
        seasonal='add',
        seasonal_periods=12
    )

    # Fit the model
    fitted_model = model.fit()

    # Generate forecast for 12 months
    forecast = fitted_model.forecast(steps=12)

    # Create date range for forecast
    last_date = df.index[-1]
    forecast_dates = []
    for i in range(1, 13):
        # Add months to last date
        new_date = last_date + pd.DateOffset(months=i)
        forecast_dates.append(new_date.strftime('%Y-%m-%d'))

    # Create DataFrame with forecast
    forecast_df = pd.DataFrame({
        'fecha': forecast_dates,
        'pronostico': np.round(forecast.values, 2)
    })

    # Save to CSV
    forecast_df.to_csv('pronostico_py.csv', index=False)

    print("Forecast saved to pronostico_py.csv")
    print(forecast_df)
    
except Exception as e:
    print(f"Error in model fitting or forecasting: {e}")
    raise