library(ggplot2)
library(dplyr)

# Leer los datos
df <- read.csv("ventas.csv")

# 1. Gráfico de barras: Ventas totales por región
df_region <- df %>%
  group_by(region) %>%
  summarise(ventas_totales = sum(ventas))

p1 <- ggplot(df_region, aes(x = region, y = ventas_totales, fill = region)) +
  geom_col() +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas") +
  theme_minimal()

ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5)

# 2. Gráfico de línea: Ventas totales por mes
df_mes <- df %>%
  group_by(mes) %>%
  summarise(ventas_totales = sum(ventas))

p2 <- ggplot(df_mes, aes(x = mes, y = ventas_totales, group = 1)) +
  geom_line(color = "blue", size = 1) +
  geom_point(color = "blue") +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas") +
  theme_minimal()

ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5)
