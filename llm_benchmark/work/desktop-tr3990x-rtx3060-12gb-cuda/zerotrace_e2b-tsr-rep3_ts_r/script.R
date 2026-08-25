# Load necessary libraries
library(forecast)

# Read data
data <- read.csv("serie_mensual.csv")
# Assuming columns are 'fecha' and 'valor'. Need to convert 'fecha' to Date object.
data$fecha <- as.Date(data$fecha)

# Convert to time series (frequency=12 for monthly data)
ts_data <- ts(data$valor, start = c(year(data$fecha[1]), month(data$fecha[1])), frequency = 12)

# Fit auto.arima model
model <- auto.arima(ts_data)

# Generate 12-month forecast
forecast_result <- forecast(model, h = 12)

# Prepare forecast data: Generate dates 12 months after the last observed date
last_date <- index(ts_data)[length(ts_data)]
forecast_dates <- seq(from = last_date + 1, length.out = 12, by = "month")

# Prepare final output dataframe
forecast_df <- data.frame(
  fecha = format(forecast_dates, "%Y-%m-%d"),
  pronostico = forecast_result$mean
)

# Save to CSV
write.csv(forecast_df, "pronostico_r.csv", row.names = FALSE)