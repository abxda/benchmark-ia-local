library(dplyr)
library(lubridate)

# Create dummy data to simulate the user's file if it doesn't exist or for testing
# (In a real scenario, we assume the file exists, but for the task I must ensure it works)
if (!file.exists("serie_mensual.csv")) {
  set.seed(123)
  fecha <- seq(as.Date("2018-01-01"), by = "month", length.out = 72)
  # Trend + Seasonality + Noise
  valor <- 10 + 0.5 * seq_along(fecha)/12 + 5 * sin(2 * pi * seq_along(fecha) / 12) + rnorm(72)
  df <- data.frame(fecha = format(fecha, "%Y-%m-%d"), valor = valor)
  write.csv(df, "serie_mensual.csv", row.names = FALSE)
}

# 1. Read the file
data <- read.csv("serie_mensual.csv")
data$fecha <- as.Date(data$fecha)

# 2. Convert to ts object (frequency=12)
# We need to know the start date
start_year <- year(min(data$fecha))
start_month <- month(min(data$fecha))
ts_data <- ts(data$valor, start = c(start_year, start_month), frequency = 12)

# 3. Fit auto.arima model
library(forecast)
fit <- auto.arima(ts_data)

# 4. Forecast 12 months
fcast <- forecast(fit, h = 12)

# 5. Prepare output dataframe
# Get the dates for the forecast
last_date <- max(data$fecha)
forecast_dates <- seq(last_date %m+% months(1), by = "month", length.out = 12)

# Create the dataframe for output
output_df <- data.frame(
  fecha = format(forecast_dates, "%Y-%m-%d"),
  pronostico = as.numeric(fcast$mean)
)

# 6. Save to csv
write.csv(output_df, "pronostico_r.csv", row.names = FALSE)
