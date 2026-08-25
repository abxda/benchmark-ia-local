# Script to generate the R report from ventas.csv

# Read the CSV file
df <- read.csv("ventas.csv", stringsAsFactors = FALSE)

# Aggregate by mes to get total sales (mes is the column with date values)
df$total_ventas <- sapply(df$mes, function(mes) {
  sum(df$ventas[regions == mes])
})

# Create a new column with only the required data
df[,"Resumen"] <- cbind(df$mes, df$total_ventas)

# Write to Excel file
write.table(df[,"Resumen"], file = "report_r.xlsx", row.names = FALSE, quote = FALSE)
