library(forecast)
library(readr)
library(zoo)

# 1. Read the data
data <- read_csv("serie_mensual.csv")

# Ensure 'fecha' is treated as Date and 'valor' as numeric
data$fecha <- as.Date(data$fecha)
data$valor <- as.numeric(data$valor)

# 2. Convert to time series (ts) with frequency=12 (annual seasonality)
# Assuming the data covers 72 months, this is appropriate.
ts_data <- ts(data$valor, start = c(format(min(data$fecha), "%Y"), format(min(data$fecha), "%m")), frequency = 12)

# 3. Fit an auto.arima model
model <- auto.arima(ts_data)

# 4. Generate a 12-month forecast
forecast_result <- forecast(model, h = 12)

# 5. Prepare output for saving
# Get the dates for the next 12 months
last_date <- index(ts_data)[length(index(ts_data))]
future_dates <- seq(from = last_date + 1, by = "month", length.out = 12)
# Format dates as YYYY-MM-DD
future_dates_formatted <- format(future_dates, "%Y-%m-%d")

# Create the final forecast dataframe
forecast_df <- data.frame(
  fecha = future_dates_formatted,
  pronostico = forecast_result$mean
)

# 6. Save the forecast
write_csv(forecast_df, "pronostico_r.csv")

cat("Forecast successfully generated and saved to pronostico_r.csv\n")