# Script R para generar dashboards a partir de ventas.csv

# Cargar librerías
library(ggplot2)

# Leer el archivo CSV
datos <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Ver estructura de los datos
print("Estructura de datos:")
print(str(datos))

# Calcular ventas totales por region
ventas_por_region <- aggregate(ventas ~ region, data = datos, sum)

# Calcular ventas totales por mes (agrupar y sumar, tratando mes como texto)
ventas_por_mes <- aggregate(ventas ~ mes, data = datos, sum)
# Asegurar que mes se trata como texto (factor)
ventas_por_mes$mes <- as.character(ventas_por_mes$mes)

# Crear gráfico de barras: ventas totales por region
p_barras <- ggplot(ventas_por_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Ventas Totales por Región",
       x = "Región",
       y = "Ventas Totales") +
  theme_minimal()

# Crear gráfico de línea: ventas totales por mes
p_linea <- ggplot(ventas_por_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line(color = "darkred", linewidth = 1) +
  geom_point(color = "darkred", size = 3) +
  labs(title = "Ventas Totales por Mes",
       x = "Mes",
       y = "Ventas Totales") +
  theme_minimal()

# Guardar gráficos con ggsave
ggsave("dashboard_r_barras.png", plot = p_barras, width = 8, height = 5, units = "in")
ggsave("dashboard_r_linea.png", plot = p_linea, width = 8, height = 5, units = "in")

print("Script completado. Archivos PNG generados:")
print("  - dashboard_r_barras.png")
print("  - dashboard_r_linea.png")