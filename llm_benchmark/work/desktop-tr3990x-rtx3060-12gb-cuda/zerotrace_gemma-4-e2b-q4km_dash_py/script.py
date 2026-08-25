import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import os

# Define file paths
csv_file = 'ventas.csv'
html_file = 'dashboard.html'
script_file = 'script.py'

try:
    # 1. Read the CSV file
    df = pd.read_csv(csv_file)

    # Ensure column names are as expected, handling potential case issues if necessary
    # Assuming columns are 'region', 'mes', 'ventas' based on the prompt.
    if not all(col in df.columns for col in ['region', 'mes', 'ventas']):
        print("Error: CSV must contain 'region', 'mes', and 'ventas' columns.")
        exit(1)

    # 2. Data Preparation
    # Aggregate sales by region
    region_sales = df.groupby('region')['ventas'].sum().reset_index()

    # Aggregate sales by month
    # Ensure 'mes' is treated as a categorical or datetime for proper ordering,
    # but for plotting, we'll group by the month name first.
    monthly_sales = df.groupby('mes')['ventas'].sum().reset_index()

    # 3. Create Subplots
    # Create figure with 2 rows and 1 column
    fig = make_subplots(rows=2, cols=1, subplot_titles=("Total Sales by Region", "Total Sales by Month"))

    # Add Bar Chart (Top subplot)
    fig.add_trace(
        go.Bar(x=region_sales['region'], y=region_sales['ventas'], name='Total Sales', marker_color='blue'),
        row=1, col=1
    )

    # Add Line Chart (Bottom subplot)
    fig.add_trace(
        go.Scatter(x=monthly_sales['mes'], y=monthly_sales['ventas'], name='Monthly Sales', mode='lines+markers', line=dict(color='red')),
        row=2, col=1
    )

    # 4. Update Layout
    fig.update_layout(
        title_text="Sales Dashboard",
        height=700,
        showlegend=True,
        template="plotly_white"
    )

    # Update axis labels for the first plot
    fig.update_xaxes(title_text="Region", row=1, col=1)
    fig.update_yaxes(title_text="Total Sales", row=1, col=1)

    # Update axis labels for the second plot
    fig.update_xaxes(title_text="Month", row=2, col=1)
    fig.update_yaxes(title_text="Total Sales", row=2, col=1)


    # 5. Write to HTML file
    print(f"Generating dashboard at {html_file}...")
    fig.write_html(html_file, include_plotlyjs='cdn')
    print(f"Successfully generated {html_file}")

except FileNotFoundError:
    print(f"Error: The file '{csv_file}' was not found in the current directory.")
except Exception as e:
    print(f"An unexpected error occurred during script execution: {e}")