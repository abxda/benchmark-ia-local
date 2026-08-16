# Dashboard de ventas: barra por region y linea por mes

library(ggplot2)

ventas <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Ventas totales por region (barras)
por_region <- aggregate(ventas ~ region, data = ventas, FUN = sum)
names(por_region)[2] <- "ventas_totales"

ggplot(por_region, aes(x = region, y = ventas_totales)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Ventas totales por region", x = "Region", y = "Ventas") +
  theme_minimal()
ggsave("dashboard_r_barras.png", width = 8, height = 5)

# Ventas totales por mes (linea)
por_mes <- aggregate(ventas ~ mes, data = ventas, FUN = sum)
names(por_mes)[2] <- "ventas_totales"

ggplot(por_mes, aes(x = mes, y = ventas_totales, group = 1)) +
  geom_line(color = "darkorange") +
  geom_point(color = "darkorange", size = 2) +
  labs(title = "Ventas totales por mes", x = "Mes", y = "Ventas") +
  theme_minimal()
ggsave("dashboard_r_linea.png", width = 8, height = 5)
