library(ggplot2)

# Leer datos
df <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# --- 1) Barras: ventas totales por región ---
ventas_region <- aggregate(ventas ~ region, data = df, FUN = sum)

p1 <- ggplot(ventas_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity", fill = "#2171b5", width = 0.7) +
  labs(title = "Ventas totales por región", x = NULL, y = "Ventas") +
  theme_minimal()

ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5)

# --- 2) Línea: ventas totales por mes ---
ventas_mes <- aggregate(ventas ~ mes, data = df, FUN = sum)

p2 <- ggplot(ventas_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line(color = "#e4572e", linewidth = 1) +
  geom_point(color = "#e4572e", size = 2) +
  labs(title = "Ventas totales por mes", x = NULL, y = "Ventas") +
  theme_minimal()

ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5)
