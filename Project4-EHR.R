rm(list=ls())
set.seed(13)

library("data.table")
install.packages("dplyr")
install.packages("utf8")
library("utf8")
library("dplyr")
library("parallel")
install.packages("stringi")
library("stringi")
library('stringr')
install.packages("colorspace")
library("colorspace")
library('ggplot2')

# Load the files for our cohort.
cohort = as.data.frame(fread("C:/Users/Katherine Book/OneDrive/Documents/0-fall_24/gaab/ParticipantEHR.tsv"))
range(cohort$ParticipantID)
dim(cohort)
head(cohort)

ehr_records = as.data.frame(fread("C:/Users/Katherine Book/OneDrive/Documents/0-fall_24/gaab//ParticipantEHR.tsv"))
dim(ehr_records)
head(ehr_records)

#Let's have a look at the EHR records.
print("Number of rows in our EHR df: ")
dim(ehr_records)

#See the number of people in the EHR data.
print("Number of participants that have EHR records: ")
length(unique(ehr_records$ParticipantID))

print("Number of unique EHR records: ") ###
length(unique(ehr_records$ICD10CM))

#codes specific to T2D
t2d_codes <- c("E11", "E11.0", "E11.1", "E11.2", "E11.3", "E11.4", "E11.5", "E11.6", "E11.8", "E11.9") 
#codes relating to T2D, T1D, and other relating symptoms
exclude_codes <- c("E08", "E08.0", "E08.1", "E08.2", "E08.3", "E08.4", "E08.5", "E08.6", "E08.8", "E08.9",
                   "E09", "E09.0", "E09.1", "E09.2", "E09.3", "E09.4", "E09.5", "E09.6", "E09.8", "E09.9",
                   "E10", "E10.0", "E10.1", "E10.2", "E10.3", "E10.4", "E10.5", "E10.6", "E10.8", "E10.9", 
                   "E12", "E12.0", "E12.1", "E12.2", "E12.3", "E12.4", "E12.5", "E12.6", "E12.8", "E12.9", 
                   "E13", "E13.0", "E13.1", "E13.2", "E13.3", "E13.4", "E13.5", "E13.6", "E13.8", "E13.9", 
                   "E14", "E14.0", "E14.1", "E14.2", "E14.3", "E14.4", "E14.5", "E14.6", "E14.8", "E14.9")

### First Attempt, not used ###

#exclude codes includes T2D codes and the related symptoms
non_t2d_cohort <- cohort %>%
  filter(!(ParticipantID %in% unique(ParticipantID[ICD10CM %in% exclude_codes])))
control_count <- n_distinct(non_t2d_cohort$ParticipantID)
cat("Number of participants who do not have Type 2 Diabetes:", control_count)

#Case (2 entries on 2 diff dates of T2D)
t2d_twice <- cohort %>%
  filter(ICD10CM %in% t2d_codes) %>%
  group_by(ParticipantID, ICD10CM) %>%
  summarize(unique_dates = n_distinct(Date), .groups = 'drop') %>%
  filter(unique_dates >= 2)
t2d_twice_count <- n_distinct(t2d_twice$ParticipantID)
cat("Number of participants with at least 2 entries of T2D ICD-10 codes on different dates:", t2d_twice_count, "\n")

#Excluded
#just 1 T2D code OR include anyone who has type 1 diabetes (condition 3, anything from the exclusion criteria)
t2d_once <- cohort %>%
  filter(ICD10CM %in% t2d_codes) %>%
  group_by(ParticipantID, ICD10CM) %>%
  summarize(unique_dates1 = n_distinct(Date), .groups = 'drop') %>%
  filter(unique_dates1 == 1)
t2d_once_count <- n_distinct(t2d_once$ParticipantID)
cat("number of participants with only 1 entry of T2D ICD-10 codes:", t2d_once_count, "\n")

### Final Attempt Below ###

#determining case, control, and excluded
#case refers to individuals who have at least two T2D codes on 2 different dates
#control refers to individuals with no T2D codes or related conditions
#excluded refers to individuals with exactly 1 T2D code or codes of any related conditions

cohort_numbers <- cohort %>%
  group_by(ParticipantID) %>%
  summarize(
    t2d_code_count = sum(ICD10CM %in% t2d_codes), #counts how many times a participant has t2d codes
    d_code_count = sum(ICD10CM %in% exclude_codes), #counts how many times a participant has related cond
    unique_dates = n_distinct(Date), #counts unique dates
    t2dstatus = case_when(
      t2d_code_count >= 2 ~ "Case", 
      t2d_code_count == 1 | d_code_count >= 1 ~ "Excluded", 
      t2d_code_count == 0 & d_code_count == 0 ~ "Control", 
      TRUE ~ "Unknown" # catch all for other cases
    )
  ) %>%
  ungroup()
cohort_numbers %>%
  count(t2dstatus) %>%
  print()

#output adds up to 100,000, which is the number of participants

