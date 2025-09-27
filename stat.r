library(survey)
library(dplyr)

analysis_data <- read.csv("cleaned_nhanes_f.csv")

design <- svydesign(
  ids = ~SDMVPSU,
  strata = ~SDMVSTRA, 
  weights = ~weight,
  data = analysis_data,
  nest = TRUE
)

model_smoking <- svyglm(RA ~ I(smoking == "Current") + age + sex + race, 
                        design = design, family = binomial())

model_vitd <- svyglm(RA ~ vitD_deficient + age + sex + race,
                     design = design, family = binomial())

model_combined <- svyglm(RA ~ I(smoking == "Current") + vitD_deficient + age + sex + race,
                         design = design, family = binomial())

extract_results <- function(model, exposure) {
  coef_summary <- summary(model)$coefficients
  exposure_row <- grep(exposure, rownames(coef_summary))
  
  or <- exp(coef_summary[exposure_row, 1])
  ci_lower <- exp(coef_summary[exposure_row, 1] - 1.96 * coef_summary[exposure_row, 2])
  ci_upper <- exp(coef_summary[exposure_row, 1] + 1.96 * coef_summary[exposure_row, 2])
  p_value <- coef_summary[exposure_row, 4]
  
  return(c(OR = or, CI_Lower = ci_lower, CI_Upper = ci_upper, P_Value = p_value))
}

smoking_results <- extract_results(model_smoking, "Current")
vitd_results <- extract_results(model_vitd, "vitD_deficient")

results_df <- data.frame(
  Exposure = c("Current Smoking", "Vitamin D Deficiency"),
  OR = c(smoking_results["OR"], vitd_results["OR"]),
  CI_Lower = c(smoking_results["CI_Lower"], vitd_results["CI_Lower"]),
  CI_Upper = c(smoking_results["CI_Upper"], vitd_results["CI_Upper"]),
  P_Value = c(smoking_results["P_Value"], vitd_results["P_Value"])
)

print(results_df)