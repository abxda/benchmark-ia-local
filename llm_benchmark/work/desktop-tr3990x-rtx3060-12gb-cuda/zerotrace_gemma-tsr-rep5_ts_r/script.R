# Load necessary libraries
library(forecast)

# Read the data
data <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)

# Convert fecha to Date
data$fecha <- as.Date(data$fecha)

# Convert valor to ts with frequency=12
# We need to know the start date to set the ts object correctly
start_year <- as.numeric(format(min(data$fecha), "%Y"))
start_month <- as.numeric(format(min(data$fecha), "%m"))
ts_data <- ts(data$valor, start = c(start_year, start_month), frequency = 12)

# Fit auto.arima model
model <- auto.arima(ts_data)

# Forecast 12 months
forecast_result <- forecast(model, h = 12)

# Generate future dates
# Get the last date in the original data
last_date <- max(data$fecha)

# Create a sequence of dates for the forecast
# The start of the forecast is the month after the last observation
# We use seq.Date to increment months
start_forecast_date <- seq(last_date, by = "month", length.out = 2)[2]
forecast_dates <- seq(start_forecast_date, by = "month", length.out = 12)

# Prepare the output data frame
output_df <- data.frame(
  fecha = format(forecast_dates, "%Y-%m-%d"),
  pronostico = as.numeric(forecast_result$mean)
)

# Save to CSV
write.csv(output_df, "pronostico_r.csv", row.names = FALSE)
