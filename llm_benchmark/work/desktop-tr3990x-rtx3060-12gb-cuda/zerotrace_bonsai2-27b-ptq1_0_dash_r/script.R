# Dashboard de ventas - R + ggplot2
# Lee ventas.csv (region, mes, ventas) y genera dos imágenes PNG.

library(ggplot2)

# Cargar datos; mes se lee como texto (character)
df <- read.csv("ventas.csv", stringsAsFactors = FALSE)
df$mes <- as.character(df$mes)

# Gráfico 1: barras de ventas totales por región
plot_barras <- ggplot(df, aes(x = region, y = ventas, fill = region)) +
  geom_bar(stat = "sum", width = 0.8) +
  theme_minimal(base_size = 12) +
  labs(title = "Ventas totales por región", x = "Región", y = "Ventas totales") +
  scale_fill_manual(values = c("Norte" = "#4C72B0", "Sur" = "#DD8452",
                               "Centro" = "#55A868", "Oriente" = "#94794D",
                               "Occidente" = "#E64B35")) +
  theme(legend.position = "none")

ggsave("dashboard_r_barras.png", plot = plot_barras, width = 8, height = 5, dpi = 150)

# Gráfico 2: línea de ventas totales por mes (mes como texto, group=1)
plot_linea <- ggplot(df, aes(x = mes, y = ventas, group = 1)) +
  geom_line(color = "#2C7FB8", linewidth = 0.9) +
  geom_point(size = 2) +
  theme_minimal(base_size = 12) +
  labs(title = "Ventas totales por mes", x = "Mes", y = "Ventas totales") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")

ggsave("dashboard_r_linea.png", plot = plot_linea, width = 8, height = 5, dpi = 150)

cat("Imágenes generadas con éxito.\n")
