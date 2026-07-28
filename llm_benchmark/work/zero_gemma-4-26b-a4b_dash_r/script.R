library(ggplot2)

# Leer los datos
datos <- read.csv("ventas.csv")

# 1. Gráfico de barras de ventas totales por región
ventas_region <- aggregate(ventas ~ region, data = datos, sum)

p1 <- ggplot(ventas_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas Totales") +
  theme_minimal()

ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5)

# 2. Gráfico de línea de ventas totales por mes
# Agrupar y sumar por mes
ventas_mes <- aggregate(ventas ~ mes, data = datos, sum)

p2 <- ggplot(ventas_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line(color = "red", linewidth = 1) +
  geom_point() +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas Totales") +
  theme_minimal()

ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5)
