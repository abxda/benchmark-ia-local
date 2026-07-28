import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing
import numpy as np
import datetime

# --- Configuration ---
INPUT_FILE = 'serie_mensual.csv'
OUTPUT_FILE = 'pronostico_py.csv'
FORECAST_HORIZON = 12
SEASONAL_PERIODS = 12

def load_data(file_path):
    """Loads the time series data from the CSV."""
    try:
        # Assuming the CSV has 'fecha' as the date column and 'valor' as the series value
        df = pd.read_csv(file_path)
        df['fecha'] = pd.to_datetime(df['fecha'])
        df = df.set_index('fecha')
        return df['valor']
    except FileNotFoundError:
        print(f"Error: Input file '{file_path}' not found.")
        return None
    except Exception as e:
        print(f"An error occurred while loading data: {e}")
        return None

def forecast_holt_winters(time_series):
    """Fits and forecasts using Holt-Winters Additive Exponential Smoothing."""
    print("Starting Holt-Winters model fitting...")
    
    # Initialize and fit the model
    # trend='add', seasonal='add', seasonal_periods=12
    try:
        model = ExponentialSmoothing(
            time_series, 
            trend='add', 
            seasonal='add', 
            seasonal_periods=SEASONAL_PERIODS
        )
        
        # Fit the model
        fit = model.fit()
        print("Model fitted successfully.")
        
        # Generate forecast
        forecast = fit.forecast(FORECAST_HORIZON)
        print(f"Forecast generated for {FORECAST_HORIZON} periods.")
        return forecast
    except Exception as e:
        print(f"An error occurred during model fitting or forecasting: {e}")
        return None

def save_forecast(forecast_series, output_file):
    """Generates future dates and saves the forecast to a CSV."""
    if forecast_series is None:
        print("No forecast data to save.")
        return

    # Get the last date from the input data to start the forecast dates
    try:
        # Read the file again, ensuring date parsing is explicit for robustness
        df_original = pd.read_csv(INPUT_FILE)
        df_original['fecha'] = pd.to_datetime(df_original['fecha'])
        last_date = df_original['fecha'].max()
    except Exception as e:
        print(f"Warning: Could not retrieve last date from input file: {e}. Using today's date as a fallback for start.")
        last_date = pd.to_datetime(datetime.date.today())
        
    # Generate future dates (monthly). Use last_date + 1 month.
    forecast_dates = pd.date_range(start=last_date + pd.DateOffset(months=1), periods=FORECAST_HORIZON, freq='MS')
    
    # Create the output DataFrame
    forecast_df = pd.DataFrame({
        'fecha': forecast_dates.strftime('%Y-%m-%d'),
        'pronostico': forecast_series.values
    })
    
    # Save to CSV
    forecast_df.to_csv(output_file, index=False)
    print(f"Successfully saved forecast to '{output_file}'.")

def main():
    """Main function to run the analysis pipeline."""
    
    # 1. Load Data
    ts_data = load_data(INPUT_FILE)
    if ts_data is None:
        return
    
    # 2. Forecast
    forecast_values = forecast_holt_winters(ts_data)
    
    # 3. Save Forecast
    save_forecast(forecast_values, OUTPUT_FILE)

if __name__ == "__main__":
    main()