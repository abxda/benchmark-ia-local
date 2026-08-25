# Librerias
library(dplyr)
library(ggplot2)

# Leer datos de ventas
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Barras: ventas totales por region
barras <- ventas %>%
  group_by(region) %>%
  summarise(total = sum(ventas, na.rm = TRUE))

p_barras <- ggplot(barras, aes(x = region, y = total, fill = region)) +
  geom_col(width = 0.7) +
  coord_flip() +
  labs(title = "Ventas Totales por Region",
       x = "Region",
       y = "Ventas Totales") +
  theme_minimal()

ggsave("dashboard_r_barras.png", plot = p_barras, width = 8, height = 5, dpi = 300)

# Linea: ventas totales por mes (mes como texto, group=1)
linea <- ventas %>%
  group_by(mes) %>%
  summarise(total = sum(ventas, na.rm = TRUE))

p_linea <- ggplot(linea, aes(x = mes, y = total, group = 1)) +
  geom_line() +
  geom_point() +
  labs(title = "Ventas Totales por Mes",
       x = "Mes",
       y = "Ventas Totales") +
  theme_minimal()

ggsave("dashboard_r_linea.png", plot = p_linea, width = 8, height = 5, dpi = 300)
