library(ggplot2)

# Leer los datos
datos <- read.csv("ventas.csv")

# 1. Barras de ventas totales por region
ventas_region <- aggregate(ventas ~ region, data = datos, sum)

p1 <- ggplot(ventas_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity") +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas Totales")

ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5)

# 2. Linea de ventas totales por mes
# Agrupar y sumar por mes
ventas_mes <- aggregate(ventas ~ mes, data = datos, sum)

# Asegurar que el mes sea tratado como texto (ya lo es por la lectura, pero por si acaso)
ventas_mes$mes <- as.character(ventas_mes$mes)

p2 <- ggplot(ventas_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line() +
  geom_point() +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas Totales")

ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5)
