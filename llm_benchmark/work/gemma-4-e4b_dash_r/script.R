library(ggplot2)
library(readr)

# Leer el archivo CSV
ventas <- read_csv("ventas.csv")

# 1. Gráfico de barras: Ventas totales por región
plot_barras <- ggplot(ventas, aes(x = region, y = sum(ventas))) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Ventas Totales por Región",
       x = "Región",
       y = "Ventas Totales") +
  theme_minimal()

# Guardar el gráfico de barras
ggsave("dashboard_r_barras.png", plot = plot_barras, width = 8, height = 5)

# 2. Gráfico de línea: Ventas totales por mes
# Agrupar y sumar por mes
ventas_mensuales <- aggregate(ventas ~ mes, data = ventas, FUN = sum)

plot_linea <- ggplot(ventas_mensuales, aes(x = mes, y = ventas)) +
  geom_line(group = 1) + # Usar group=1 para forzar una sola línea a través de todos los meses
  geom_point(color = "red") +
  labs(title = "Ventas Totales por Mes",
       x = "Mes",
       y = "Ventas Totales") +
  theme_minimal()

# Guardar el gráfico de línea
ggsave("dashboard_r_linea.png", plot = plot_linea, width = 8, height = 5)
