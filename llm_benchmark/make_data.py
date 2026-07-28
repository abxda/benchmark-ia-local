# Genera los datos sinteticos que usan todas las tareas del benchmark.
import numpy as np
import pandas as pd
from pathlib import Path

rng = np.random.default_rng(42)
BASE = Path(__file__).parent / "data"
BASE.mkdir(exist_ok=True)

# ventas.csv: region, mes, ventas (12 meses x 5 regiones)
regiones = ["Norte", "Sur", "Centro", "Oriente", "Occidente"]
meses = pd.date_range("2025-01-01", periods=12, freq="MS").strftime("%Y-%m")
rows = []
for r in regiones:
    base = rng.uniform(50, 200)
    for m in meses:
        rows.append({"region": r, "mes": m, "ventas": round(base + rng.uniform(-20, 40), 2)})
pd.DataFrame(rows).to_csv(BASE / "ventas.csv", index=False)

# serie_mensual.csv: 72 meses con tendencia + estacionalidad + ruido
n = 72
t = np.arange(n)
valor = 100 + 0.8 * t + 15 * np.sin(2 * np.pi * t / 12) + rng.normal(0, 5, n)
fechas = pd.date_range("2020-01-01", periods=n, freq="MS").strftime("%Y-%m-%d")
pd.DataFrame({"fecha": fechas, "valor": np.round(valor, 2)}).to_csv(BASE / "serie_mensual.csv", index=False)

print("datos generados en", BASE)
