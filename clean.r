library(foreign)
library(dplyr)

data_dir <- "data/"

demo_f <- read.xport(paste0(data_dir, "DEMO_F.xpt"))
mcq_f <- read.xport(paste0(data_dir, "MCQ_F.xpt"))
vid_f <- read.xport(paste0(data_dir, "VID_F.xpt"))
smq_f <- read.xport(paste0(data_dir, "SMQ_F.xpt"))
crp_f <- read.xport(paste0(data_dir, "CRP_F.xpt"))

cycle_f <- demo_f %>%
  left_join(mcq_f, by = "SEQN") %>%
  left_join(vid_f, by = "SEQN") %>%
  left_join(smq_f, by = "SEQN") %>%
  left_join(crp_f, by = "SEQN")

analysis_data <- cycle_f %>%
  filter(RIDAGEYR >= 20) %>%
  mutate(
    RA = case_when(
      MCQ160A == 1 ~ 1,
      MCQ160A == 2 ~ 0,
      TRUE ~ NA_real_
    ),
    smoking = case_when(
      SMQ020 == 2 ~ "Never",
      SMQ020 == 1 & SMQ040 == 1 ~ "Current",
      SMQ020 == 1 & SMQ040 == 2 ~ "Former",
      TRUE ~ NA_character_
    ),
    vitD_deficient = case_when(
      LBXVIDMS < 50 ~ 1,
      LBXVIDMS >= 50 ~ 0,
      TRUE ~ NA_real_
    ),
    age = RIDAGEYR,
    sex = case_when(
      RIAGENDR == 1 ~ "Male",
      RIAGENDR == 2 ~ "Female"
    ),
    race = case_when(
      RIDRETH1 == 3 ~ "White",
      RIDRETH1 == 4 ~ "Black", 
      RIDRETH1 %in% 1:2 ~ "Hispanic",
      TRUE ~ "Other"
    ),
    weight = WTMEC2YR,
    crp = LBXCRP
  ) %>%
  select(SEQN, RA, smoking, vitD_deficient, age, sex, race, weight, crp, SDMVSTRA, SDMVPSU) %>%
  filter(complete.cases(.))

write.csv(analysis_data, "cleaned_nhanes_f.csv", row.names = FALSE)