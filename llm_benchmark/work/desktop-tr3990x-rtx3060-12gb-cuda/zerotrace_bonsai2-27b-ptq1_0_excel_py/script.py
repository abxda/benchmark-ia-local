import pandas as pd


def main():
    df = pd.read_csv("ventas.csv")
    resumen = (
        df.groupby("region", as_index=False)["ventas"]
        .sum()
        .rename(columns={"ventas": "ventas_totales"})
    )
    resumen.to_excel(
        "reporte.xlsx",
        sheet_name="Resumen",
        index=False,
        engine="openpyxl",
    )


if __name__ == "__main__":
    main()
