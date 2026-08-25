# script.R

library(forecast)
library(tsibble)
library(tidyverse)

# 1. Read the data
data <- read.csv('serie_mensual.csv')
# Ensure date column is parsed correctly, assuming the first column is date and the second is value
data$fecha <- as.Date(data$fecha)

# Prepare data for ts object (assuming monthly data, frequency=12)
# We'll use the date column as the index for time series modeling
ts_data <- ts(data$valor, start = c(year(data$fecha[1]), month(data$fecha[1])), frequency = 12)

# 2. Fit an auto.arima model
model <- auto.arima(ts_data)

# 3. Generate a 12-month forecast
forecast_result <- forecast(model, h = 12)

# 4. Prepare the forecast data
forecast_df <- data.frame(
  fecha = seq(from = max(data$fecha) + 1, by = "month", length.out = 12),
  pronostico = forecast_result$mean
)

# Format dates to YYYY-MM-DD
forecast_df$fecha <- format(forecast_df$fecha, "%Y-%m-%d")

# 5. Save the forecast
write.csv(forecast_df, 'pronostico_r.csv', row.names = FALSE)

cat("Forecast successfully saved to pronostico_r.csv\n")