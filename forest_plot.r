library(ggplot2)
library(dplyr)

or_results <- data.frame(
  Exposure = c("Current Smoking", "Vitamin D Deficiency"),
  Method = "Logistic Regression",
  Estimate = c(1.953, 1.172),
  Lower = c(1.627, 0.810),
  Upper = c(2.343, 1.697),
  Significant = c("***", "NS")
)

ate_results <- data.frame(
  Exposure = c("Current Smoking", "Vitamin D Deficiency"),
  Method = "TMLE",
  Estimate = c(0.098, 0.015),
  Lower = c(0.067, -0.014),
  Upper = c(0.130, 0.044),
  Significant = c("***", "NS")
)

combined_results <- rbind(or_results, ate_results)
combined_results$Method <- factor(combined_results$Method, levels = c("Logistic Regression", "TMLE"))

p <- ggplot(combined_results, aes(x = Estimate, y = interaction(Exposure, Method), color = Method)) +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2) +
  geom_text(aes(label = Significant), hjust = -0.5, size = 3, fontface = "bold") +
  geom_vline(xintercept = ifelse(grepl("Regression", combined_results$Method[1]), 1, 0), 
             linetype = "dashed", alpha = 0.6) +
  facet_wrap(~ifelse(Method == "Logistic Regression", "Odds Ratios", "Average Treatment Effects (Risk Difference)"), 
             scales = "free_x", ncol = 2) +
  labs(
    title = "Association vs Causal Effects: Smoking and Vitamin D on Rheumatoid Arthritis",
    subtitle = "NHANES 2009-2010 (N = 4,307 adults ≥20 years) | *** p<0.001, NS = not significant",
    x = "Effect Size",
    y = "Exposure",
    caption = "Note: Vitamin D deficiency shows no significant causal effect (TMLE CI crosses null)"
  ) +
  scale_color_manual(values = c("Logistic Regression" = "#2E86AB", "TMLE" = "#A23B72")) +
  theme_minimal() +
  theme(
    legend.position = "none",
    strip.text = element_text(face = "bold", size = 10),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11),
    plot.caption = element_text(size = 9, hjust = 0),
    axis.text.y = element_text(size = 9)
  )

ggsave("forest_plot.png", p, width = 12, height = 7, dpi = 300)