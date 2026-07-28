library(forecast)

df <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
df$fecha <- as.Date(df$fecha)
ts_data <- ts(df$valor, start = as.numeric(format(df$fecha[1], "%Y")), frequency = 12)
fit <- auto.arima(ts_data)
fc <- forecast(fit, h = 12)

last_date <- as.Date("2024-12-01") + months(0:11)
out <- data.frame(fecha = format(last_date, "%Y-%m-%d"), pronostico = as.numeric(fc$mean))
write.csv(out, "pronostico_r.csv", row.names = FALSE)
