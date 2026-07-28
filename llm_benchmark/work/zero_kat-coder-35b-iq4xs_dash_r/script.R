# Cargar librería
library(ggplot2)

# Leer datos
v <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# ── Gráfico 1: barras de ventas totales por región ──
p1 <- ggplot(v, aes(x = region, y = ventas)) +
  geom_bar(stat = "summary", fun = "sum", fill = "steelblue") +
  labs(title = "Ventas totales por región",
       x = "Región",
       y = "Ventas") +
  theme_minimal()
ggsave("dashboard_r_barras.png", p1, width = 8, height = 5)

# ── Gráfico 2: línea de ventas totales por mes ──
m <- aggregate(ventas ~ mes, data = v, FUN = sum)
m$mes <- factor(m$mes, levels = m$mes)

p2 <- ggplot(m, aes(x = mes, y = ventas, group = 1)) +
  geom_line() +
  geom_point() +
  labs(title = "Ventas totales por mes",
       x = "Mes",
       y = "Ventas") +
  theme_minimal()
ggsave("dashboard_r_linea.png", p2, width = 8, height = 5)

cat("Listo: dashboard_r_barras.png  dashboard_r_linea.png\n")
