library(forecast)

d <- read.csv("serie_mensual.csv", stringsAsFactors = FALSE)
d$fecha <- as.Date(d$fecha)
x <- ts(d$valor, start = c(format(d$fecha[1], "%Y"), 1), frequency = 12)

m <- auto.arima(x)
f <- forecast(m, h = 12)

pred <- f$mean
last_date <- max(d$fecha)
next_dates <- seq(last_date, length.out = 13)[-1]

out <- data.frame(
  fecha     = format(next_dates, "%Y-%m-%d"),
  pronostico = round(pred, 2)
)

write.csv(out, "pronostico_r.csv", row.names = FALSE)

cat("Pronostico de 12 meses:\n")
print(out)
cat("\nModelo:\n")
print(m)
