# Cargar la librería ggplot2
library(ggplot2)

# Leer el archivo CSV
df <- read.csv("ventas.csv")

# Convertir la columna mes a tipo de dato caracter para mantener el formato
df$mes <- as.character(df$mes)

# Crear el dashboard_r_barras.png con barras de ventas totales por region
p1 <- ggplot(df, aes(x = region, y = ventas, fill = region)) +
  geom_col() +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("dashboard_r_barras.png", p1, width = 8, height = 5, dpi = 300)

# Agrupar y sumar por mes (tratando mes como texto)
ventas_por_mes <- aggregate(ventas ~ mes, data = df, sum)

# Crear el dashboard_r_linea.png con línea de ventas totales por mes
p2 <- ggplot(ventas_por_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line() +
  geom_point() +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("dashboard_r_linea.png", p2, width = 8, height = 5, dpi = 300)