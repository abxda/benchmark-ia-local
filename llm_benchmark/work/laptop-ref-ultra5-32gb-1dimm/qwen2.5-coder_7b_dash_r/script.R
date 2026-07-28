library(ggplot2)

# Leer los datos
datos <- read.csv('ventas.csv')

# Calcular ventas totales por region
ventas_region <- aggregate(ventas ~ region, data = datos, sum)
ggplot(ventas_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Ventas Totales por Region", x = "Region", y = "Ventas")

# Calcular ventas totales por mes
datos$mes <- factor(datos$mes)
ventas_mes <- aggregate(ventas ~ mes, data = datos, sum)
ggplot(ventas_mes, aes(x = mes, y = ventas)) +
  geom_line(group = 1) +
  theme_minimal() +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas")

# Guardar las imágenes
ggsave("dashboard_r_barras.png", width = 8, height = 5)
ggsave("dashboard_r_linea.png", width = 8, height = 5)
