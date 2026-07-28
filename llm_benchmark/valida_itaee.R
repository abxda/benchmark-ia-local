# Validacion estadistica del ajuste estacional producido por el agente.
d <- "D:/TallerIA_Agente/trabajo/itaee_final"
df <- read.csv(file.path(d, "itaee_hidalgo_ajustada.csv"))

o <- ts(df$original, frequency = 4, start = c(1980, 1))
a <- ts(df$desestacionalizada, frequency = 4, start = c(1980, 1))

cat("observaciones:", nrow(df), "\n")
cat("rango:", min(df$anio), "T", df$trimestre[1], "a", max(df$anio), "T",
    df$trimestre[nrow(df)], "\n")
cat("media original :", round(mean(o), 3), "\n")
cat("media ajustada :", round(mean(a), 3), "\n")
cat("correlacion    :", round(cor(o, a), 4), "\n\n")

# Prueba de estacionalidad remanente: F de un ANOVA por trimestre sobre la
# serie diferenciada (para quitar la tendencia). Si el ajuste sirvio, la
# estacionalidad debe ser fuerte en la original y desaparecer en la ajustada.
prueba <- function(x, etiqueta) {
  dx <- diff(x)
  f <- summary(aov(as.numeric(dx) ~ factor(cycle(dx))))[[1]]
  cat(sprintf("%-10s F = %7.2f   p = %s\n", etiqueta,
              f[1, 4], format.pval(f[1, 5], digits = 3)))
}
prueba(o, "original")
prueba(a, "ajustada")
