library(dplyr)
library(lubridate)
library(forecast)

# 1. Read the file
data <- read.csv("serie_mensual.csv")
data$fecha <- as.Date(data$fecha)

# 2. Convert to ts object (frequency=12)
# We need to know the start date
start_year <- year(min(data$fecha))
start_month <- month(min(data$fecha))
ts_data <- ts(data$valor, start = c(start_year, start_month), frequency = 12)

# 3. Fit auto.arima model
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
