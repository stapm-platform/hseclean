
# The aim of this code is to check the processing of the Scottish tobacco data
# by producing some key plots
# of tobacco consumption variables and their socio-demographic distribution

library(ggplot2)
library(viridis)
library(cowplot)
library(data.table)
library(hseclean)
library(TTR)

plot_dir <- "vignettes/Scotland_tobacco_data/25_plots"
if(!dir.exists(plot_dir)) {dir.create(plot_dir)}

end_year <- 2019

# Load cleaned and imputed data
data <- readRDS(paste0(dir, "/tob_consumption_scot_national_2008-2019_v1_", Sys.Date(), "_hseclean_", ver, "_imputed.rds"))


data <- data[age >= 16 & age <= 89]

data[, age_cat := c("16-17",
                    "18-24",
                    "25-34",
                    "35-54",
                    "55-89")[findInterval(age, c(-1, 18, 25, 35, 55, 1000))]]

data[ , ageband := c("16-17", "18-24", "25-34", "35-54", "55+")[findInterval(age, c(-1, 18, 25, 35, 55, 1000))]]


###################################################################
# 01 - Distribution of smokers by smoker category

### Overall population

smk_summary <- data[!is.na(cig_smoker_status), .(N = .N), by = c("cig_smoker_status")]
smk_summary[ , prop := N / sum(N)]


# Set order of smoking states
smk_summary[, cig_smoker_status := factor(cig_smoker_status, levels = c("never", "former", "current"))]

p <- ggplot(smk_summary) +
  geom_bar(aes(x = cig_smoker_status, y = prop, fill = cig_smoker_status), stat = "identity") +
  theme_minimal() +
  ylim(0, 1) +
  xlab("Cigarette smoker status") +
  ylab("Proportion") +
  scale_fill_manual(name = "Cigarette\nsmoker status", values = c('#00429d', '#94527e', '#e0655b'))

png(paste0(plot_dir, "/01_smoker_status.png"), units="in", width=7/1.5, height=6/1.5, res=600)
print(p)
dev.off()


### by sex

smk_summary <- data[!is.na(cig_smoker_status), .(N = .N), by = c("cig_smoker_status", "sex")]
smk_summary[ , prop := N / sum(N), by = "sex"]


# Set order of smoking states
smk_summary[, cig_smoker_status := factor(cig_smoker_status, levels = c("never", "former", "current"))]

p <- ggplot(smk_summary) +
  geom_bar(aes(x = cig_smoker_status, y = prop, fill = cig_smoker_status), stat = "identity") +
  theme_minimal() +
  ylim(0, 1) +
  xlab("Cigarette smoker status") +
  facet_wrap(~ sex, nrow = 1) +
  ylab("Proportion") +
  scale_fill_manual(name = "Cigarette\nsmoker status", values = c('#00429d', '#94527e', '#e0655b'))

png(paste0(plot_dir, "/01_smoker_status_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### by IMD quintile

smk_summary <- data[!is.na(cig_smoker_status), .(N = .N), by = c("cig_smoker_status", "imd_quintile")]
smk_summary[ , prop := N / sum(N), by = "imd_quintile"]


# Set order of smoking states
smk_summary[, cig_smoker_status := factor(cig_smoker_status, levels = c("never", "former", "current"))]

p <- ggplot(smk_summary) +
  geom_bar(aes(x = cig_smoker_status, y = prop, fill = cig_smoker_status), stat = "identity") +
  theme_minimal() +
  ylim(0, 1) +
  xlab("Cigarette smoker status") +
  facet_wrap(~ imd_quintile, nrow = 1) +
  ylab("Proportion") +
  scale_fill_manual(name = "Cigarette\nsmoker status", values = c('#00429d', '#94527e', '#e0655b'))

png(paste0(plot_dir, "/01_smoker_status_imd.png"), units="in", width=15/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# calendar year trends in smoking status

smk_summary <- data[!is.na(cig_smoker_status), .(N = .N), by = c("cig_smoker_status", "year")]
smk_summary[ , prop := N / sum(N), by = "year"]


# Set order of smoking states
smk_summary[, cig_smoker_status := factor(cig_smoker_status, levels = c("never", "former", "current"))]

p <- ggplot(smk_summary) +
  geom_line(aes(x = year, y = prop, colour = cig_smoker_status), stat = "identity") +
  theme_minimal() +
  ylim(0, 1) +
  xlim(2007, end_year) +
  xlab("Cigarette smoker status") +
  ylab("Proportion") +
  scale_colour_manual(name = "Cigarette\nsmoker status", values = c('#00429d', '#94527e', '#e0655b'))

png(paste0(plot_dir, "/01_smoker_status_year.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# age trends in smoking status

smk_summary <- data[!is.na(cig_smoker_status), .(N = .N), by = c("cig_smoker_status", "age")]
smk_summary[ , prop := N / sum(N), by = "age"]


# Set order of smoking states
smk_summary[, cig_smoker_status := factor(cig_smoker_status, levels = c("never", "former", "current"))]

p <- ggplot(smk_summary) +
  geom_line(aes(x = age, y = prop, colour = cig_smoker_status), stat = "identity") +
  theme_minimal() +
  ylim(0, 1) +
  xlab("Cigarette smoker status") +
  ylab("Proportion") +
  scale_colour_manual(name = "Cigarette\nsmoker status", values = c('#00429d', '#94527e', '#e0655b'))

png(paste0(plot_dir, "/01_smoker_status_age.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### Distribution of the age started smoking

# overall population

p <- ggplot(data[!is.na(smk_start_age)], aes(smk_start_age )) +
  geom_histogram(binwidth = 1) +
  theme_minimal() +
  xlab("Age started to smoke") +
  ylab("Count")

png(paste0(plot_dir, "/02_smk_start_age.png"), units="in", width=7/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by sex

p <- ggplot(data[!is.na(smk_start_age)], aes(smk_start_age)) +
  geom_histogram(aes(fill = sex), binwidth = 1) +
  theme_minimal() +
  facet_wrap(~ sex, nrow = 1) +
  xlab("Age started to smoke") +
  ylab("Count") +
  scale_fill_manual(name = "Sex", values = c("#6600cc", "#00cc99")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/02_smk_start_age_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by imd quintile

p <- ggplot(data[!is.na(smk_start_age)], aes(smk_start_age)) +
  geom_histogram(aes(fill = imd_quintile), binwidth = 1) +
  theme_minimal() +
  facet_wrap(~ imd_quintile, nrow = 1) +
  xlab("Age started to smoke") +
  ylab("Count") +
  scale_fill_manual(name = "IMD quintile", labels = c("1 (least deprived)", "2", "3", "4", "5 (most deprived)"), values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/02_smk_start_age_imd.png"), units="in", width=15/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### Distribution of the number of cigarettes smoked by current smokers

# overall population

p <- ggplot(data[cigs_per_day > 0], aes(cigs_per_day)) +
  geom_histogram(binwidth = 1) +
  theme_minimal() +
  xlab("Cigarettes per day") +
  ylab("Count")

png(paste0(plot_dir, "/03_cigs_per_day.png"), units="in", width=7/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by sex

p <- ggplot(data[cigs_per_day > 0], aes(cigs_per_day)) +
  geom_histogram(aes(fill = sex), binwidth = 1) +
  theme_minimal() +
  facet_wrap(~ sex, nrow = 1) +
  xlab("Cigarettes per day") +
  ylab("Count") +
  scale_fill_manual(name = "Sex", values = c("#6600cc", "#00cc99")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/03_cigs_per_day_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by imd quintile

p <- ggplot(data[cigs_per_day > 0], aes(cigs_per_day)) +
  geom_histogram(aes(fill = imd_quintile), binwidth = 1) +
  theme_minimal() +
  facet_wrap(~ imd_quintile, nrow = 1) +
  xlab("Cigarettes per day") +
  ylab("Count") +
  scale_fill_manual(name = "IMD quintile", labels = c("1 (least deprived)", "2", "3", "4", "5 (most deprived)"), values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/03_cigs_per_day_imd.png"), units="in", width=15/1.5, height=6/1.5, res=600)
print(p)
dev.off()


### Distribution of the number of years since quitting in former smokers

# overall population

p <- ggplot(data[years_since_quit > 0], aes(years_since_quit)) +
  geom_histogram(binwidth = 1) +
  theme_minimal() +
  xlab("Years since quitting") +
  ylab("Count")

png(paste0(plot_dir, "/04_years_since_quitting.png"), units="in", width=7/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by sex

p <- ggplot(data[years_since_quit > 0], aes(years_since_quit)) +
  geom_histogram(aes(fill = sex), binwidth = 1) +
  theme_minimal() +
  facet_wrap(~ sex, nrow = 1) +
  xlab("Years since quitting") +
  ylab("Count") +
  scale_fill_manual(name = "Sex", values = c("#6600cc", "#00cc99")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/04_years_since_quitting_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by imd quintile

p <- ggplot(data[years_since_quit > 0], aes(years_since_quit)) +
  geom_histogram(aes(fill = imd_quintile), binwidth = 1) +
  theme_minimal() +
  facet_wrap(~ imd_quintile, nrow = 1) +
  xlab("Years since quitting") +
  ylab("Count") +
  scale_fill_manual(name = "IMD quintile", labels = c("1 (least deprived)", "2", "3", "4", "5 (most deprived)"), values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/04_years_since_quitting_imd.png"), units="in", width=15/1.5, height=6/1.5, res=600)
print(p)
dev.off()












