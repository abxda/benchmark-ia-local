library(forecast)
library(zoo)

series <- read.csv("serie_mensual.csv")
print("Original data:")
print(head(series))

# Create time series object with monthly frequency
ts_data <- ts(series$valor, start = 1, end = 72, frequency = 12)

# Get the forecast
model <- auto.arima(ts_data, seasonal = TRUE, stepwise = TRUE)
forecast <- forecast(model, h = 12)

print("\nForecast object:")
print(forecast)

# Manually create date sequence for forecast
start_date <- as.Date("2025-01-01")
forecast_dates <- seq(from = start_date, by = "month", length.out = 12)

print("\nForecast dates:")
print(forecast_dates)

output <- data.frame(
  fecha = format(forecast_dates, "%Y-%m-%d"),
  pronostico = round(forecast$mean, 2)
)

print("\nOutput dataframe:")
print(output)

write.csv(output, "pronostico_r.csv", row.names = FALSE)
print("\nForecast saved to pronostico_r.csv")
