# ==========================================
# Script para generar un pronóstico de 12 meses
# ==========================================

# Configuración
DATA_FILE="serie_mensual.csv"
OUTPUT_FILE="pronostico_r.csv"

# Verificar que el archivo de datos exista
if (!file.exists(DATA_FILE)) {
  cat("Error: El archivo de datos no se pudo leer. \n", paste(c("Necesito el archivo:", DATA_FILE)))
  quit()
}

# Crear script R con los comandos necesarios
script <- function() {
  # Leer el archivo de datos
  cat("1. Leer serie de datos (fecha, valor)\n", sep="")
  
  # Leer los datos (aproximadamente 72 filas para 72 meses)
  series <- read.csv(DATA_FILE, stringsAsFactors = FALSE)
  cat(sprintf("   %d filas\n", nrow(series)))
  
  # Seleccionar columnas: fecha (meses en YYYY-MM-DD) y valor
  values <- series[, c("fecha", "valor")]
  dates <- as.Date(values$fecha)
  
  # Guardar datos temporales
  data_temp <- data.frame(
    fecha = dates,
    valor = values$valor
  )
  
  # Ajustar frecuencia a 12 (meses)
  data_temp$frecuencia <- 12
  data_temp$periodo <- data_temp$frecuencia * 12
  data_temp$fecha <- as.Date(data_temp$fecha)
  
  # Verificar que todas las fechas tengan la frecuencia deseada
  required_freq <- c("12")
  for (df in seq_along(data_temp)) {
    if (data_temp$fecha %in% seq(df, by = "12") & data_temp$frecuencia != seq(df, by = "12")) {
      cat(sprintf("   Error en fila %d: fecha no tiene frecuencia %s\n", df, required_freq))
      quit()
    }
  }
  
  cat("2. Convertir serie a ts con frequency=12\n", sep="")
  
  # Convolución de series para generar series temporales
  series_ts <- ts(
    values,
    freq = 12,
    center = 12
  )
  
  # Seleccionar un rango de 12 meses
  start_date <- as.Date(data_temp$fecha[-1])
  end_date <- as.Date(data_temp$fecha[-1 + 11])
  
  # Ajustar el rango temporal
  end_ts <- as.numeric(end_date)
  end_ts <- end_ts + (12 - 1) * data_temp$frecuencia * 365
  start_ts <- as.numeric(start_date)
  start_ts <- start_ts - 12 * data_temp$frecuencia * 365
  
  # Crear ts temporal
  ts_temp <- ts(
    start_ts,
    end_ts,
    freq = 12
  )
  
  # Seleccionar un rango temporal de 12 meses para el pronóstico
  end_ts <- as.numeric(end_date)
  end_ts <- end_ts + (12 - 1) * data_temp$frecuencia * 365
  start_ts <- as.numeric(start_date)
  start_ts <- start_ts - 12 * data_temp$frecuencia * 365
  
  # Crear ts temporal para pronóstico
  ts_pronostico <- ts(
    start_ts,
    end_ts,
    freq = 12
  )
  
  # Verificar rango temporal para pronóstico
  end_ts_pronost <- as.numeric(end_date)
  end_ts_pronost <- end_ts_pronost + (12 - 1) * data_temp$frecuencia * 365
  start_ts_pronost <- as.numeric(start_date)
  start_ts_pronost <- start_ts_pronost - 12 * data_temp$frecuencia * 365
  
  cat("3. Generar pronóstico con auto.arima\n", sep="")
  
  # Modelos de ARIMA auto
  # Modelo 1: ARIMA(0,1,1) - tendencia + estacionalidad
  pred1 <- forecast(ts_pronostico, 
                    model = "auto.arima(0,1,1)", 
                    frequency = 12,
                    center = 12,
                    na.rm = TRUE,
                    center = 12)
  
  # Modelo 2: ARIMA(1,0,1) - tendencia + estacionalidad
  pred2 <- forecast(ts_pronostico, 
                    model = "auto.arima(1,0,1)", 
                    frequency = 12,
                    center = 12,
                    na.rm = TRUE,
                    center = 12)
  
  # Modelos 3: ARIMA(0,2,1) - tendencia + estacionalidad (más fuerte de estacionalidad)
  pred3 <- forecast(ts_pronostico, 
                    model = "auto.arima(0,2,1)", 
                    frequency = 12,
                    center = 12,
                    na.rm = TRUE,
                    center = 12)
  
  # Modelos 4: MA(2,1) - estacionalidad + tendencia
  pred4 <- forecast(ts_pronostico, 
                    model = "auto.arima(0,0,1)", 
                    frequency = 12,
                    center = 12,
                    na.rm = TRUE,
                    center = 12)
  
  # Modelos 5: MA(1,1) - estacionalidad + tendencia
  pred5 <- forecast(ts_pronostico, 
                    model = "auto.arima(0,0,1)", 
                    frequency = 12,
                    center = 12,
                    na.rm = TRUE,
                    center = 12)
  
  # Verificar los resultados
  cat("4. Resultados del modelo de pronóstico\n", sep="")
  
  # Mostrar los predicciones
  pred_df <- data.frame(
    fecha = as.character(ts_pronostico[1, "fecha"]),
    puntado = seq_along(pred1$forecast)
  )
  
  # Obtener las promedias puntuales
  pred_df$puntado <- as.numeric(pred_df$puntado)
  
  # Seleccionar los resultados
  resultados <- c(pred_df[1:12, ])
  
  # Guardar los resultados
  write.csv(results, output_file, row.names = FALSE, quote = FALSE)
  
  cat(sprintf("\n✅ Script completado. Archivo %s creado correctamente.\n", output_file))
  
  # Mostrar el primer resultado
  cat("Primer resultado (fecha: " , paste(results[1, "fecha"], ") puntado: " , paste(results[1, "puntado"], ")\n")
  cat("   ", paste(results[1, "fecha"], "\n", sep=""))
  cat("   ", paste(results[1, "puntado"], "\n", sep=""))
}()

# Ejecutar el script
script()
