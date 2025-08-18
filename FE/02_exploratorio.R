library(tidyverse)
library(readr)

### Tomadores de te

# 1. Tablas cruzadas: azúcar y tipo de té

#Lee los datos de tomadores de té
setwd("/Users/dianalauratrevinorivera/Documents/ITAM/Fundamentos  Estadisticos/Tarea 1 Análisis Exploratorio 2")
tea <- readr::read_csv("tea.csv", show_col_types = FALSE)
dir.create("outputs", showWarnings = FALSE)

## Haz una tabla cruzada de uso de azúcar (sugar) con tipo de té (Tea),
## mostrando el número de casos en cada cruce
# Pon el uso de azúcar en las columnas

tab_sugar_tea <- tea |>
  count(Tea, sugar, name = "n") |>
  tidyr::pivot_wider(names_from = sugar, values_from = n, values_fill = 0)
print(tab_sugar_tea)
  
## ¿Cómo se relaciona el uso de azúcar con el té que toman las personas?
## Haz una tabla de porcentajes por renglón (para cada tipo de té) de tu tabla anterior

tab_sugar_tea_pct_row <- tab_sugar_tea |>
  mutate(total = rowSums(across(-Tea))) |>
  mutate(across(-c(Tea, total), ~ .x / total)) |>
  select(-total)
print(tab_sugar_tea_pct_row)
  
## 2. Haz una tabla cruzada para la variable Tea y la presentación (how)
## donde las columnas son el tipo de Té

tab_how_tea <- tea |>
  count(how, Tea, name = "n") |>
  tidyr::pivot_wider(names_from = Tea, values_from = n, values_fill = 0)
print(tab_how_tea)
  
## Ahora calcula porcentajes por columna de la tabla anterior

tab_how_tea_pct_col <- {
  cols_only <- tab_how_tea |> select(-how)
  totals <- summarise(cols_only, across(everything(), sum))
  bind_cols(
    tibble(how = tab_how_tea$how),
    mutate(cols_only, across(everything(), ~ .x / as.numeric(totals[[cur_column()]])))
  )
}
print(tab_how_tea_pct_col)
  
# ¿Cómo son diferentes en cuanto a la presentación los tomadores de distintos tés (negro, earl gray, etc.)?

#Diferencias principales:

#Earl Grey:
#Más tradicional: 60.6% usa tea bags (mayor proporción)
#Menos artesanal: Solo 8.3% usa presentación unpackaged
#Más convencional en sus preferencias

#Black Tea:
#Más diverso: Distribución más equilibrada
#Más artesanal: 20.3% prefiere unpackaged (más del doble que Earl Grey)
#Menos dependiente de tea bags (48.6% vs 60.6% de Earl Grey)

#Green Tea:
#Intermedio: 51.5% usa tea bags
#Moderadamente artesanal: 15.2% unpackaged
#Balanceado entre conveniencia y tradición

#Interpretación:
#Earl Grey → Consumidores más convencionales, prefieren la comodidad de tea bags
#Black Tea → Consumidores más diversos y artesanales, mayor apertura a diferentes presentaciones
#Green Tea → Consumidores intermedios, balance entre tradición y modernidad
#Conclusión: Los tomadores de black tea son los más diversos en sus preferencias de presentación, mientras que los de Earl Grey son los más tradicionales/convencionales.


