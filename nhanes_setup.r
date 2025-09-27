library(nhanesA)
library(dplyr)
library(survey)

cycles <- c("F", "G", "H", "I", "J")

get_cycle_data <- function(cycle_code) {
  tryCatch({
    demo <- nhanes(paste0("DEMO_", cycle_code))
    mcq <- nhanes(paste0("MCQ_", cycle_code))
    vid <- nhanes(paste0("VID_", cycle_code))  # Changed from LAB25 to VID
    smq <- nhanes(paste0("SMQ_", cycle_code))
    biopro <- nhanes(paste0("BIOPRO_", cycle_code))
    
    if(is.null(demo)) return(NULL)
    
    result <- demo
    if(!is.null(mcq)) result <- merge(result, mcq, by = "SEQN", all.x = TRUE)
    if(!is.null(vid)) result <- merge(result, vid, by = "SEQN", all.x = TRUE)
    if(!is.null(smq)) result <- merge(result, smq, by = "SEQN", all.x = TRUE)
    if(!is.null(biopro)) result <- merge(result, biopro, by = "SEQN", all.x = TRUE)
    
    return(result)
  }, error = function(e) {
    message("Error downloading cycle ", cycle_code, ": ", e$message)
    return(NULL)
  })
}

get_nhanes_data <- function() {
  data_list <- list()
  for(i in seq_along(cycles)) {
    message("Processing cycle ", cycles[i])
    data_list[[i]] <- get_cycle_data(cycles[i])
  }
  
  valid_data <- data_list[!sapply(data_list, is.null)]
  do.call(rbind, valid_data)
}

clean_data <- function(data) {
  data %>%
    filter(RIDAGEYR >= 20) %>%
    mutate(
      RA = ifelse(MCQ160A == 1, 1, 0),
      smoking = case_when(
        SMQ020 == 2 ~ "Never",
        SMQ020 == 1 & SMQ040 == 1 ~ "Current", 
        SMQ020 == 1 & SMQ040 == 2 ~ "Former",
        TRUE ~ NA_character_
      ),
      vitD_deficient = ifelse(LBXVIDMS < 50, 1, 0),  # <50 nmol/L deficient
      age = RIDAGEYR,
      sex = ifelse(RIAGENDR == 1, "Male", "Female"),
      race = case_when(
        RIDRETH3 == 3 ~ "White",
        RIDRETH3 == 4 ~ "Black", 
        RIDRETH3 %in% 1:2 ~ "Hispanic",
        TRUE ~ "Other"
      ),
      weight = WTMEC2YR
    ) %>%
    select(SEQN, RA, smoking, vitD_deficient, age, sex, race, weight, LBXCRP) %>%
    filter(complete.cases(.))
}

message("Starting data download...")
raw_data <- get_nhanes_data()
message("Cleaning data...")
analysis_data <- clean_data(raw_data)
message("Complete! Dataset has ", nrow(analysis_data), " participants")