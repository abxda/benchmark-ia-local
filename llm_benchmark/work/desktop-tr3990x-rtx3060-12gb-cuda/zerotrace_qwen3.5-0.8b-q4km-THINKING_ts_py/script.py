#!/usr/bin/env python3
"""
Script para leer serie_mensual.csv y aplicar Holt-Winters aditivo con statsmodels.
Genera un pronóstico de 12 meses y lo guarda en pronostico_py.csv.
"""

import csv
import os
from datetime import datetime
from statsmodels.tsa.statmodels import ExponentialSmoothing
from statsmodels.tsa.models import RegressionModel
import numpy as np

# Configuración
OUTPUT_FILE = "pronostico_py.csv"

def main():
    # Leer la serie
    serie_path = "serie_mensual.csv"
    print(f"Leendo serie: {serie_path}")
    
    series = []
    with open(serie_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            series.append({'fecha': row['fecha'], 'valor': float(row['valor'])})
    
    print(f"Se encontraron {len(series)} datos de la serie")
    
    # Procesar serie: filtrar los primeros 72 meses (12 meses de tendencia + 60 meses de estacionalidad)
    start_date = datetime(2020, 1, 1)
    end_date = start_date + datetime.timedelta(days=72*30)
    
    # Filtrar datos válidos
    valid_data = [
        s for s in series
        if s['fecha'] >= start_date and s['fecha'] <= end_date
    ]
    
    print(f"Validos en la serie: {len(valid_data)}")
    
    # Crear índice de mes
    for i, item in enumerate(valid_data):
        item['mes'] = valid_data[i]['fecha'].strftime('%m')
    
    # Aplicar Holt-Winters
    trend, seasonal, seasonal_period = ExponentialSmoothing(
        data=valid_data,
        trend='add',
        seasonal='add',
        seasonal_periods=12
    )
    
    print(f"Tendencia: {trend.name}")
    print(f"Estacionalidad: {seasonal.name}")
    
    # Calcular pronósticos
    pronosticos = []
    for item in valid_data:
        if item['mes'] in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']:
            item['pronostico'] = item['valor'] + trend.period_at_trend(item['mes']) + seasonal.period_at_seasonality(item['mes'])
        else:
            item['pronostico'] = None
    
    print(f"Pronósticos calculados para {len(valid_data)} meses")
    
    # Guardar output
    with open(OUTPUT_FILE, 'w') as f:
        writer = csv.writer(f)
        writer.writerow(['fecha', 'pronostico'])
        for item in valid_data:
            if item['pronostico'] is not None:
                writer.writerow([item['mes'], item['pronostico']])
    
    print(f"Archivo {OUTPUT_FILE} guardado con éxito")
    
    return valid_data, trend, seasonal, seasonal_period

if __name__ == "__main__":
    main()
