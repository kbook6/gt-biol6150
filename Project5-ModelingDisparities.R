#Project 5
#Modeling Disparities
#Katherine Book

#set working directory
rm(list=ls())
set.seed(13)

install.packages("performance")

library("data.table")
library("dplyr")
library("parallel")
library('stringr')
library('ggplot2')
library('performance')
install.packages("farver")
library('farver')
install.packages("epitools")
library(epitools)
install.packages("car")
library(car)
install.packages("DHARMa")
library('DHARMa')
install.packages("minqa")
library('minqa')
install.packages("ResourceSelection")
library('ResourceSelection')


##### Question 1: Summarize the data #####
      #summarize prevalence (for binary) or mean & median (for quantitative) for 
      #the two traits: type 2 diabetes and A1C levels
      #simple graphs (histograms or boxplots) to visualize

###load the data
cohort = as.data.frame(fread("C:/Users/Katherine Book/OneDrive/Documents/0-fall_24/gaab/ParticipantCohort.tsv"))
dim(cohort)
head(cohort)

a1c = as.data.frame(fread("C:/Users/Katherine Book/OneDrive/Documents/0-fall_24/gaab/ParticipantA1C.tsv"))
dim(a1c)
head(a1c)

t2d = as.data.frame(fread("C:/Users/Katherine Book/OneDrive/Documents/0-fall_24/gaab/ParticipantT2DStatus.tsv"))
dim(t2d)
head(t2d)

# Merge the datasets together.
cohort = merge(merge(cohort, a1c, by = "ParticipantID"), t2d, by = "ParticipantID")

# Make SIRE as a categorical variable.
unique(cohort$SIRE)
cohort$SIRE = factor(cohort$SIRE, levels = c("White", "Black", "Hispanic"))
cohort$T2DStatus = factor(cohort$T2DStatus, level = c(0, 1))

###quality control
#QC for t2d
sum(is.na(t2d)) #checks for missing data (output 0 = no missing data)
#QC for a1c
sum(is.na(a1c)) #checks for missing data (output 0 = no missing data)

# Visualize the density of age distribution.
ggplot(cohort, aes(x = A1C, fill = SIRE)) + 
  geom_density(alpha = 0.3) + 
  theme_bw(base_size = 20) + 
  theme(legend.position = "bottom")

#more QC for a1c
z_scores <- scale(cohort$A1C) #a1c z scores
outliers <- cohort[abs(z_scores) > 2, ] #outliers by z score
outliers_df <- data.frame(ParticipantID = outliers$ParticipantID, A1C = outliers$A1C)
QC_cohort_a1c <- cohort %>% 
  anti_join(outliers, by = "ParticipantID")
#visualize again post QC
ggplot(cohort, aes(x = A1C, fill = SIRE)) + 
  geom_density(alpha = 0.3) + 
  theme_bw(base_size = 20) + 
  theme(legend.position = "bottom")

###summarize
mean(a1c$A1C)
median(a1c$A1C)

###visualize
#a1c
ggplot(QC_cohort_a1c, aes(x = SIRE, y = A1C, fill = SIRE)) +
  geom_boxplot() +
  labs(title = "Box Plot of A1C by SIRE", x = "SIRE", y = "A1C") +
  theme_minimal()
#t2d
ggplot(cohort, aes(x = SIRE, fill = T2DStatus)) +
  geom_bar(position = "fill") +
  labs(title = "T2D Status by SIRE", x = "SIRE", y = "T2DStatus") +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()

#t2d is binary
prevalence_t2d <- mean(t2d$T2D, na.rm = TRUE) * 100
prevalence_t2d


##### Question 2: Model A1C levels #####
      #run a simple linear regression model and test for association of
      #A1C with self-identified race/ethnicity
      #Adjust the models with age and sex

# Create a linear model to test for A1C disparities within the outlier-removed database.
a1c_mod <- lm(A1C ~ SIRE + Sex + Age, data = QC_cohort_a1c)
summary_stats_a1c = summary(a1c_mod)$coefficients %>% as.data.frame()
summary(a1c_mod)


##### Question 3: Model T2D status #####
      #run a simple linear regression model and test for association of
      #T2D status

# Create a logistic model to test for T2D disparities.
t2d_mod <- glm(T2DStatus ~ SIRE + Sex + Age, data = cohort, family = "binomial")
summary_stats_t2d = summary(t2d_mod)$coefficients %>% as.data.frame()
summary(t2d_mod)


##### Question 4: Get ORs and CI #####
      #For each model in Q2 and Q3, find confidence intervals for linear and odds ratio & 
      #confidence intervals for the logistic regression model.

###CI for a1c linear model
# Create a linear model to test for A1C disparities within the outlier-removed datase.
conf_intervals_a1c <- confint(a1c_mod) %>% as.data.frame()
names(conf_intervals_a1c) = c("Low", "High")
summary_stats_a1c = merge(summary_stats_a1c, conf_intervals_a1c, by='row.names', all=TRUE)
names(summary_stats_a1c)[1] = "Variable"

###CI for t2d logistic model
conf_intervals_t2d <- confint(t2d_mod) %>% as.data.frame()
names(conf_intervals_t2d) = c("Low", "High")
summary_stats_t2d = merge(summary_stats_t2d, conf_intervals_t2d, by='row.names', all=TRUE)
names(summary_stats_t2d)[1] = "Variable"

###odds ratio for t2d logistic model
# Extract the coefficients and calculate odds ratios
odds_ratios <- exp(coef(t2d_mod)) %>% as.data.frame()
names(odds_ratios) <- "OddsRatio"
# Add row names as a column for merging
odds_ratios <- tibble::rownames_to_column(odds_ratios, var = "Variable")
# Convert confidence intervals to odds ratios by exponentiating them
conf_intervals_t2d <- tibble::rownames_to_column(conf_intervals_t2d, var = "Variable")
names(conf_intervals_t2d)[2:3] <- c("LowCI", "HighCI")  # Rename confidence interval columns
# Merge odds ratios with confidence intervals
summary_stats_t2d <- merge(odds_ratios, conf_intervals_t2d, by = "Variable", all = TRUE)

# Round to 2 decimal places and filter out intercept
summary_stats_a1c = summary_stats_a1c %>% 
  mutate_if(is.numeric, round, digits = 2) %>% 
  filter(Variable != "(Intercept)")
summary_stats_t2d <- summary_stats_t2d %>%
  mutate_if(is.numeric, round, digits = 2) %>%
  filter(Variable != "(Intercept)")

# View the results
head(summary_stats_a1c)
head(summary_stats_t2d)


##### Question 5: Evaluate models #####
###5.1 Variance inflation factor
#a1c
vif_values_a1c <- vif(a1c_mod)
vif_values_a1c #using the car package
check_collinearity(a1c_mod) #just to check it again using performance

#t2d
vif_values_t2d <- vif(t2d_mod)
vif_values_t2d #using the car package
check_collinearity(t2d_mod) #checking it again using performance

###5.2 Normality of residuals
check_normality(a1c_mod)
check_residuals(t2d_mod)

###5.3 Homogeneity of variance within groups
check_heteroscedasticity(a1c_mod)
check_heteroscedasticity(t2d_mod) #doesn't work so use another method (not a gaussian model)
hoslem_test <- hoslem.test(cohort$T2DStatus, fitted(t2d_mod))
hoslem_test #small p-value means null is rejected, thus the model does not fit the data well

#plotting
residuals <- residuals(t2d_mod, type = "deviance")
fitted_values <- fitted(t2d_mod)
diagnostic_data <- data.frame(Fitted = fitted_values, Residuals = residuals)

ggplot(diagnostic_data, aes(x = Fitted, y = Residuals)) + 
  geom_point(alpha = 0.3) + 
  geom_hline(yintercept = 0, color = 'green') + 
  labs(title = "Residuals vs Fitted Values for Logistic Regression", x = "Fitted Values", y = "Residuals") +
  theme_minimal()
