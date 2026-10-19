# R Script for ARIMA Forecasting

# Load required library
library(forecast)

# Read the CSV file
series <- read.csv("serie_mensual.csv")

# Create time series object with monthly frequency
ts_data <- ts(series$valor, start = 1, end = 72, frequency = 12)

# Fit ARIMA model using auto.arima
model <- auto.arima(ts_data, seasonal = TRUE, stepwise = TRUE)

# Generate 12-month forecast
forecast <- forecast(model, h = 12)

# Create output dataframe
output <- data.frame(
  fecha = format(forecast$time, "%Y-%m-%d"),
  pronostico = round(forecast$mean, 2)
)

# Save to CSV
write.csv(output, "pronostico_r.csv", row.names = FALSE)

print("Forecast saved to pronostico_r.csv")
