# Script para generar dashboards de ventas con ggplot2

# 1. Cargar librerías
library(ggplot2)
library(dplyr)

# 2. Leer el archivo CSV
tryCatch({
  # Leer el CSV asumiendo que las columnas son correctas, forzando stringsAsFactors=FALSE
  ventas_data <- read.csv("ventas.csv", stringsAsFactors = FALSE)
}, error = function(e) {
  stop(paste("Error al leer ventas.csv:", e$message))
})

# Asegurar que las columnas existen (para prevenir fallos en la lógica posterior)
if (!all(c("region", "mes", "ventas") %in% names(ventas_data))) {
  stop("ventas.csv debe contener las columnas: region, mes, ventas")
}

# --- Dashboard de Barras: Ventas totales por región ---
# 3. Procesar y generar el gráfico de barras
ventas_por_region <- ventas_data %>%
  group_by(region) %>%
  summarise(total_ventas = sum(ventas, na.rm = TRUE))

barras_plot <- ggplot(ventas_por_region, aes(x = region, y = total_ventas, fill = region)) +
  geom_bar(stat = "identity") +
  labs(title = "Ventas Totales por Región",
       x = "Región",
       y = "Ventas Totales") +
  theme_minimal() +
  theme(legend.position = "none")

# 4. Guardar el gráfico de barras
ggsave("dashboard_r_barras.png", plot = barras_plot, width = 8, height = 5)
print("Archivo 'dashboard_r_barras.png' generado.")

# --- Dashboard de Línea: Ventas totales por mes ---
# 5. Procesar y generar el gráfico de línea
# Orden de meses esperado para el eje X del gráfico de línea para asegurar orden cronológico.
meses_ordenados <- c("2025-01", "2025-02", "2025-03", "2025-04", "2025-05", "2025-06", "2025-07", "2025-08", "2025-09", "2025-10", "2025-11", "2025-12")

ventas_por_mes <- ventas_data %>%
  mutate(mes = factor(mes, levels = meses_ordenados)) %>% # Forzar ordenamiento de meses
  group_by(mes) %>%
  summarise(total_ventas = sum(ventas, na.rm = TRUE))

linea_plot <- ggplot(ventas_por_mes, aes(x = mes, y = total_ventas, group = 1)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Ventas Totales por Mes",
       x = "Mes",
       y = "Ventas Totales") +
  theme_minimal()

# 6. Guardar el gráfico de línea
ggsave("dashboard_r_linea.png", plot = linea_plot, width = 8, height = 5)
print("Archivo 'dashboard_r_linea.png' generado.")