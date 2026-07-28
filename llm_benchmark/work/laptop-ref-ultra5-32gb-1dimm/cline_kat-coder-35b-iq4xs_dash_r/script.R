# Script R: Dashboard de ventas
# Lee ventas.csv y genera dos gráficos PNG con ggplot2

# Cargar librería
library(ggplot2)

# Leer datos
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# ============================================================
# Gráfico 1: Barras de ventas totales por región
# ============================================================
ventas_por_region <- aggregate(ventas ~ region, data = ventas, FUN = sum)

p1 <- ggplot(ventas_por_region, aes(x = region, y = ventas, fill = region)) +
  geom_bar(stat = "identity") +
  labs(title = "Ventas totales por región",
       x = "Región",
       y = "Ventas") +
  theme(legend.position = "none")

ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5, dpi = 150)

# ============================================================
# Gráfico 2: Línea de ventas totales por mes
# ============================================================
ventas_por_mes <- aggregate(ventas ~ mes, data = ventas, FUN = sum)

p2 <- ggplot(ventas_por_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line() +
  geom_point() +
  labs(title = "Ventas totales por mes",
       x = "Mes",
       y = "Ventas")

ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5, dpi = 150)

cat("Scripts ejecutados correctamente.\n")
cat("Se generaron: dashboard_r_barras.png y dashboard_r_linea.png\n")
