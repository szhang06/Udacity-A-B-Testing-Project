# Load necessary library
install.packages("readxl")
library(readxl)

# Load baseline data
data <- read_excel("C:/Users/Wenwen/Desktop/ab_testing/Final Project Baseline Values.xlsx", col_names = FALSE)
colnames(data) <- c("...1", "...2")

# Extract probabilities from baseline data
probability_enroll_click <- data$...2[5]  # Probability of enrollment after click
click_through_probability <- data$...2[4]  # Click-through probability
probability_payment_enroll <- data$...2[6]  # Probability of payment after enrollment
probability_payment_click <- data$...2[7]  # Probability of payment after click

# Calculate metrics
unique_view_course_page <- 5000
unique_cookie_trial <- unique_view_course_page * click_through_probability
sample_enrollment_per_day <- unique_cookie_trial * probability_enroll_click

# Standard deviations for key metrics
sd_gross_conversion <- sqrt(probability_enroll_click * (1 - probability_enroll_click) / unique_cookie_trial)
sd_retention <- sqrt(probability_payment_enroll * (1 - probability_payment_enroll) / sample_enrollment_per_day)
sd_net_conversion <- sqrt(probability_payment_click * (1 - probability_payment_click) / unique_cookie_trial)

# Sample size calculations
size_gross_conversion <- 25835
no_of_pageview <- size_gross_conversion * 2 / data$...2[4]
no_of_days_pageview <- no_of_pageview / data$...2[1]

size_retention <- 39115
no_of_retention <- size_retention * 2 / (data$...2[3] / data$...2[1])
days_retention <- no_of_retention / data$...2[1]

size_net_conversion <- 27413
no_of_pageview_net_conversion <- size_net_conversion * 2 / data$...2[4]
days_net_conversion <- no_of_pageview_net_conversion / data$...2[1]

# Sanity checks using experimental results
data_res <- read_excel("C:/Users/Wenwen/Desktop/ab_testing/Final Project Results.xlsx")
control_pageviews <- sum(data_res$Pageviews)

sheet_names <- excel_sheets("C:/Users/Wenwen/Desktop/ab_testing/Final Project Results.xlsx")
experiment_data <- read_excel("C:/Users/Wenwen/Desktop/ab_testing/Final Project Results.xlsx", sheet = sheet_names[2])
exp_pageviews <- sum(experiment_data$Pageviews)

# Margin of error and confidence intervals for pageviews
me <- 1.96 * sqrt(0.5 * (1 - 0.5) / (control_pageviews + exp_pageviews))
CI_lower <- 0.5 - me
CI_upper <- 0.5 + me
cat("95% Confidence Interval for Pageviews: (", CI_lower, ", ", CI_upper, ")\n")

# Margin of error and confidence intervals for clicks
ctl_clicks <- sum(data_res$Clicks)
exp_clicks <- sum(experiment_data$Clicks)
me_clicks <- 1.96 * sqrt(0.5 * (1 - 0.5) / (ctl_clicks + exp_clicks))
CI_lower <- 0.5 - me_clicks
CI_upper <- 0.5 + me_clicks
cat("95% Confidence Interval for Clicks: (", CI_lower, ", ", CI_upper, ")\n")

# Click-through probability (CTP) analysis
p_pooled_ctp <- (ctl_clicks + exp_clicks) / (control_pageviews + exp_pageviews)
me_ctp <- 1.96 * sqrt(p_pooled_ctp * (1 - p_pooled_ctp) * (1 / control_pageviews + 1 / exp_pageviews))
ctp_ctl <- ctl_clicks / control_pageviews
ctp_exp <- exp_clicks / exp_pageviews
dif <- ctp_exp - ctp_ctl
ci_lower_ctp <- dif - me_ctp
ci_upper_ctp <- dif + me_ctp
cat("95% Confidence Interval for CTP Difference: (", ci_lower_ctp, ", ", ci_upper_ctp, ")\n")

# Effect size tests for gross conversion and net conversion
p_pooled_gc <- (sum(data_res$Enrollments[1:23]) + sum(experiment_data$Enrollments[1:23])) / (sum(data_res$Clicks[1:23]) + sum(experiment_data$Clicks[1:23]))
sd_gc <- sqrt(p_pooled_gc * (1 - p_pooled_gc) * (1 / sum(data_res$Clicks[1:23]) + 1 / sum(experiment_data$Clicks[1:23])))
d_gc <- sum(experiment_data$Enrollments[1:23]) / sum(experiment_data$Clicks[1:23]) - sum(data_res$Enrollments[1:23]) / sum(data_res$Clicks[1:23])
me_gc <- 1.96 * sd_gc
ci_lower_gc <- d_gc - me_gc
ci_upper_gc <- d_gc + me_gc
cat("95% Confidence Interval for Gross Conversion: (", ci_lower_gc, ", ", ci_upper_gc, ")\n")

p_pooled_nc <- (sum(data_res$Payments[1:23]) + sum(experiment_data$Payments[1:23])) / (sum(data_res$Clicks[1:23]) + sum(experiment_data$Clicks[1:23]))
sd_nc <- sqrt(p_pooled_nc * (1 - p_pooled_nc) * (1 / sum(data_res$Clicks[1:23]) + 1 / sum(experiment_data$Clicks[1:23])))
d_nc <- sum(experiment_data$Payments[1:23]) / sum(experiment_data$Clicks[1:23]) - sum(data_res$Payments[1:23]) / sum(data_res$Clicks[1:23])
me_nc <- 1.96 * sd_nc
ci_lower_nc <- d_nc - me_nc
ci_upper_nc <- d_nc + me_nc
cat("95% Confidence Interval for Net Conversion: (", ci_lower_nc, ", ", ci_upper_nc, ")\n")