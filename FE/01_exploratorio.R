library(tidyverse)
library(patchwork)
library(readr)
###### Propinas

setwd("/Users/dianalauratrevinorivera/Documents/ITAM/Fundamentos  Estadisticos/Tarea 1 Análisis Exploratorio 2")
tips  <- readr::read_csv("tips.csv",  show_col_types = FALSE)
casas <- readr::read_csv("casas.csv", show_col_types = FALSE)
dir.create("outputs", showWarnings = FALSE)

## Lee los datos
glimpse(tips)

## Recodificar nombres y niveles
propinas <- tips |> 
  rename(cuenta_total = total_bill, 
         propina = tip, sexo = sex, 
         fumador = smoker,
         dia = day, momento = time, 
         num_personas = size) |> 
  mutate(sexo = recode(sexo, Female = "Mujer", Male = "Hombre"), 
         fumador = recode(fumador, No = "No", Yes = "Si"),
         dia = recode(dia, Sun = "Dom", Sat = "Sab", Thur = "Jue", Fri = "Vie"),
         momento = recode(momento, Dinner = "Cena", Lunch = "Comida")) |> 
  select(-sexo) |> 
  mutate(dia  = fct_relevel(dia, c("Jue", "Vie", "Sab", "Dom")))
print(propinas |> slice_head(n = 10))



## 1. Calcula percentiles de la variable propina
## junto con mínimo y máxmo
print(quantile(propinas$propina, probs = seq(0, 1, 0.05), na.rm = TRUE))
  
## 2. Haz una gráfica de cuantiles de la variable propina
propinas <- propinas |> 
  mutate(orden_propina = rank(propina, ties.method = "first"), 
         f = orden_propina / n()) 
## aquí tu código
p_ecdf <- ggplot(propinas, aes(x = f, y = propina)) +
  geom_line()
print(p_ecdf)
ggsave("outputs/propina_cuantiles.png", p_ecdf, width = 7, height = 4, dpi = 150)

## 3. Haz un histograma de la variable propinas
## Ajusta distintos anchos de banda (usa bins o binwidth en ggplot)

#ejemplo con cuenta total
p_hist_ct_20 <- ggplot(propinas, aes(x = cuenta_total)) +
  geom_histogram(bins = 20)
print(p_hist_ct_20)
ggsave("outputs/hist_cuenta_total_bins20.png", p_hist_ct_20, width = 7, height = 4, dpi = 150)

p_hist_ct_40 <- ggplot(propinas, aes(x = cuenta_total)) +
  geom_histogram(bins = 40)
print(p_hist_ct_40)
ggsave("outputs/hist_cuenta_total_bins40.png", p_hist_ct_40, width = 7, height = 4, dpi = 150)


## 4. Haz una gráfica de cuenta total contra propina
## ggplot
p_scatter <- ggplot(propinas, aes(x = cuenta_total, y = propina)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE)
print(p_scatter)
ggsave("outputs/scatter_cuenta_vs_propina.png", p_scatter, width = 7, height = 4, dpi = 150)


## 5. Calcula propina en porcentaje de la cuenta total
## calcula algunos cuantiles de propina en porcentaje
propinas <- propinas |> 
  mutate(pct_propina = 100 * propina / cuenta_total)
           
print(quantile(propinas$pct_propina, probs = seq(0, 1, 0.1), na.rm = TRUE))
  
  
## 6. Haz un histograma de la propina en porcentaje. Prueba con
##  distintos anchos de banda. 
p_hist_pct <- ggplot(propinas, aes(x = pct_propina)) +
  geom_histogram(binwidth = 1)
print(p_hist_pct)
ggsave("outputs/hist_pct_propina.png", p_hist_pct, width = 7, height = 4, dpi = 150)

## 7. Describe la distribución de propina en pct. ¿Hay datos atípicos?
##8. Filtra los casos con porcentaje de propina muy altos. 
## ¿Qué tipos de cuentas son? ¿Son cuentas grandes o chicas?
umbral_alto <- with(propinas, quantile(pct_propina, 0.75, na.rm = TRUE) + 1.5 * IQR(pct_propina, na.rm = TRUE))
propinas_altas <- propinas |> filter(pct_propina > umbral_alto)
print(propinas_altas |> select(cuenta_total, propina, pct_propina, num_personas) |> arrange(desc(pct_propina)) |> head(10))

## 9. Haz una diagrama de caja y brazos para 
## propina en dolares dependiendo del momento (comida o cena)
## ¿Cuál parece más grande? ¿Por qué? Haz otras gráficas si es necesario.
p_box <- ggplot(propinas, aes(x = momento, y = propina)) +
  geom_boxplot()
print(p_box)
ggsave("outputs/box_propina_por_momento.png", p_box, width = 6, height = 4, dpi = 150)



####### Casas
glimpse(casas)

# 1. Condición y calidad general vs precio x m2
# haz una tabla de conteos de los valores
# de calidad general de construcción y terminados (calidad_gral)

# tip: usa la función summarise
print(casas |> 
  group_by(calidad_gral) |> 
  summarise(n = n(), .groups = "drop"))
    
# Haz una gráfica de caja y brazos del precio x m2 para cada 
# nivel de calidad gral ¿Qué interpretas?
    
# aquí tu codigo (tip: usa factor(variable) para convertir una variable
# numérica a factor)
ggplot(casas, aes(x = calidad_gral, y = precio_m2, group = calidad_gral)) +
  geom_boxplot()

ggplot(casas, aes(x = factor(calidad_gral), y = precio_m2)) +
  geom_boxplot() 




# 2. Repite el anterior con número de coches que caben en el garage.
#¿Cuál es la relación? ¿Qué puedes malinterpretar de esta gráfica?

print("=== ANÁLISIS POR NÚMERO DE COCHES EN GARAGE ===")

# Tabla de conteos de número de coches
print(casas |> 
  group_by(num_coches) |> 
  summarise(n = n(), .groups = "drop"))

# Boxplot de precio por m2 según número de coches
p_box_coches <- ggplot(casas, aes(x = factor(num_coches), y = precio_m2)) +
  geom_boxplot() +
  labs(x = "Número de coches en garage", y = "Precio por m²", 
       title = "Precio por m² según capacidad del garage")
print(p_box_coches)
ggsave("outputs/box_precio_por_num_coches.png", p_box_coches, width = 8, height = 5, dpi = 150)

# Estadísticas por grupo
print(casas |> 
  group_by(num_coches) |> 
  summarise(
    n = n(),
    precio_medio = mean(precio_m2, na.rm = TRUE),
    precio_mediana = median(precio_m2, na.rm = TRUE),
    precio_sd = sd(precio_m2, na.rm = TRUE),
    .groups = "drop"
  ))

print("=== INTERPRETACIÓN ===")
print("1. Relación: A mayor número de coches en garage, mayor precio por m²")
print("2. Posible malinterpretación: No necesariamente más coches = mejor casa")
print("   - Casas con 0 coches pueden ser muy caras (sin garage pero lujosas)")
print("   - Casas con 4 coches son muy pocas (solo 4 casos) - muestra pequeña")
print("   - El garage puede ser indicador de tamaño total de la casa")

print("=== ANÁLISIS DE LA VARIABLE PRECIO_M2 ===")

# 1. Calcula percentiles de la variable precio_m2
print("Percentiles de precio_m2:")
print(quantile(casas$precio_m2, probs = seq(0, 1, 0.05), na.rm = TRUE))

# 2. Gráfica de cuantiles de la variable precio_m2
casas_cuantiles <- casas |> 
  mutate(orden_precio = rank(precio_m2, ties.method = "first"), 
         f = orden_precio / n()) 

p_cuantiles_precio <- ggplot(casas_cuantiles, aes(x = f, y = precio_m2)) +
  geom_line(color = "blue", linewidth = 1) +
  labs(title = "Gráfica de cuantiles: Precio por m²", 
       x = "Proporción acumulada", y = "Precio por m²") +
  theme_minimal()
print(p_cuantiles_precio)
ggsave("outputs/cuantiles_precio_m2.png", p_cuantiles_precio, width = 8, height = 5, dpi = 150)

# 3. Histograma de precio_m2
p_hist_precio <- ggplot(casas, aes(x = precio_m2)) +
  geom_histogram(bins = 30, fill = "lightblue", alpha = 0.7, color = "black") +
  labs(title = "Distribución del precio por m²", 
       x = "Precio por m²", y = "Frecuencia") +
  theme_minimal()
print(p_hist_precio)
ggsave("outputs/histograma_precio_m2.png", p_hist_precio, width = 8, height = 5, dpi = 150)

# Histograma con diferentes bins
p_hist_precio_50 <- ggplot(casas, aes(x = precio_m2)) +
  geom_histogram(bins = 50, fill = "lightgreen", alpha = 0.7, color = "black") +
  labs(title = "Distribución del precio por m² (50 bins)", 
       x = "Precio por m²", y = "Frecuencia") +
  theme_minimal()
print(p_hist_precio_50)
ggsave("outputs/histograma_precio_m2_50bins.png", p_hist_precio_50, width = 8, height = 5, dpi = 150)

# 4. Diagrama de caja y brazos de precio_m2
p_box_precio <- ggplot(casas, aes(y = precio_m2)) +
  geom_boxplot(fill = "lightcoral", alpha = 0.7, color = "darkred") +
  labs(title = "Diagrama de caja: Precio por m²", 
       y = "Precio por m²") +
  theme_minimal() +
  theme(axis.text.x = element_blank())
print(p_box_precio)
ggsave("outputs/boxplot_precio_m2.png", p_box_precio, width = 6, height = 5, dpi = 150)

# Estadísticas descriptivas
print("Estadísticas descriptivas de precio_m2:")
print(summary(casas$precio_m2))

# Detección de outliers
Q1_precio <- quantile(casas$precio_m2, 0.25, na.rm = TRUE)
Q3_precio <- quantile(casas$precio_m2, 0.75, na.rm = TRUE)
IQR_precio <- Q3_precio - Q1_precio
lower_bound_precio <- Q1_precio - 1.5 * IQR_precio
upper_bound_precio <- Q3_precio + 1.5 * IQR_precio

outliers_precio <- casas |> filter(precio_m2 < lower_bound_precio | precio_m2 > upper_bound_precio)
print(paste("Número de outliers en precio_m2:", nrow(outliers_precio)))
print(paste("Porcentaje de outliers:", round(100 * nrow(outliers_precio) / nrow(casas), 2), "%"))

print("=== INTERPRETACIÓN DE PRECIO_M2 ===")
print("1. La distribución es asimétrica hacia la derecha (sesgada positivamente)")
print("2. Hay varios outliers con precios muy altos por m²")
print("3. La mayoría de casas tienen precios entre $1,000-$2,000 por m²")
print("4. La mediana está alrededor de $1,300 por m²")

#. Percentiles (cada 5%):
#Mínimo: $305/m²
#5%: $782/m²
#25%: $1,105/m²
#50% (mediana): $1,304/m²
#75%: $1,497/m²
#95%: $1,866/m²
#Máximo: $2,785/m²

#Estadísticas:
#Media: $1,311/m²
#Mediana: $1,304/m²
#Desviación estándar: ~$285/m²
#Outliers: 27 casos (2.36% del total)

#Interpretación:
#Distribución asimétrica positiva (sesgada hacia la derecha)
#Rango típico: $1,000-$2,000/m²
#Casas premium: Precios >$1,866/m² (top 5%)
#Casas económicas: Precios <$782/m² (bottom 5%)
#No necesariamente más coches = mejor casa
#Muestra pequeña en extremos: Solo 4 casas con 4 coches - no es representativo
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/DianaTrevino/itam.git
git push -u origin main