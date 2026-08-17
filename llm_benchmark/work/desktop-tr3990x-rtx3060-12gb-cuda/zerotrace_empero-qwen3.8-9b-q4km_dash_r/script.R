# Script R: Dashboard de ventas con ggplot2
# Lee ventas.csv y genera dos gráficos PNG

library(ggplot2)

# --- Gráfico 1: Barras de ventas totales por región ---
ventas <- read.csv("ventas.csv")

p_barras <- ggplot(ventas, aes(x = region, y = ventas, fill = region)) +
  geom_bar(stat = "identity", width = 0.7, alpha = 0.9) +
  scale_fill_manual(values = c("Norte" = "#E69F00", "Sur" = "#56B4E9",
                                "Centro" = "#009E73", "Oriente" = "#F0E442",
                                "Occidente" = "#CC79A7")) +
  labs(title = "Ventas Totales por Región",
       x = "Región",
       y = "Ventas ($)",
       fill = "Región") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.text.x = element_text(angle = 0, hjust = 0.5),
        legend.position = "none",
        panel.grid = element_blank(),
        axis.text.y = element_text(angle = 0))

ggsave("dashboard_r_barras.png", plot = p_barras, width = 8, height = 5, dpi = 300)
cat("✓ Guardado: dashboard_r_barras.png\n")

# --- Gráfico 2: Línea de ventas totales por mes ---
# Se trata el mes como texto y se usa group = 1 para una sola línea
p_linea <- ggplot(ventas, aes(x = mes, y = ventas, group = 1)) +
  geom_line(color = "#2166AC", linewidth = 1.2, alpha = 0.8) +
  geom_point(color = "#FDB462", size = 3, alpha = 0.8) +
  scale_x_discrete(name = "Mes", labels = c(
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
  )) +
  labs(title = "Ventas Totales por Mes",
       x = "Mes",
       y = "Ventas ($)") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        axis.text.x = element_text(angle = 0, hjust = 0.5))

ggsave("dashboard_r_linea.png", plot = p_linea, width = 8, height = 5, dpi = 300)
cat("✓ Guardado: dashboard_r_linea.png\n")

cat("\nAmbos gráficos generados exitosamente.\n")
