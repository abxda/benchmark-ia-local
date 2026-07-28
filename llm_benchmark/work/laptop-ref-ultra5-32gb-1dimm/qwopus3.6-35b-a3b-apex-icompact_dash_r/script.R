library(ggplot2)

ventas <- read.csv("ventas.csv")

ventas$region <- as.factor(ventas$region)
ventas$mes <- as.factor(ventas$mes)

ventas_region <- aggregate(ventas ~ region, data = ventas, FUN = sum)
ventas_mes <- aggregate(ventas ~ mes, data = ventas, FUN = sum)

p1 <- ggplot(ventas_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas") +
  theme_minimal()

ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5)

p2 <- ggplot(ventas_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line(color = "red", size = 1) +
  geom_point(color = "red", size = 3) +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas") +
  theme_minimal()

ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5)
