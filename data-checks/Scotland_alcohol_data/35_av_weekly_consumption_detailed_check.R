
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

# The variables to retain
keep_vars = c(
  "hse_id", "wt_int", "year",
  "age", "age_cat", "sex", "imd_quintile",
  "drinks_now",
  "drink_freq_7d", "n_days_drink", "peakday", "binge_cat",
  "beer_units", "wine_units", "spirit_units", "rtd_units",
  "weekmean", "drating", "dnoft", "dnnow", "dnany", "dnevr")

# Read 2018 SHeS data
data <- read_SHeS_2018(root = root_dir)

# data <- read_SHeS_2019(root = root_dir)

# prepare the basic demographic variables
data <- clean_age(data)
data <- clean_demographic(data)

# SHeS only has alcohol data on people over age 16
data <- data[age >= 16 & age <= 89]


## Process data on whether someone drinks and frequency of drinking

# first, step through function in hseclean to check line by line and add annotation

data <- alc_drink_now_allages(data)

nrow(data[is.na(drinks_now)])
# 24 rows of missing data
# these look to have general missingness across all variables

# remove the missing rows of data
data <- data[!is.na(drinks_now)]


## Alcohol average weekly consumption (adults)

#alc_weekmean_adult

data <- alc_weekmean_adult(data)

# normal beer
ggplot(data, aes(y = nbeer_units, x = nberwu)) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average units per week") +
  ylab("hseclean average units per week") +
  geom_abline(slope = 1, intercept = 0, colour = 2) +
  ggtitle("Normal beer, lager, stout, cider and shandy")

# strong beer
ggplot(data, aes(y = sbeer_units, x = sberwu)) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average units per week") +
  ylab("hseclean average units per week") +
  geom_abline(slope = 1, intercept = 0, colour = 2) +
  ggtitle("Strong beer, lager, stout and cider")

# sherry
ggplot(data, aes(y = sherry_units, x = sherwu)) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average units per week") +
  ylab("hseclean average units per week") +
  geom_abline(slope = 1, intercept = 0, colour = 2) +
  ggtitle("Sherry and martini")

# spirits
ggplot(data, aes(y = spirit_units, x = spirwu)) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average units per week") +
  ylab("hseclean average units per week") +
  geom_abline(slope = 1, intercept = 0, colour = 2) +
  ggtitle("Spirits and liqueurs")

# wine
ggplot(data, aes(y = wine_units, x = winewu)) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average units per week") +
  ylab("hseclean average units per week") +
  geom_abline(slope = 1, intercept = 0, colour = 2) +
  ggtitle("Wine")

# alcopops
ggplot(data, aes(y = rtd_units, x = popswu)) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average units per week") +
  ylab("hseclean average units per week") +
  geom_abline(slope = 1, intercept = 0, colour = 2) +
  ggtitle("Alcoholic soft drinks (alcopops)")

ggplot(data, aes(y = weekmean, x = drating )) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average units per week") +
  ylab("hseclean average units per week") +
  geom_abline(slope = 1, intercept = 0, colour = 2) +
  ggtitle("Total consumption - all drink types")




