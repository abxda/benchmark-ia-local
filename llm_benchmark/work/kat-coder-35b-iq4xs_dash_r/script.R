library(ggplot2)

df <- read.csv("ventas.csv", stringsAsFactors = FALSE)

ventas_region <- aggregate(ventas ~ region, data = df, FUN = sum)
ventas_mes <- aggregate(ventas ~ mes, data = df, FUN = sum)
ventas_mes$mes <- factor(ventas_mes$mes, levels = ventas_mes$mes)

p1 <- ggplot(ventas_region, aes(x = region, y = ventas, fill = region)) +
  geom_bar(stat = "identity") +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas") +
  theme(legend.position = "none")

p2 <- ggplot(ventas_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line() +
  geom_point() +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas")

ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5)
ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5)
