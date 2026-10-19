# Script R para generar dashboards de ventas

# Cargar librerías necesarias
library(ggplot2)

# Leer datos desde ventas.csv
datos <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Dashboard 1: Barras de ventas totales por region
dashboard_barras <- ggplot(datos, aes(x = region, y = ventas, fill = region)) +
  geom_bar(stat = "sum") +
  labs(title = "Ventas Totales por Region",
       x = "Region",
       y = "Ventas",
       fill = "Region") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12),
        legend.position = "bottom")

ggsave("dashboard_r_barras.png", plot = dashboard_barras, width = 8, height = 5, unit = "in")
cat("Dashboard de barras generado exitosamente.\n")

# Dashboard 2: Línea de ventas totales por mes (agrupa y suma por mes, mes como texto, group=1)
ventas_por_mes <- aggregate(ventas ~ mes, data = datos, FUN = sum)

dashboard_linea <- ggplot(ventas_por_mes, aes(x = as.character(mes), y = ventas, group = 1)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3, colour = "blue") +
  labs(title = "Ventas Totales por Mes",
       x = "Mes",
       y = "Ventas",
       caption = "Ventas agrupadas y sumadas por mes") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12))

ggsave("dashboard_r_linea.png", plot = dashboard_linea, width = 8, height = 5, unit = "in")
cat("Dashboard de línea generado exitosamente.\n")

cat("\nAmbos dashboards generados correctamente.\n")
