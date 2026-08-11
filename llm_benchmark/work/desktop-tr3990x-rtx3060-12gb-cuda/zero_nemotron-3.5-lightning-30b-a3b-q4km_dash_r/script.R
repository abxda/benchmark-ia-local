# Script R para leer ventas.csv y generar dashboards con ggplot2

# Cargar librerías
library(ggplot2)

# Leer el CSV
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Ver estructura de los datos
print("Estructura de datos:")
print(str(ventas))

# Calcular ventas totales por region
ventas_por_region <- aggregate(ventas ~ region, data = ventas, sum)

# Calcular ventas totales por mes (agrupar y sumar; mes como texto)
ventas_por_mes <- aggregate(ventas ~ mes, data = ventas, sum)

# Gráfico 1: Barras de ventas totales por region
p1 <- ggplot(ventas_por_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Ventas Totales por Región",
       x = "Región",
       y = "Ventas Totales") +
  theme_minimal()

# Gráfico 2: Línea de ventas totales por mes (mes como texto, group=1)
p2 <- ggplot(ventas_por_mes, aes(x = mes, y = ventas)) +
  geom_line(color = "red", size = 1, aes(group = 1)) +
  geom_point(color = "red", size = 3) +
  labs(title = "Ventas Totales por Mes",
       x = "Mes",
       y = "Ventas Totales") +
  theme_minimal()

# Guardar gráficos con ggsave
ggsave("dashboard_r_barras.png", p1, width = 8, height = 5, units = "in")
ggsave("dashboard_r_linea.png", p2, width = 8, height = 5, units = "in")

print("Script completado. Archivos guardados: dashboard_r_barras.png, dashboard_r_linea.png")