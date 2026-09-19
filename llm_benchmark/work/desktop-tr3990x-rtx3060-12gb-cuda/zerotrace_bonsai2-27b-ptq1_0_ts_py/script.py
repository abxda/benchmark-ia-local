"""
Script de pronóstico con Holt-Winters aditivo (statsmodels)

Lee 'serie_mensual.csv' (columns: fecha, valor), ajusta un modelo de
ExponentialSmoothing (Holt-Winters aditivo) con period=12 y genera
un pronóstico de 12 meses a futuro.

Salida: 'pronostico_py.csv' con columnas 'fecha' (YYYY-MM-DD, meses
siguientes tras el último dato) y 'pronostico'.
"""

import pandas as pd
from statsmodels.tsa.holtwinters import ExponentialSmoothing


def main():
    # 1. Carga los datos
    df = pd.read_csv("serie_mensual.csv")
    df["fecha"] = pd.to_datetime(df["fecha"], format="%Y-%m-%d")
    df = df.set_index("fecha")
    df = df.sort_index()

    # Validaciones básicas
    if len(df) != 72:
        print(f"Advertencia: se esperaba 72 observaciones, se leyeron {len(df)}.")
    if not df.index.is_monotonic_increasing:
        raise ValueError("El índice temporal no está ordenado.")

    # 2. Ajusta el modelo Holt-Winters aditivo (trend ad, seasonal ad, 12)
    model = ExponentialSmoothing(
        df["valor"],
        trend="add",
        seasonal="add",
        seasonal_periods=12,
    )
    fit = model.fit()
    print(fit.summary())

    # 3. Pronóstico de 12 meses
    forecast = fit.forecast(12)

    # 4. Fechas de los 12 meses siguientes en formato YYYY-MM-DD
    last_date = df.index[-1]
    # La última fecha de la serie ya es un 1 del mes. Usamos offset de meses
    # para que el primer pronóstico corresponda al mes siguiente.
    next_dates = [
        (last_date + pd.DateOffset(months=k)) for k in range(1, 13)
    ]

    # 5. Guarda en CSV
    out = pd.DataFrame(
        {
            "fecha": [d.strftime("%Y-%m-%d") for d in next_dates],
            "pronostico": forecast.astype(float).values,
        }
    )
    out.to_csv("pronostico_py.csv", index=False)

    print("Pronóstico de 12 meses:")
    print(out.to_string(index=False))
    print("Archivo guardado en 'pronostico_py.csv'.")


if __name__ == "__main__":
    main()
