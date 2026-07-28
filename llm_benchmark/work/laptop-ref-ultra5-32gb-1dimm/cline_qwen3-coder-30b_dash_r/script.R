# Cargar librerías necesarias
library(ggplot2)

# Verificar que el archivo existe
if (!file.exists("ventas.csv")) {
  stop("El archivo ventas.csv no existe en el directorio actual")
}

# Leer el archivo CSV
ventas <- read.csv("ventas.csv")

# Convertir la columna mes a factor para tratarlo como texto
ventas$mes <- as.factor(ventas$mes)

# Calcular ventas totales por región para el gráfico de barras
ventas_region <- aggregate(ventas$ventas, by = list(Region = ventas$region), FUN = sum)
colnames(ventas_region) <- c("region", "ventas")

# Crear gráfico de barras por región
p1 <- ggplot(ventas_region, aes(x = region, y = ventas)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Ventas Totales por Región", x = "Región", y = "Ventas Totales") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Guardar el gráfico de barras como PNG
ggsave("dashboard_r_barras.png", plot = p1, width = 8, height = 5, unit = "in", dpi = 300)

# Agrupar y sumar ventas por mes (tratando mes como texto)
ventas_mes <- aggregate(ventas$ventas, by = list(Mes = ventas$mes), FUN = sum)
colnames(ventas_mes) <- c("mes", "ventas")

# Crear gráfico de línea por mes
p2 <- ggplot(ventas_mes, aes(x = mes, y = ventas, group = 1)) +
  geom_line(color = "red", size = 1) +
  geom_point(color = "red", size = 2) +
  labs(title = "Ventas Totales por Mes", x = "Mes", y = "Ventas Totales") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Guardar el gráfico de línea como PNG
ggsave("dashboard_r_linea.png", plot = p2, width = 8, height = 5, unit = "in", dpi = 300)

print("Gráficos generados exitosamente.")
print("Archivos generados:")
print(list.files(pattern = "\\.png$"))