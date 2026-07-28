import requests

# Intentar una petición simple a la API de INEGI (SID) para ver la estructura
# Usaremos una serie conocida si es posible, o simplemente probar la conexión.
# La URL base de la API de INEGI para series de tiempo (SID) suele ser algo como:
# https://www.inegi.org.mx/app/api/sid/query?series=XXXXX&token=YYYYY

def test_connection():
    print("Probando conexión a la API de INEGI...")
    try:
        # Nota: Sin un token real, esto fallará, pero quiero ver qué error devuelve.
        # El usuario pide datos REALES, por lo que necesitaré un método para obtenerlos.
        # A veces INEGI permite descargas vía URL de archivos CSV o Excel sin token para ciertas series,
        # o requiere registro para la API.
        response = requests.get("https://www.inegi.org.mx/app/api/sid/query?series=12345", timeout=5)
        print(f"Status Code: {response.status_code}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_connection()
