# Load necessary libraries
library(ggplot2)

# 1. Read the data
data <- read.csv('ventas.csv')

# Ensure 'mes' is treated as a factor for correct categorical plotting
data$mes <- as.factor(data$mes)

# --- Plot 1: Bar chart of total sales by region ---
p1 <- ggplot(data, aes(x = region, y = sum(ventas))) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Ventas Totales por Región",
       x = "Región",
       y = "Ventas") +
  theme_minimal()

# Save Plot 1: width=8, height=5
ggsave('dashboard_r_barras.png', plot = p1, width = 8, height = 5)

# --- Plot 2: Line plot of total sales by month ---
p2 <- ggplot(data, aes(x = mes, y = sum(ventas), group = 1)) +
  geom_line(color = "darkred", linewidth = 1) +
  geom_point(color = "darkred") +
  labs(title = "Ventas Totales por Mes",
       x = "Mes",
       y = "Ventas") +
  theme_minimal()

# Save Plot 2: width=8, height=5
ggsave('dashboard_r_linea.png', plot = p2, width = 8, height = 5)

print("Scripts ejecutados exitosamente. Se han generado dashboard_r_barras.png y dashboard_r_linea.png.")