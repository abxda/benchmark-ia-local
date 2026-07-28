# Verificación de datos
ventas <- read.csv("ventas.csv")
print("Ventas por región:")
print(aggregate(ventas$ventas ~ ventas$region, FUN=sum))