library(forecast)
library(tseries)

# 1. Read the data
data <- read.csv("serie_mensual.csv", header = TRUE)

# Ensure 'fecha' is in date format for proper time series handling
data$fecha <- as.Date(data$fecha)

# 2. Convert to Time Series (TS) with frequency=12 (monthly data)
tss <- ts(data$valor, start = c(year(data$fecha[1]), month(data$fecha[1])), frequency = 12)

# 3. Fit an auto.arima model
model <- auto.arima(tss, stepwise = FALSE, approximation = FALSE)

# 4. Generate a 12-month forecast
forecast_result <- forecast(model, h = 12)

# 5. Prepare forecast data for saving
# Generate the next 12 dates starting from the month after the last data point
last_date <- max(data$fecha)
future_dates <- seq(last_date + 1, by = "month", length.out = 12)

# Create a data frame for the forecast
forecast_df <- data.frame(
  fecha = format(future_dates, "%Y-%m-%d"),
  pronostico = forecast_result$mean
)

# 6. Save the forecast
write.csv(forecast_df, "pronostico_r.csv", row.names = FALSE)

cat("Pronóstico generado y guardado en pronostico_r.csv")