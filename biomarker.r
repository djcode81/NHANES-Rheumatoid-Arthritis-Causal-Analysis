library(dplyr)
library(ggplot2)
library(cluster)
library(pheatmap)
library(tibble)

analysis_data <- read.csv("cleaned_nhanes_f.csv")

biomarker_data <- analysis_data %>%
  select(SEQN, RA, smoking, vitD_deficient, age, sex, race, crp) %>%
  filter(complete.cases(.))

clustering_vars <- biomarker_data %>%
  mutate(
    smoking_current = ifelse(smoking == "Current", 1, 0),
    smoking_former = ifelse(smoking == "Former", 1, 0)
  ) %>%
  select(age, smoking_current, smoking_former, vitD_deficient) %>%
  scale()

set.seed(123)
k3 <- kmeans(clustering_vars, centers = 3, nstart = 25)
biomarker_data$cluster <- as.factor(k3$cluster)

cluster_summary <- biomarker_data %>%
  group_by(cluster) %>%
  summarise(
    n = n(),
    age_mean = round(mean(age), 1),
    smoking_current_prev = round(mean(smoking == "Current") * 100, 1),
    smoking_former_prev = round(mean(smoking == "Former") * 100, 1),
    vitD_def_prev = round(mean(vitD_deficient) * 100, 1),
    crp_mean = round(mean(crp), 2),
    crp_sd = round(sd(crp), 2),
    RA_prev = round(mean(RA) * 100, 1)
  )

cluster_matrix <- biomarker_data %>%
  group_by(cluster) %>%
  summarise(
    Age = mean(age),
    `Current Smoking` = mean(smoking == "Current") * 100,
    `Former Smoking` = mean(smoking == "Former") * 100,
    `Vitamin D Deficiency` = mean(vitD_deficient) * 100,
    CRP = mean(crp),
    `RA Prevalence` = mean(RA) * 100
  ) %>%
  column_to_rownames("cluster") %>%
  as.matrix() %>%
  scale()

pheatmap(cluster_matrix,
         main = "Behavioral Risk Clusters: Demographics, Biomarkers & RA",
         cluster_rows = FALSE,
         cluster_cols = TRUE,
         color = colorRampPalette(c("blue", "white", "red"))(100),
         cellwidth = 40,
         cellheight = 30,
         fontsize = 10,
         filename = "biomarker_heatmap.png",
         width = 10,
         height = 6)

p1 <- ggplot(biomarker_data, aes(x = age, y = crp, color = cluster)) +
  geom_point(alpha = 0.7) +
  labs(
    title = "Risk Factor Clusters: Age vs CRP Distribution",
    x = "Age (years)",
    y = "C-Reactive Protein (mg/L)",
    color = "Risk Cluster"
  ) +
  theme_minimal()

p2 <- ggplot(biomarker_data, aes(x = cluster, fill = factor(RA))) +
  geom_bar(position = "fill") +
  labs(
    title = "RA Prevalence by Behavioral Risk Cluster",
    x = "Behavioral Risk Cluster",
    y = "Proportion",
    fill = "RA Status"
  ) +
  scale_fill_manual(values = c("0" = "lightblue", "1" = "darkred"),
                    labels = c("No RA", "RA")) +
  theme_minimal()

ggsave("age_crp_scatter.png", p1, width = 8, height = 6, dpi = 300)
ggsave("ra_by_cluster.png", p2, width = 8, height = 6, dpi = 300)

write.csv(cluster_summary, "cluster_summary.csv", row.names = FALSE)