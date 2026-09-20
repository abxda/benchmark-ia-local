# Script R para generar dashboard
library(ggplot2)

# Leer ventas.csv
ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Mostrar datos leídos
print("Datos leídos:")
print(ventas)

# 1. Barras de ventas totales por region
# Suma ventas por region
ventas_por_region <- aggregate(ventas ~ region, data = ventas, sum)
print("Ventas por region (suma):")
print(ventas_por_region)

# Gráfico de barras
p_barras <- ggplot(ventas_por_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity", width = 0.6, fill = "steelblue") +
  labs(title = "Ventas totales por región",
       x = "Región",
       y = "Ventas (total)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Guardar como dashboard_r_barras.png
ggsave("dashboard_r_barras.png", plot = p_barras, width = 8, height = 5, units = "in")
print("archivo dashboard_r_barras.png guardado")

# 2. Línea de ventas totales por mes
# Agrupar ventas por mes (tratar mes como texto, sumar ventas)
ventas_por_mes <- aggregate(ventas ~ mes, data = ventas, sum)
print("Ventas por mes (suma):")
print(ventas_por_mes)

# Gráfico de línea
# Usar group=1 para línea (mes como texto)
p_linea <- ggplot(ventas_por_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line(color = "darkred", size = 1) +
  geom_point(color = "darkred", size = 2) +
  labs(title = "Ventas totales por mes",
       x = "Mes (texto)",
       y = "Ventas (total)") +
  theme_minimal()

# Guardar como dashboard_r_linea.png
ggsave("dashboard_r_linea.png", plot = p_linea, width = 8, height = 5, units = "in")
print("archivo dashboard_r_linea.png guardado")

print("Script completado exitosamente")