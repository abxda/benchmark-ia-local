library(ggplot2)

datos <- read.csv("ventas.csv", stringsAsFactors = FALSE)

ventas_region <- aggregate(ventas ~ region, data = datos, FUN = sum)
ventas_mes <- aggregate(ventas ~ mes, data = datos, FUN = sum)

p1 <- ggplot(ventas_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity") +
  labs(title = "Ventas Totales por Región")

ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5, units = "in")

p2 <- ggplot(ventas_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line() +
  labs(title = "Ventas Totales por Mes")

ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5, units = "in")
