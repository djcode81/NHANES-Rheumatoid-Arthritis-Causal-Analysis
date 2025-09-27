library(dplyr)
library(ggplot2)
library(cluster)
library(factoextra)
library(pheatmap)
library(tibble)

analysis_data <- read.csv("cleaned_nhanes_f.csv")

biomarker_data <- analysis_data %>%
  select(SEQN, RA, smoking, vitD_deficient, age, sex, race, crp) %>%
  filter(complete.cases(.))

clustering_vars <- biomarker_data %>%
  select(crp, age) %>%
  scale()

set.seed(123)
k3 <- kmeans(clustering_vars, centers = 3, nstart = 25)

biomarker_data$cluster <- as.factor(k3$cluster)

cluster_summary <- biomarker_data %>%
  group_by(cluster) %>%
  summarise(
    n = n(),
    crp_mean = round(mean(crp, na.rm = TRUE), 2),
    crp_sd = round(sd(crp, na.rm = TRUE), 2),
    age_mean = round(mean(age, na.rm = TRUE), 1),
    RA_prev = round(mean(RA) * 100, 1),
    smoking_prev = round(mean(smoking == "Current", na.rm = TRUE) * 100, 1),
    vitD_def_prev = round(mean(vitD_deficient, na.rm = TRUE) * 100, 1)
  )

print("Biomarker Cluster Summary:")
print(cluster_summary)

cluster_matrix <- biomarker_data %>%
  group_by(cluster) %>%
  summarise(
    CRP = mean(crp, na.rm = TRUE),
    Age = mean(age, na.rm = TRUE),
    `RA Prevalence` = mean(RA) * 100,
    `Current Smoking` = mean(smoking == "Current", na.rm = TRUE) * 100,
    `Vitamin D Deficiency` = mean(vitD_deficient, na.rm = TRUE) * 100
  ) %>%
  column_to_rownames("cluster") %>%
  as.matrix()

cluster_matrix_scaled <- scale(cluster_matrix)

pheatmap(cluster_matrix_scaled,
         main = "Biomarker Clusters: Inflammatory Phenotypes",
         cluster_rows = FALSE,
         cluster_cols = TRUE,
         color = colorRampPalette(c("blue", "white", "red"))(100),
         cellwidth = 40,
         cellheight = 30,
         fontsize = 10,
         filename = "biomarker_heatmap.png",
         width = 8,
         height = 6)

p1 <- ggplot(biomarker_data, aes(x = crp, y = age, color = cluster)) +
  geom_point(alpha = 0.7) +
  labs(
    title = "Biomarker Clustering: CRP vs Age",
    x = "C-Reactive Protein (mg/L)",
    y = "Age (years)",
    color = "Cluster"
  ) +
  theme_minimal()

p2 <- ggplot(biomarker_data, aes(x = cluster, fill = factor(RA))) +
  geom_bar(position = "fill") +
  labs(
    title = "RA Prevalence by Cluster",
    x = "Biomarker Cluster",
    y = "Proportion",
    fill = "RA Status"
  ) +
  scale_fill_manual(values = c("0" = "lightblue", "1" = "darkred"),
                    labels = c("No RA", "RA")) +
  theme_minimal()

print(p1)
print(p2)

ggsave("crp_age_scatter.png", p1, width = 8, height = 6, dpi = 300)
ggsave("ra_by_cluster.png", p2, width = 8, height = 6, dpi = 300)

write.csv(cluster_summary, "cluster_summary.csv", row.names = FALSE)