
# The aim of this code is to check the results of applying upshifting
# to adjust average weekly alcohol consumption for under-reporting in Scotland

library(hseclean)
library(data.table)
library(magrittr)
library(ggplot2)
library(dplyr)

?alc_upshift

# Create plot directory if it doesn't exist
plot_dir <- "vignettes/Alcohol_upshifting/plots"
if(!dir.exists(plot_dir)) {dir.create(plot_dir)}

#### Scotland

# Location of Scottish data
root_dir <- "X:/HAR_PR/PR/Consumption_TA/HSE/Scottish Health Survey (SHeS)/"


# QA check plots for the distribution of average weekly alcohol consumption (UK standard units) in Scotland for the years 2015 - 2019.


# 2019
data <- read_SHeS_2019(root = root_dir) %>%
  clean_age %>% clean_demographic %>%
  alc_drink_now_allages %>%
  alc_weekmean_adult %>%
  select_data(ages = 16:89, years = 2019,
              keep_vars = c("wt_int", "year", "age", "sex", "weekmean"),
              complete_vars = c("wt_int", "sex", "weekmean"))


data <- alc_upshift(data, country = "Scotland",
                    year_select = 2019,
                    pcc_data = "MESAS",
                    proportion = 0.8)



# Plot of the SHeS data version of average weekly alcohol consumption compared to the upshifted version
# (Average weekly alcohol consumption in UK standard units of ethanol)

# side by side

png(paste0(plot_dir, "/drink_amount_histograms_2019.png"), units="in", width=10/1.5, height=5/1.5, res=600)

par(
  mfrow=c(1,2),
  mar=c(4,4,1,0)
)


hist_weekmean <- hist(data$weekmean,
                      xlim = c(0, 100),
                      ylim = c(0, 2750),
                      breaks =100,
                      col="lightblue",
                      xlab="SHeS average units per week",
                      main = "Before")
abline(v = mean(data$weekmean), lwd=3, lty=2)
text(40, 1500, "Mean weekly \n consumption = 10.12 units",
     cex = 0.6)


hist_adj <- hist(data$weekmean_adj,
                 xlim = c(0, 100),
                 ylim = c(0, 2750),
                 breaks = 100,
                 col="thistle",
                 xlab="Adjusted average units per week",
                 main = "After")

abline(v = mean(data$weekmean_adj), lwd=3, lty=2)
text(45, 1500, "Mean weekly \n consumption = 14.88 units",
     cex = 0.6)


dev.off()


# Together
# Barplot of standardised distribution of alcohol consumption before and after upshifting


# Consumption bands

data[, weekmean_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]

data[, weekmean_adj_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean_adj, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]


# sum population weighted consumption in each band (sum weights)
# and standardise the sum of weights to equal 1

# SHeS estimate
data_2 <- data %>%
  group_by(weekmean_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_2$Estimate <- "Before"

X <- 1 / sum(data_2$sum_wt)
data_2$prop <- data_2$sum_wt * X


# Adjusted estimate
data_3 <- data %>%
  group_by(weekmean_adj_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_3$Estimate <- "After"

X <- 1 / sum(data_3$sum_wt)
data_3$prop <- data_3$sum_wt * X

names(data_3)[names(data_3) == "weekmean_adj_cat"] <- "weekmean_cat"


# join
data_2 <- rbind(data_2, data_3)

# refactor to keep order on x axis
data_2$weekmean_cat <- factor(data_2$weekmean_cat, levels=c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +"))

data_2$Estimate <- factor(data_2$Estimate, levels=c("Before", "After"))

p <- ggplot(data_2) +
  geom_col(aes(x = weekmean_cat, y = prop, fill = Estimate),
           position = "dodge") +
  scale_fill_manual(values = (c("lightblue", "thistle"))) +
  xlab("Average units per week") +
  ylab("Proportion") +
  ggtitle("Average units per week before and after upshifting: 2019") +
  theme_minimal()

png(paste0(plot_dir, "/drink_amount_barplot_2019.png"), units="in", width=10/1.5, height=5/1.5, res=600)
print(p)
dev.off()




# 2018
data <- read_SHeS_2018(root = root_dir) %>%
  clean_age %>% clean_demographic %>%
  alc_drink_now_allages %>%
  alc_weekmean_adult %>%
  select_data(ages = 16:89, years = 2018,
              keep_vars = c("wt_int", "year", "age", "sex", "weekmean"),
              complete_vars = c("wt_int", "sex", "weekmean"))

data <- alc_upshift(data, country = "Scotland",
                    year_select = 2018,
                    pcc_data = "MESAS",
                    proportion = 0.8)


# Plot of the SHeS data version of average weekly alcohol consumption compared to the upshifted version
# side by side

png(paste0(plot_dir, "/drink_amount_histograms_2018.png"), units="in", width=10/1.5, height=5/1.5, res=600)

par(
  mfrow=c(1,2),
  mar=c(4,4,1,0)
)

hist_weekmean <- hist(data$weekmean,
                      xlim = c(0, 100),
                      ylim = c(0, 2750),
                      breaks =100,
                      col="lightblue",
                      xlab="SHeS average units per week",
                      main = "Before")
abline(v = mean(data$weekmean), lwd=3, lty=2)
text(40, 1500, "Mean weekly \n consumption = 10.18 units",
     cex = 0.6)


hist_adj <- hist(data$weekmean_adj,
                 xlim = c(0, 100),
                 ylim = c(0, 2750),
                 breaks = 100,
                 col="thistle",
                 xlab="Adjusted average units per week",
                 main = "After")

abline(v = mean(data$weekmean_adj), lwd=3, lty=2)
text(45, 1500, "Mean weekly \n consumption = 14.49 units",
     cex = 0.6)

dev.off()


# Together
# Barplot of standardised distribution of alcohol consumption before and after upshifting


# Consumption bands

data[, weekmean_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]

data[, weekmean_adj_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean_adj, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]


# sum population weighted consumption in each band (sum weights)
# and standardise the sum of weights to equal 1

# SHeS estimate
data_2 <- data %>%
  group_by(weekmean_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_2$Estimate <- "Before"

X <- 1 / sum(data_2$sum_wt)
data_2$prop <- data_2$sum_wt * X


# Adjusted estimate
data_3 <- data %>%
  group_by(weekmean_adj_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_3$Estimate <- "After"

X <- 1 / sum(data_3$sum_wt)
data_3$prop <- data_3$sum_wt * X

names(data_3)[names(data_3) == "weekmean_adj_cat"] <- "weekmean_cat"


# join
data_2 <- rbind(data_2, data_3)

# refactor to keep order on x axis
data_2$weekmean_cat <- factor(data_2$weekmean_cat, levels=c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +"))

data_2$Estimate <- factor(data_2$Estimate, levels=c("Before", "After"))

p <- ggplot(data_2) +
  geom_col(aes(x = weekmean_cat, y = prop, fill = Estimate),
           position = "dodge") +
  scale_fill_manual(values = (c("lightblue", "thistle"))) +
  xlab("Average units per week") +
  ylab("Proportion") +
  ggtitle("Average units per week before and after upshifting: 2018") +
  theme_minimal()

png(paste0(plot_dir, "/drink_amount_barplot_2018.png"), units="in", width=10/1.5, height=5/1.5, res=600)
print(p)
dev.off()


# 2017
data <- read_SHeS_2017(root = root_dir) %>%
  clean_age %>% clean_demographic %>%
  alc_drink_now_allages %>%
  alc_weekmean_adult %>%
  select_data(ages = 16:89, years = 2017,
              keep_vars = c("wt_int", "year", "age", "sex", "weekmean"),
              complete_vars = c("wt_int", "sex", "weekmean"))


data <- alc_upshift(data, country = "Scotland",
                    year_select = 2017,
                    pcc_data = "MESAS",
                    proportion = 0.8)


# Plot of the SHeS data version of average weekly alcohol consumption compared to the upshifted version
# side by side

png(paste0(plot_dir, "/drink_amount_histograms_2017.png"), units="in", width=10/1.5, height=5/1.5, res=600)

par(
  mfrow=c(1,2),
  mar=c(4,4,1,0)
)

hist_weekmean <- hist(data$weekmean,
                      xlim = c(0, 100),
                      ylim = c(0, 2750),
                      breaks =100,
                      col="lightblue",
                      xlab="SHeS average units per week",
                      main = "Before")
abline(v = mean(data$weekmean), lwd=3, lty=2)
text(40, 1500, "Mean weekly \n consumption = 10.60 units",
     cex = 0.6)


hist_adj <- hist(data$weekmean_adj,
                 xlim = c(0, 100),
                 ylim = c(0, 2750),
                 breaks = 100,
                 col="thistle",
                 xlab="Adjusted average units per week",
                 main = "After")

abline(v = mean(data$weekmean_adj), lwd=3, lty=2)
text(45, 1500, "Mean weekly \n consumption = 15.40 units",
     cex = 0.6)

dev.off()


# Together
# Barplot of standardised distribution of alcohol consumption before and after upshifting


# Consumption bands

data[, weekmean_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]

data[, weekmean_adj_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean_adj, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]


# sum population weighted consumption in each band (sum weights)
# and standardise the sum of weights to equal 1

# SHeS estimate
data_2 <- data %>%
  group_by(weekmean_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_2$Estimate <- "Before"

X <- 1 / sum(data_2$sum_wt)
data_2$prop <- data_2$sum_wt * X


# Adjusted estimate
data_3 <- data %>%
  group_by(weekmean_adj_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_3$Estimate <- "After"

X <- 1 / sum(data_3$sum_wt)
data_3$prop <- data_3$sum_wt * X

names(data_3)[names(data_3) == "weekmean_adj_cat"] <- "weekmean_cat"


# join
data_2 <- rbind(data_2, data_3)

# refactor to keep order on x axis
data_2$weekmean_cat <- factor(data_2$weekmean_cat, levels=c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +"))

data_2$Estimate <- factor(data_2$Estimate, levels=c("Before", "After"))

p <- ggplot(data_2) +
  geom_col(aes(x = weekmean_cat, y = prop, fill = Estimate),
           position = "dodge") +
  scale_fill_manual(values = (c("lightblue", "thistle"))) +
  xlab("Average units per week") +
  ylab("Proportion") +
  ggtitle("Average units per week before and after upshifting: 2017") +
  theme_minimal()

png(paste0(plot_dir, "/drink_amount_barplot_2017.png"), units="in", width=10/1.5, height=5/1.5, res=600)
print(p)
dev.off()


# 2016
data <- read_SHeS_2016(root = root_dir) %>%
  clean_age %>% clean_demographic %>%
  alc_drink_now_allages %>%
  alc_weekmean_adult %>%
  select_data(ages = 16:89, years = 2016,
              keep_vars = c("wt_int", "year", "age", "sex", "weekmean"),
              complete_vars = c("wt_int", "sex", "weekmean"))


data <- alc_upshift(data, country = "Scotland",
                    year_select = 2016,
                    pcc_data = "MESAS",
                    proportion = 0.8)


# Plot of the SHeS data version of average weekly alcohol consumption compared to the upshifted version
# side by side

png(paste0(plot_dir, "/drink_amount_histograms_2016.png"), units="in", width=10/1.5, height=5/1.5, res=600)

par(
  mfrow=c(1,2),
  mar=c(4,4,1,0)
)

hist_weekmean <- hist(data$weekmean,
                      xlim = c(0, 100),
                      ylim = c(0, 2750),
                      breaks =100,
                      col="lightblue",
                      xlab="SHeS average units per week",
                      main = "Before")
abline(v = mean(data$weekmean), lwd=3, lty=2)
text(40, 1500, "Mean weekly \n consumption = 10.53 units",
     cex = 0.6)


hist_adj <- hist(data$weekmean_adj,
                 xlim = c(0, 100),
                 ylim = c(0, 2750),
                 breaks = 100,
                 col="thistle",
                 xlab="Adjusted average units per week",
                 main = "After")

abline(v = mean(data$weekmean_adj), lwd=3, lty=2)
text(45, 1500, "Mean weekly \n consumption = 14.58 units",
     cex = 0.6)

dev.off()


# Together
# Barplot of standardised distribution of alcohol consumption before and after upshifting


# Consumption bands

data[, weekmean_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]

data[, weekmean_adj_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean_adj, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]


# sum population weighted consumption in each band (sum weights)
# and standardise the sum of weights to equal 1

# SHeS estimate
data_2 <- data %>%
  group_by(weekmean_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_2$Estimate <- "Before"

X <- 1 / sum(data_2$sum_wt)
data_2$prop <- data_2$sum_wt * X


# Adjusted estimate
data_3 <- data %>%
  group_by(weekmean_adj_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_3$Estimate <- "After"

X <- 1 / sum(data_3$sum_wt)
data_3$prop <- data_3$sum_wt * X

names(data_3)[names(data_3) == "weekmean_adj_cat"] <- "weekmean_cat"


# join
data_2 <- rbind(data_2, data_3)

# refactor to keep order on x axis
data_2$weekmean_cat <- factor(data_2$weekmean_cat, levels=c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +"))

data_2$Estimate <- factor(data_2$Estimate, levels=c("Before", "After"))

p <- ggplot(data_2) +
  geom_col(aes(x = weekmean_cat, y = prop, fill = Estimate),
           position = "dodge") +
  scale_fill_manual(values = (c("lightblue", "thistle"))) +
  xlab("Average units per week") +
  ylab("Proportion") +
  ggtitle("Average units per week before and after upshifting: 2016") +
  theme_minimal()

png(paste0(plot_dir, "/drink_amount_barplot_2016.png"), units="in", width=10/1.5, height=5/1.5, res=600)
print(p)
dev.off()


# 2015
data <- read_SHeS_2015(root = root_dir) %>%
  clean_age %>% clean_demographic %>%
  alc_drink_now_allages %>%
  alc_weekmean_adult %>%
  select_data(ages = 16:89, years = 2015,
              keep_vars = c("wt_int", "year", "age", "sex", "weekmean"),
              complete_vars = c("wt_int", "sex", "weekmean"))


data <- alc_upshift(data, country = "Scotland",
                    year_select = 2015,
                    pcc_data = "MESAS",
                    proportion = 0.8)

# Plot of the SHeS data version of average weekly alcohol consumption compared to the upshifted version
# side by side

png(paste0(plot_dir, "/drink_amount_histograms_2015.png"), units="in", width=10/1.5, height=5/1.5, res=600)

par(
  mfrow=c(1,2),
  mar=c(4,4,1,0)
)

hist_weekmean <- hist(data$weekmean,
                      xlim = c(0, 100),
                      ylim = c(0, 2750),
                      breaks =100,
                      col="lightblue",
                      xlab="SHeS average units per week",
                      main = "Before")
abline(v = mean(data$weekmean), lwd=3, lty=2)
text(40, 1500, "Mean weekly \n consumption = 11.22 units",
     cex = 0.6)


hist_adj <- hist(data$weekmean_adj,
                 xlim = c(0, 100),
                 ylim = c(0, 2750),
                 breaks = 100,
                 col="thistle",
                 xlab="Adjusted average units per week",
                 main = "After")

abline(v = mean(data$weekmean_adj), lwd=3, lty=2)
text(45, 1500, "Mean weekly \n consumption = 15.26 units",
     cex = 0.6)

dev.off()


# Together
# Barplot of standardised distribution of alcohol consumption before and after upshifting


# Consumption bands

data[, weekmean_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]

data[, weekmean_adj_cat := c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +")
     [findInterval(weekmean_adj, c(-1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))]]


# sum population weighted consumption in each band (sum weights)
# and standardise the sum of weights to equal 1

# SHeS estimate
data_2 <- data %>%
  group_by(weekmean_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_2$Estimate <- "Before"

X <- 1 / sum(data_2$sum_wt)
data_2$prop <- data_2$sum_wt * X


# Adjusted estimate
data_3 <- data %>%
  group_by(weekmean_adj_cat) %>%
  summarise(sum_wt = sum(wt_int))

data_3$Estimate <- "After"

X <- 1 / sum(data_3$sum_wt)
data_3$prop <- data_3$sum_wt * X

names(data_3)[names(data_3) == "weekmean_adj_cat"] <- "weekmean_cat"


# join
data_2 <- rbind(data_2, data_3)

# refactor to keep order on x axis
data_2$weekmean_cat <- factor(data_2$weekmean_cat, levels=c("0-9", "10-19", "20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90-99", "100 +"))

data_2$Estimate <- factor(data_2$Estimate, levels=c("Before", "After"))

p <- ggplot(data_2) +
  geom_col(aes(x = weekmean_cat, y = prop, fill = Estimate),
           position = "dodge") +
  scale_fill_manual(values = (c("lightblue", "thistle"))) +
  xlab("Average units per week") +
  ylab("Proportion") +
  ggtitle("Average units per week before and after upshifting: 2015") +
  theme_minimal()

png(paste0(plot_dir, "/drink_amount_barplot_2015.png"), units="in", width=10/1.5, height=5/1.5, res=600)
print(p)
dev.off()



