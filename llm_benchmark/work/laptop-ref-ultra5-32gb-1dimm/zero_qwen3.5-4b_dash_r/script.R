# Script R para generar dashboard de ventas
# Lee ventas.csv y genera dos gráficos: barras por región y línea por mes

# Cargar librerías necesarias
library(ggplot2)
library(dplyr)

# Cargar datos
datos <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Ajustar nombres de columnas si es necesario
# Asumimos que las columnas son: region, mes, ventas
# Si los nombres son diferentes, ajustar aquí

# Verificar columnas
cat("Columnas disponibles:", names(datos), "\n")

# 1. Gráfico de barras: ventas totales por región
# Agrupar y sumar ventas por región
ventas_por_region <- aggregate(ventas ~ region, data = datos, FUN = sum, na.rm = TRUE)
names(ventas_por_region) <- c("region", "ventas_region")

# Crear gráfico de barras
p_barras <- ggplot(ventas_por_region, aes(x = region, y = ventas_region)) +
  geom_bar(stat = "identity", fill = "#4C72B5", color = "white") +
  labs(title = "Ventas Totales por Región",
       subtitle = "Gráfico de barras",
       x = "Región",
       y = "Ventas") +
  theme_minimal() +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14, face = "bold"),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5))

# Guardar gráfico de barras
ggsave("dashboard_r_barras.png", plot = p_barras, width = 8, height = 5, units = "in")
cat("Guardado: dashboard_r_barras.png\n")

# 2. Gráfico de líneas: ventas totales por mes
# Agrupar y sumar ventas por mes (tratando mes como texto)
ventas_por_mes <- aggregate(ventas ~ mes, data = datos, FUN = sum, na.rm = TRUE)
names(ventas_por_mes) <- c("mes", "ventas_mes")

# Ordenar por mes (asegurando orden correcto)
ventas_por_mes <- ventas_por_mes[order(ventas_por_mes$mes), ]

# Crear gráfico de líneas
p_linea <- ggplot(ventas_por_mes, aes(x = mes, y = ventas_mes)) +
  geom_line(group = 1, linewidth = 1.5) +
  geom_col(aes(y = ventas_mes), fill = "#DD8452", alpha = 0.3) +
  labs(title = "Ventas Totales por Mes",
       subtitle = "Gráfico de líneas (mes como texto)",
       x = "Mes",
       y = "Ventas") +
  theme_minimal() +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 14, face = "bold"),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5))

# Guardar gráfico de líneas
ggsave("dashboard_r_linea.png", plot = p_linea, width = 8, height = 5, units = "in")
cat("Guardado: dashboard_r_linea.png\n")

cat("\nÉxito: Ambos gráficos generados correctamente.\n")
