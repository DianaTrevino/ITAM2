library(tidyverse)

data <- read.csv("data/processed/auto_mpg_clean.csv", stringsAsFactors = FALSE)

# Asegurar tipos correctos
data$horsepower <- as.numeric(data$horsepower)

# Origin como factor con etiquetas
data$origin <- factor(
  data$origin,
  levels = c(1, 2, 3),
  labels = c("USA", "Europe", "Japan")
)

# ---------------------------
# Univariado
# ---------------------------
num_vars <- c("mpg","cylinders","displacement","horsepower",
              "weight","acceleration","model_year")

univariate <- data %>%
  summarise(across(all_of(num_vars),
                   list(mean = ~mean(.x, na.rm=TRUE),
                        sd   = ~sd(.x, na.rm=TRUE),
                        min  = ~min(.x, na.rm=TRUE),
                        max  = ~max(.x, na.rm=TRUE)),
                   .names = "{.col}_{.fn}"))

write.csv(univariate, "data/processed/univariate_stats.csv", row.names = FALSE)

origin_counts <- as.data.frame(table(data$origin))
write.csv(origin_counts, "data/processed/origin_counts.csv", row.names = FALSE)

# ---------------------------
# Bivariado
# ---------------------------
cor_matrix <- data %>%
  select(all_of(num_vars)) %>%
  cor(use = "complete.obs")

write.csv(cor_matrix, "data/processed/cor_matrix.csv")

cor_mpg <- sort(cor_matrix[,"mpg"], decreasing = TRUE)
write.csv(data.frame(variable = names(cor_mpg), cor = cor_mpg),
          "data/processed/cor_with_mpg.csv", row.names = FALSE)

origin_summary <- data %>%
  group_by(origin) %>%
  summarise(
    n = n(),
    mean_mpg = mean(mpg, na.rm=TRUE),
    median_mpg = median(mpg, na.rm=TRUE),
    min_mpg = min(mpg, na.rm=TRUE),
    max_mpg = max(mpg, na.rm=TRUE)
  )

write.csv(origin_summary, "data/processed/origin_vs_mpg.csv", row.names = FALSE)

# ---------------------------
# Gráficos requeridos
# ---------------------------
p1 <- ggplot(data, aes(x=origin, y=mpg)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title="MPG por Origen", x="Origen", y="MPG")

p2 <- ggplot(data, aes(x=weight, y=mpg, color=origin)) +
  geom_point(alpha=0.7) +
  theme_minimal() +
  labs(title="Peso vs MPG", x="Peso", y="MPG")

ggsave("data/processed/boxplot_mpg_origin.png", p1, width=7, height=5)
ggsave("data/processed/scatter_weight_mpg.png", p2, width=7, height=5)

cat("OK -> Univariado, bivariado y gráficos guardados en data/processed/\n")
