#!/usr/bin/env python3
"""
Script to read serie_mensual.csv and apply Holt-Winters additive model with statsmodels.
The output is saved to pronostico_py.csv with columns: 'meses siguientes en formato YYYY-MM-DD' and 'pronostico'.
"""

import csv
from datetime import datetime
from pathlib import Path
import warnings
warnings.filterwarnings('ignore')

# Paths
SERIES_FILE = Path("/mnt/data_4tb/IA-Local/benchmark-ia-local/llm_benchmark/work/desktop-tr3990x-rtx3060-12gb-cuda/zerotrace_qwen3.5-0.8b-q4km_ts_py/serie_mensual.csv")
OUTPUT_FILE = Path("/mnt/data_4tb/IA-Local/benchmark-ia-local/llm_benchmark/work/desktop-tr3990x-rtx3060-12gb-cuda/zerotrace_qwen3.5-0.8b-q4km_ts_py/pronostico_py.csv")

# Holt-Winters model parameters
TRENDS = ['add']
SEASONAL = ['add']
SEASONAL_PERIODS = 12

# Define trend parameters
TRENDS = ['add']

# Define seasonality parameters
SEASONAL = ['add']
SEASONAL_PERIODS = 12

# Define noise parameters
THETA = 0.1

def parse_date(date_str: str) -> datetime:
    """Parse a date string in YYYY-MM-DD format."""
    try:
        return datetime.fromisoformat(date_str.replace('Z', '+00:00'))
    except:
        raise ValueError(f"Invalid date: {date_str}")

def apply_holt_winters(model: dict) -> None:
    """
    Apply Holt-Winters additive model.
    
    Holt-Winters:
    x_t = alpha * x_{t-1} + beta * x_{t-2} + gamma * x_{t-3} + theta * x_{t-4} + 
    (epsilon_t + trend_t) + seasonal_t * seasonal_period + noise_t
    
    Where:
    - alpha: decay rate for trend
    - beta: decay rate for seasonality
    - gamma: decay rate for seasonality
    - theta: decay rate for noise
    - trend: 'add' (treat trend as a separate seasonal component)
    - seasonal: 'add' (treat seasonality as separate seasonal component)
    - seasonal_periods: number of seasonal periods (months in a year)
    
    The model generates one forecast for each month.
    """
    # Load data
    df = pd.read_csv(SERIES_FILE, sep=',')
    
    # Get the columns to keep
    kept_cols = ['fecha', 'valor']
    df_clean = df[kept_cols]
    
    # Validate data
    if len(df_clean) < 2:
        raise ValueError("Insufficient data for Holt-Winters model")
    
    # Create model for the first month
    model['forecast'] = None
    model['dates'] = []
    model['start_date'] = parse_date(df_clean.iloc[0]['fecha'])
    model['current_date'] = model['start_date']
    model['start_date_dt'] = model['start_date'].date()
    
    for idx, row in df_clean.iterrows():
        df_clean.loc[idx, 'fecha'] = model['current_date'].date().strftime('%Y-%m-%d')
        
        df_clean.loc[idx, 'valor'] = row['valor']
        
        # Apply Holt-Winters to each value
        for j in range(12):
            df_clean.loc[idx, 'valor'] = apply_holt_winters_single(row, model, j)
    
    # Calculate statistics
    stats = calculate_statistics(model)
    
    # Generate forecasts for each month
    for idx, row in df_clean.iterrows():
        df_clean.loc[idx, 'fecha'] = model['current_date'].date().strftime('%Y-%m-%d')
        
        # Generate one month's forecast for this row
        df_clean.loc[idx, 'pronostico'] = model['forecast'][idx]
    
    # Save output
    df_output = df_clean.copy()
    df_output['meses siguientes en formato YYYY-MM-DD'] = df_clean['fecha'].dt.to_period('M')
    df_output.to_csv(OUTPUT_FILE, index=False)
    
    # Print statistics
    print(f"Statistics calculated for model: {model['forecast']}")
    print(f"Start date: {model['start_date']}, End date: {model['current_date']}")
    print(f"Forecast span: {model['current_date'] - model['start_date']}\n")
    print(stats)

def apply_holt_winters_single(row: dict, model: dict, j: int) -> float:
    """
    Apply Holt-Winters single value prediction for one month.
    """
    # Holt-Winters parameters for additive model
    alpha = model['alpha']
    beta = model['beta']
    gamma = model['gamma']
    theta = model['theta']
    
    # Extract seasonality from previous 4 values
    previous_seasonal = []
    for i in range(4):
        if i >= len(model['seasonal']):
            previous_seasonal.append(0.0)
        else:
            previous_seasonal.append(model['seasonal'][i])
    
    # Extract trend
    if model['trend'] != 'add':
        raise ValueError(f"Model requires trend='add', got: {model['trend']}")
    
    # Calculate trend difference
    trend_diff = row['valor'] - row['valor'][-1]
    trend = (trend_diff / 2.0) if trend_diff != 0 else 0.0
    
    # Apply prediction
    forecast = alpha * row['valor'] + beta * row['valor'][-1] + \
                gamma * row['valor'][-2] + theta * row['valor'][-3] + \
                (previous_seasonal[j] + trend)
    
    return forecast

def calculate_statistics(model: dict) -> dict:
    """Calculate statistics for the Holt-Winters model."""
    forecast = model['forecast']
    start_date = model['start_date'].date()
    end_date = model['current_date'].date()
    
    # Calculate time span in months
    months = (end_date - start_date).days // 30
    
    # Calculate mean
    mean = sum(forecast) / len(forecast)
    
    # Calculate standard deviation
    if len(forecast) > 1:
        std = (forecast[1] - forecast[-1]) ** 0.5
    else:
        std = 0.0
    
    # Calculate mean and std
    mean_std = mean / (months + 0.5)
    
    return {
        'mean': mean,
        'std': std,
        'months': months,
        'alpha': model['alpha'],
        'beta': model['beta'],
        'gamma': model['gamma'],
        'theta': model['theta'],
        'trend': model['trend'],
        'seasonal': model['seasonal']
    }

if __name__ == "__main__":
    print("=" * 60)
    print("Holt-Winters Additive Model with statsmodels")
    print("=" * 60)
    print(f"Series file: {SERIES_FILE}")
    print(f"Output file: {OUTPUT_FILE}")
    print()
    
    try:
        apply_holt_winters(model={
            'trend': TRENDS,
            'seasonal': SEASONAL,
            'seasonal_periods': SEASONAL_PERIODS,
        })
    except ValueError as e:
        print(f"Error: {e}")
        raise
