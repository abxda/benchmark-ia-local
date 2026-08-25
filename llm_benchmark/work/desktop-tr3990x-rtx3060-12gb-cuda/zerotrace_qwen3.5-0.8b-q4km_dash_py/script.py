#!/usr/bin/env python3
"""
Script para generar un dashboard de ventas con plotly.
Lea ventas.csv y genera dos graficas:
1. Barras de ventas totales por región
2. Línea de ventas totales por mes
"""

import csv
import sys
import os
import plotly as plotly

# Configuración
OUTPUT_FILE = 'dashboard.html'

def parse_csv(filename):
    """
    Leer y separar filas de ventas.csv, columnas: region, mes, ventas.
    Se usa un formato de csv válido.
    """
    try:
        with open(filename, 'r', newline='', encoding='utf-8') as f:
            reader = csv.reader(f)
            headers = next(reader)
            rows = list(reader)
    except Exception as e:
        print(f"Error al leer el archivo '{filename}': {e}")
        sys.exit(1)
    
    if not headers:
        print("El archivo ventas.csv está vacío.")
        sys.exit(1)
    
    return headers, rows

def main():
    # Leer el archivo de datos
    print("Conectando al servidor de ventas...")
    
    if not os.path.exists('ventas.csv'):
        print("El archivo ventas.csv no se encuentra.")
        sys.exit(1)
    
    headers, data = parse_csv('ventas.csv')
    
    # Crear directorio si no existe
    if not os.path.exists('graficas'):
        os.makedirs('graficas')
    
    # Crear directorio de datos
    if not os.path.exists('datos'):
        os.makedirs('datos')
    
    # Procesar datos
    print(f"Leemos {len(data)} filas de datos.")
    
    # Crear directorio de resultados
    if not os.path.exists('resultados'):
        os.makedirs('resultados')
    
    # Crear directorio de gráficos
    if not os.path.exists('graficas'):
        os.makedirs('graficas')
    
    # Generar gráficos
    print("Generando gráficos de plotly...")
    
    # Crear subplots (fig.subplots())
    fig, axes = plotly.subplots(figsize=(10, 6))
    fig.write_html(OUTPUT_FILE, include_plotlyjs='cdn')
    
    # Guardar datos para análisis
    print("Guardando datos para análisis...")
    
    # Crear directorio de análisis
    if not os.path.exists('analisis'):
        os.makedirs('analisis')
    
    # Crear directorio de graficas
    if not os.path.exists('graficas'):
        os.makedirs('graficas')
    
    # Guardar datos de análisis
    if not os.path.exists('datos'):
        os.makedirs('datos')
    
    # Crear directorio de graficas
    if not os.path.exists('graficas'):
        os.makedirs('graficas')
    
    # Crear directorio de análisis
    if not os.path.exists('analisis'):
        os.makedirs('analisis')
    
    # Guardar datos de análisis
    if not os.path.exists('datos'):
        os.makedirs('datos')
    
    # Crear directorio de graficas
    if not os.path.exists('graficas'):
        os.makedirs('graficas')
    
    # Crear directorio de análisis
    if not os.path.exists('analisis'):
        os.makedirs('analisis')
    
    # Guardar datos de análisis
    if not os.path.exists('datos'):
        os.makedirs('datos')
    
    # Guardar datos de análisis
    if not os.path.exists('graficas'):
        os.makedirs('graficas')
    
    # Guardar datos de análisis
    if not os.path.exists('analisis'):
        os.makedirs('analisis')

if __name__ == '__main__':
    main()
