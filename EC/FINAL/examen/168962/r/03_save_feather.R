library(arrow)

data <- read.csv("data/processed/auto_mpg_clean.csv", stringsAsFactors = FALSE)

# Asegurar tipos correctos
data$horsepower <- as.numeric(data$horsepower)

data$origin <- factor(
  data$origin,
  levels = c(1, 2, 3),
  labels = c("USA", "Europe", "Japan")
)

write_feather(data, "data/processed/auto_mpg.feather")

cat("OK -> data/processed/auto_mpg.feather\n")
