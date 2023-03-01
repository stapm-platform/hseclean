
# The aim of this code is to do a detailed check on the hseclean
# functions used to calculate average weekly consumption
# for Scotland
# the check focuses on the 2018 Scottish Health Survey

# load packages
library(hseclean)
library(data.table)
library(magrittr)
library(ggplot2)

# Location of Scottish data
root_dir <- "X:/HAR_PR/PR/Consumption_TA/HSE/Scottish Health Survey (SHeS)/"

# Read one year of SHeS data
data <- read_SHeS_2019(root = root_dir)

# prepare the basic demographic variables
data <- clean_age(data)
data <- clean_demographic(data)
data <- clean_economic_status(data)

# SHeS only has alcohol data on people over age 16
data <- data[age >= 16 & age <= 89]


## Process data on someone's smoking status, how much they smoke and how long they have been quit for

## Smoking status

data <- smk_status(data)

nrow(data[is.na(cig_smoker_status)])

data <- data[!is.na(cig_smoker_status)]

nrow(data)


# former smokers

data <- smk_former(data)

data[cig_smoker_status == "former" & is.na(years_since_quit)]

# smk_life_history

data <- smk_life_history(data)

# smk_amount

data <- smk_amount(data)


# check 

data[smoker_cat != "non_smoker" & cigs_per_day == 0]

# cigs per day includes the amount smoked by individuals who primarily smoke handrolled
# cigdyal does not

ggplot(data, aes(y = cigs_per_day, x = cigdyal)) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average cigarettes per day") +
  ylab("hseclean average cigarettes per day") +
  geom_abline(slope = 1, intercept = 0, colour = 2)




