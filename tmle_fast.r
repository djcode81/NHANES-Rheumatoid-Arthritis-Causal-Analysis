library(tmle)
library(dplyr)

set.seed(123)

analysis_data <- read.csv("cleaned_nhanes_f.csv")

analysis_data$sex <- factor(analysis_data$sex)
analysis_data$race <- factor(analysis_data$race)

tmle_smoking <- tmle(
  Y = analysis_data$RA,
  A = ifelse(analysis_data$smoking == "Current", 1, 0),
  W = analysis_data[, c("age", "sex", "race")],
  Q.SL.library = "SL.glm",
  g.SL.library = "SL.glm",
  family = "binomial"
)

tmle_vitd <- tmle(
  Y = analysis_data$RA,
  A = analysis_data$vitD_deficient,
  W = analysis_data[, c("age", "sex", "race")],
  Q.SL.library = "SL.glm",
  g.SL.library = "SL.glm",
  family = "binomial"
)

causal_results <- data.frame(
  Exposure = c("Current Smoking", "Vitamin D Deficiency"),
  ATE = round(c(tmle_smoking$estimates$ATE$psi, tmle_vitd$estimates$ATE$psi), 3),
  CI_Lower = round(c(tmle_smoking$estimates$ATE$CI[1], tmle_vitd$estimates$ATE$CI[1]), 3),
  CI_Upper = round(c(tmle_smoking$estimates$ATE$CI[2], tmle_vitd$estimates$ATE$CI[2]), 3),
  P_Value = round(c(tmle_smoking$estimates$ATE$pvalue, tmle_vitd$estimates$ATE$pvalue), 3)
)

print(causal_results)
write.csv(causal_results, "tmle_results.csv", row.names = FALSE)