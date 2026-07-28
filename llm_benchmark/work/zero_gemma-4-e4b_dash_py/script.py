import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from datetime import datetime

# --- Configuration ---
CSV_FILE = 'ventas.csv'
OUTPUT_FILE = 'dashboard.html'

def create_dashboard():
    """
    Reads ventas.csv, generates sales visualizations, and saves them to dashboard.html.
    """
    try:
        # 1. Load data
        df = pd.read_csv(CSV_FILE)
        print(f"Successfully loaded {CSV_FILE}. Data head:\n{df.head()}")

    except FileNotFoundError:
        print(f"Error: {CSV_FILE} not found. Please ensure the file is in the correct directory.")
        return
    except Exception as e:
        print(f"An error occurred while reading the CSV file: {e}")
        return

    # Ensure 'ventas' is numeric
    df['ventas'] = pd.to_numeric(df['ventas'], errors='coerce')
    df.dropna(subset=['ventas'], inplace=True)

    # 2. Data Aggregation
    # Sales totals by region (for Bar Chart)
    region_sales = df.groupby('region')['ventas'].sum().reset_index()
    region_sales = region_sales.sort_values(by='ventas', ascending=False)

    # Sales totals by month (for Line Chart)
    # Convert 'mes' to datetime objects for proper plotting order
    df['date'] = pd.to_datetime(df['mes'])
    monthly_sales = df.groupby(df['date'].dt.to_period('M'))['ventas'].sum().reset_index()
    # Convert Period object back to string for consistent display/ordering if necessary, 
    # but Plotly handles datetime objects well.
    monthly_sales['date'] = monthly_sales['date'].dt.to_timestamp()
    monthly_sales = monthly_sales.sort_values(by='date')

    print("Data aggregated successfully for regional and monthly sales.")

    # 3. Create Plotly Figure with Subplots
    # We need a figure with 2 rows and 1 column for the two charts.
    fig = make_subplots(
        rows=2, cols=1,
        shared_xaxes=True,
        vertical_spacing=0.1,
        subplot_titles=("Ventas Totales por Región", "Ventas Totales por Mes")
    )

    # --- Chart 1: Bar chart of total sales by region (Row 1) ---
    # We use the aggregated data for regional sales.
    fig.add_trace(
        go.Bar(
            x=region_sales['region'],
            y=region_sales['ventas'],
            name="Ventas por Región",
            marker_color='skyblue'
        ),
        row=1, col=1
    )
    fig.update_yaxes(title_text="Ventas Totales", row=1, col=1)
    fig.update_xaxes(title_text="Región", row=1, col=1)


    # --- Chart 2: Line chart of total sales by month (Row 2) ---
    fig.add_trace(
        go.Scatter(
            x=monthly_sales['date'],
            y=monthly_sales['ventas'],
            name="Ventas Mensuales",
            mode='lines+markers',
            line=dict(color='orange')
        ),
        row=2, col=1
    )
    fig.update_yaxes(title_text="Ventas Totales", row=2, col=1)
    # Format x-axis for dates in the second plot
    fig.update_xaxes(tickformat="%b\n%Y", row=2, col=1)


    # 4. Final Layout Update
    fig.update_layout(
        title_text="Dashboard de Ventas por Región y Mes",
        height=700,
        showlegend=True
    )

    # 5. Save to HTML
    try:
        fig.write_html(OUTPUT_FILE, include_plotlyjs='cdn')
        print(f"\n✅ Success: Dashboard successfully created at {OUTPUT_FILE}")
    except Exception as e:
        print(f"Error while saving the HTML file: {e}")

if __name__ == "__main__":
    # Check if pandas and plotly are installed. This is crucial for execution.
    try:
        import pandas
        import plotly
    except ImportError:
        print("Dependencies missing. Please install them using: pip install pandas plotly")
        exit(1)
    
    create_dashboard()