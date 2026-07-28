library(ggplot2)
library(dplyr)

# Leer el archivo CSV
ventas <- read.csv("ventas.csv")

# Crear el dashboard de barras
p1 <- ggplot(ventas, aes(x = region, y = ventas)) +
  geom_col() +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas") +
  theme_minimal()

# Guardar la imagen de barras
ggsave("dashboard_r_barras.png", p1, width = 8, height = 5, dpi = 300)

# Crear el dashboard de línea
ventas_por_mes <- ventas %>%
  group_by(mes) %>%
  summarise(ventas = sum(ventas), .groups = 'drop')

p2 <- ggplot(ventas_por_mes, aes(x = mes, y = ventas)) +
  geom_line(aes(group = 1), size = 1) +
  geom_point(size = 2) +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas") +
  theme_minimal()

# Guardar la imagen de línea
ggsave("dashboard_r_linea.png", p2, width = 8, height = 5, dpi = 300)
