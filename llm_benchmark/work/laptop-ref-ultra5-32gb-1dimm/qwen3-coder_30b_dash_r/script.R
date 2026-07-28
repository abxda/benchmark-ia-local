library(ggplot2)
library(dplyr)

# Leer los datos
ventas <- read.csv("ventas.csv")

# Crear dashboard_r_barras.png
ventas_region <- ventas %>%
  group_by(region) %>%
  summarise(total_ventas = sum(ventas))

p1 <- ggplot(ventas_region, aes(x = region, y = total_ventas, fill = region)) +
  geom_col() +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas Totales") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("dashboard_r_barras.png", p1, width = 8, height = 5, dpi = 300)

# Crear dashboard_r_linea.png
ventas_mes <- ventas %>%
  group_by(mes) %>%
  summarise(total_ventas = sum(ventas))

p2 <- ggplot(ventas_mes, aes(x = mes, y = total_ventas)) +
  geom_line(aes(group = 1), size = 1) +
  geom_point(size = 2) +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas Totales") +
  theme_minimal()

ggsave("dashboard_r_linea.png", p2, width = 8, height = 5, dpi = 300)
