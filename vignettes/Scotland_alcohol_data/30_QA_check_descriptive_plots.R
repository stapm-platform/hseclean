
# The aim of this code is to check the processing of the Scottish alcohol data
# by producing some key plots
# of alcohol consumption variables and their socio-demographic distribution

library(ggplot2)
library(viridis)
library(cowplot)
library(data.table)
library(hseclean)
library(TTR)

plot_dir <- "data-checks/Scotland_alcohol_data/25_plots"
if(!dir.exists(plot_dir)) {dir.create(plot_dir)}

end_year <- 2019

# Load cleaned and imputed data
data <- readRDS(paste0(dir, "/alc_consumption_scot_national_2008-2019_v1_", Sys.Date(), "_hseclean_", ver, "_imputed.rds"))

# Select ages
data <- data[age >= 16 & age <= 89]

data[, age_cat := c("16-17",
                    "18-24",
                    "25-34",
                    "35-54",
                    "55-89")[findInterval(age, c(-1, 18, 25, 35, 55, 1000))]]

data[ , ageband := c("16-17", "18-24", "25-34", "35-54", "55+")[findInterval(age, c(-1, 18, 25, 35, 55, 1000))]]


###################################################################
# 01 - Distribution of average weekly alcohol consumption

### Overall population

p <- ggplot(data[weekmean < 100], aes(weekmean)) +
  geom_histogram(binwidth = 1) +
  theme_minimal() +
  xlab("Average units per week") +
  ylab("Count")

png(paste0(plot_dir, "/01_drink_amount.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By IMD quintile
p <- ggplot(data[weekmean < 100], aes(weekmean)) +
  geom_histogram(binwidth = 1, aes(fill = imd_quintile)) +
  theme_minimal() +
  facet_wrap(~ imd_quintile, nrow = 1) +
  xlab("Average units per week") +
  ylab("Count") +
  scale_fill_manual(name = "IMD quintile", labels = c("1 (least deprived)", "2", "3", "4", "5 (most deprived)"), values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/01_drink_amount_imd.png"), units="in", width=10/1.5, height=5/1.5, res=600)
print(p)
dev.off()

### By sex
p <- ggplot(data[weekmean < 100], aes(weekmean)) +
  geom_histogram(binwidth = 1, aes(fill = sex)) +
  theme_minimal() +
  facet_wrap(~ sex, nrow = 1) +
  xlab("Average units per week") +
  ylab("Count") +
  scale_fill_manual(name = "Sex", values = c("#6600cc", "#00cc99")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/01_drink_amount_sex.png"), units="in", width=10/1.5, height=5/1.5, res=600)
print(p)
dev.off()


# Plot of the hseclean version of average weekly alcohol consumption compared to the version provided with the SHeS data (based on different assumptions)

p <- ggplot(data, aes(x = drating, y = weekmean)) +
  geom_point(alpha = 0.2) +
  theme_minimal() +
  coord_equal() +
  xlab("SHeS average units per week") +
  ylab("hseclean average units per week") +
  geom_abline(slope = 1, intercept = 0, colour = 2)

png(paste0(plot_dir, "/01_drink_amount_shes_vs_hseclean.png"), units="in", width=6/1.5, height=6/1.5, res=600)
print(p)
dev.off()

###################################################################

# 02 - Calendar year trend in the proportion of people who consume alcohol for

# create a binary variable for drinks now or not
data[drinks_now == "drinker", drink_bin := 1]
data[drinks_now == "non_drinker", drink_bin := 0]

# summarise that to show the proportion of drinkers in each calendar year
drink_summary <- data[ , .(drink_prop = mean(drink_bin, na.rm = T)), by = c("year")]
#drink_summary <- data[ , .(drink_prop = mean(drink_bin, na.rm = T)), by = c("year",
                                                                            #"age",
                                                                            #"sex",
                                                                            #"imd_quintile")]
### By population
p <- ggplot(drink_summary) +
  geom_line(aes(x = year, y = drink_prop)) +
  theme_minimal() +
  xlab("Year") + xlim(2007, end_year) +
  ylim(0, 1) +
  ylab("Proportion of people who drink alcohol")

png(paste0(plot_dir, "/02_drink_prop.png"), units="in", width=6/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By sex
drink_summary_sex <- data[ , .(drink_prop = mean(drink_bin, na.rm = T)), by = c("year", "sex")]

p <- ggplot(drink_summary_sex, aes(x = year)) +
  geom_line(aes(y = drink_prop, color = sex)) +
  xlim(2007, end_year) +
  ylim(0, 1) +
  xlab("Year") +
  ylab("Proportion of people who drink alcohol") +
  theme_minimal() +
  scale_color_manual(name = "Sex", values = c("#6600cc", "#00cc99"))# +
  #theme(legend.position = "top"#,
        #legend.key.size = unit(0.5/5, 'in'),
        #legend.title = element_text(size = 8),
        #legend.text = element_text(size = 6)
  #)

png(paste0(plot_dir, "/02_drink_prop_sex.png"), units="in", width=8/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By IMD quintile
drink_summary_imd <- data[ , .(drink_prop = mean(drink_bin, na.rm = T)), by = c("year", "imd_quintile")]

p <- ggplot(drink_summary_imd, aes(x = year)) +
  geom_line(aes(y = drink_prop, color = imd_quintile)) +
  theme_minimal() +
  xlim(2007, end_year) +
  ylim(0, 1) +
  xlab("Year") +
  ylab("Proportion of people who drink alcohol") +
  scale_color_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))# +
  #theme(legend.position = "top"#,
        #legend.key.size = unit(0.5/5, 'in'),
        #legend.title = element_text(size = 8),
        #legend.text = element_text(size = 6)
  #)

png(paste0(plot_dir, "/02_drink_prop_imd.png"), units="in", width=8.5/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# facet version
#p <- ggplot(drink_summary_imd) +
#  geom_line(aes(x = year, y = drink_prop)) +
#  facet_wrap(~ imd_quintile, nrow = 1) +
#  theme_minimal() +
#  scale_color_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))

##########################################################
# 03 - Calendar year trend in average weekly alcohol consumption by people who consume alcohol for
#(a) the overall population aged 16 to 89 years,

### By population
weekconsump_summary <- data[drinker_cat != "Abstainer", .(week_mean = mean(weekmean, na.rm = T)), by = c("year")]

p <- ggplot(weekconsump_summary) +
  geom_line(aes(x = year, y = week_mean)) +
  xlim(2007, end_year) +
  ylim(0, 25) +
  theme_minimal() +
  xlab("Year") +
  ylab("Average units per week consumed by drinkers")

png(paste0(plot_dir, "/03_weekdrnk.png"), units="in", width=6/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By sex
weekconsump_summary_sex <- data[drinker_cat != "Abstainer", .(week_mean = mean(weekmean, na.rm = T)), by = c("year", "sex")]

p <- ggplot(weekconsump_summary_sex, aes(x = year)) +
  geom_line(aes(y = week_mean, color = sex)) +
  xlim(2007, end_year) +
  ylim(0, 25) +
  theme_minimal() +
  xlab("Year") +
  ylab("Average units per week consumed by drinkers") +
  scale_colour_manual(name = "Sex", values = c("#6600cc", "#00cc99")) #+
  # theme(legend.position = "top",
  #       legend.key.size = unit(0.5/5, 'in'),
  #       legend.title = element_text(size = 8),
  #       legend.text = element_text(size = 6)
  # )

png(paste0(plot_dir, "/03_weekdrnk_sex.png"), units="in", width=8/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By IMD quintile
weekconsump_summary_imd <- data[drinker_cat != "Abstainer", .(week_mean = mean(weekmean, na.rm = T)), by = c("year", "imd_quintile")]

p <- ggplot(weekconsump_summary_imd, aes(x = year)) +
  geom_line(aes(y = week_mean, color = imd_quintile)) +
  xlim(2007, end_year) +
  ylim(0, 25) +
  theme_minimal() +
  xlab("Year") +
  ylab("Average units per week consumed by drinkers") +
  scale_color_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))# +
  #theme(
    #legend.position = c(1, 1),
    #legend.justification = c(1, 1),
   # legend.key.size = unit(0.5/5, 'in')
  #) +
  # theme(legend.position = "top",
  #       legend.key.size = unit(0.5/5, 'in'),
  #       legend.title = element_text(size = 8),
  #       legend.text = element_text(size = 6)
  # )


png(paste0(plot_dir, "/03_weekdrnk_imd.png"), units="in", width=8.5/1.5, height=6/1.5, res=600)
print(p)
dev.off()

##########################################################
# 04 - Age trend in the proportion of people who consume alcohol for
#(a) the overall population aged 16 to 89 years,

### By population (age bands)
drnk_summary <- data[ , .N, by = c("drinker_cat", "ageband")]
drnk_summary[ , prop := N / sum(N), by = "ageband"]
drnk_summary[ , drinker_cat := factor(drinker_cat, levels = c("Abstainer", "Lower risk", "Increasing risk", "Higher risk"))]

p <- ggplot(drnk_summary) +
  geom_bar(aes(x = ageband, y = prop, fill = drinker_cat), position = "dodge", stat = "identity") +
  theme_minimal() +
  xlab("Sex") +
  ylab("Proportion") +
  scale_fill_manual(name = "Drinker\ncategory", values = c('#ceeab0', '#92d050', '#ffc000', '#c00000'))

png(paste0(plot_dir, "/04_drinkerplot_age.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By population (age flow) - look into splitting this into categories
agedrink_summary <- data[ , .(drink_prop = mean(drink_bin, na.rm = T)), by = c("age")]

p <- ggplot(agedrink_summary) +
  geom_line(aes(x = age, y = drink_prop)) +
  theme_minimal() +
  xlab("Age") +
  ylim(0, 1) +
  ylab("Proportion of the population who drink alcohol") +
  scale_x_continuous(breaks = seq(15, 90, 10))

png(paste0(plot_dir, "/04_agetrend_prop.png"), units="in", width=6/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By sex
agedrink_summary_sex <- data[ , .(drink_prop = mean(drink_bin, na.rm = T)), by = c("age","sex")]

p <- ggplot(agedrink_summary_sex, aes(x = age)) +
  geom_line(aes(y = drink_prop, color = sex)) +
  theme_minimal() +
  xlab("Age") +
  ylim(0, 1) +
  ylab("Proportion of the population who drink alcohol") +
  scale_x_continuous(breaks = seq(15, 90, 10)) +
  scale_colour_manual(name = "Sex", values = c("#6600cc", "#00cc99"))# +
  # theme(legend.position = "top",
  #       legend.key.size = unit(0.5/5, 'in'),
  #       legend.title = element_text(size = 8),
  #       legend.text = element_text(size = 6)
  # )

png(paste0(plot_dir, "/04_agetrend_prop_sex.png"), units="in", width=8/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By IMD quintile
agedrink_summary_imd <- data[ , .(drink_prop = mean(drink_bin, na.rm = T)), by = c("age","imd_quintile")]

p <- ggplot(agedrink_summary_imd, aes(x = age)) +
  geom_line(aes(y = drink_prop, color = imd_quintile)) +
  theme_minimal() +
  xlab("Age") +
  ylim(0, 1) +
  ylab("Proportion of the population who drink alcohol") +
  scale_x_continuous(breaks = seq(15, 90, 10)) +
  scale_color_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) #+
  # theme(legend.position = "top",
  #       legend.key.size = unit(0.5/5, 'in'),
  #       legend.title = element_text(size = 8),
  #       legend.text = element_text(size = 6)
  # )

png(paste0(plot_dir, "/04_agetrend_prop_imd.png"), units="in", width=8.5/1.5, height=6/1.5, res=600)
print(p)
dev.off()


##########################################################
# 05 - Age trend in average weekly alcohol consumption for
#(a) the overall population aged 16 to 89 years,

# SELF ADJUSTED FOR DRINKERS ONLY

### By population (age flow)
agemean_summary <- data[drinker_cat != "Abstainer", .(week_mean = mean(weekmean, na.rm = T)), by = c("age")]

p <- ggplot(agemean_summary) +
  geom_line(aes(x = age, y = week_mean)) +
  xlab("Age") +
  ylim(0, 25) +
  theme_minimal() +
  ylab("Average units per week consumed by drinkers") +
  scale_x_continuous(breaks = seq(15, 90, 10))

png(paste0(plot_dir, "/05_agetrend_mean.png"), units="in", width=6/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By sex
agemean_summary_sex <- data[drinker_cat != "Abstainer", .(week_mean = mean(weekmean, na.rm = T)), by = c("age","sex")]

p <- ggplot(agemean_summary_sex, aes(x = age)) +
  geom_line(aes(y = week_mean, color = sex)) +
  xlab("Age") +
  ylim(0, 25) +
  theme_minimal() +
  ylab("Average units per week consumed by drinkers") +
  scale_x_continuous(breaks = seq(15, 90, 10)) +
  scale_colour_manual(name = "Sex", values = c("#6600cc", "#00cc99")) #+
  # theme(legend.position = "top",
  #       legend.key.size = unit(0.5/5, 'in'),
  #       legend.title = element_text(size = 8),
  #       legend.text = element_text(size = 6)
  # )

png(paste0(plot_dir, "/05_agetrend_mean_sex.png"), units="in", width=8/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By IMD quintile
agemean_summary_imd <- data[drinker_cat != "Abstainer", .(week_mean = mean(weekmean, na.rm = T)), by = c("age","imd_quintile")]

p <- ggplot(agemean_summary_imd, aes(x = age)) +
  geom_line(aes(y = week_mean, color = imd_quintile)) +
  theme_minimal() +
  xlab("Age") +
  ylim(0, 25) +
  theme_minimal() +
  ylab("Average units per week consumed by drinkers") +
  scale_x_continuous(breaks = seq(15, 90, 10)) +
  scale_color_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) #+
  # theme(legend.position = "top",
  #       legend.key.size = unit(0.5/5, 'in'),
  #       legend.title = element_text(size = 8),
  #       legend.text = element_text(size = 6)
  # )

png(paste0(plot_dir, "/05_agetrend_mean_imd.png"), units="in", width=8.5/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By sex and IMD quintile (have not tested error bar ~ryan)

#drink_summary <- data[drinker_cat != "Abstainer"]

#drnkunits <- drink_summary[ , .(weekmean_mu = mean(weekmean, na.rm = T),
#                                se = sqrt(var(weekmean, na.rm = T) / .N),
#                                n_drinkers = .N), by = c("age", "imd_quintile", "sex")]

#p <- ggplot(drnkunits) +
  ##geom_point(aes(x = age, y = weekmean_mu, colour = imd_quintile), size = .4, alpha = .7) +
  ##geom_errorbar(aes(x = age, ymin = weekmean_mu - (1.96 * se), ymax = weekmean_mu + (1.96 * se), colour = imd_quintile), width = 0, size = .7) +
#  geom_line(aes(x = age, y = weekmean_mu, colour = imd_quintile), linewidth = .4) +
#  facet_wrap(~ sex + imd_quintile, nrow = 2) +
#  ylab("units / week") +
#  theme_minimal() +
#  scale_colour_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))

#png("25_plots/05_drink_amount_agetrend.png", units="in", width=10/1.5, height=6/1.5, res=600)
#print(p)
#dev.off()

##########################################################
# 06 - Distribution of preferences among beer, spirits, wine and alcopops for
#(a) the overall population aged 16 to 89 years,


### By population
drinkcat_mean_summary <- data[ , .(
  Beer = sum(beer_units > 0) / length(beer_units),
  Wine = sum(wine_units > 0) / length(wine_units),
  Spirits = sum(spirit_units > 0) / length(spirit_units),
  Alcopops = sum(rtd_units > 0) / length(rtd_units)
)]

drinkcat_mean_summary <- melt(drinkcat_mean_summary, variable.name = "Product", value.name = "prop")

p <- ggplot(drinkcat_mean_summary) +
  geom_bar(aes(x = Product, y = prop, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  ylab("Proportion of people") +
  xlab("Product") +
  ylim(0, 1) +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000"))

png(paste0(plot_dir, "/06_drink_prefs.png"), units="in", width=8.5/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By sex
drinkcat_mean_summary_sex <- data[ , .(
  Beer = sum(beer_units > 0) / length(beer_units),
  Wine = sum(wine_units > 0) / length(wine_units),
  Spirits = sum(spirit_units > 0) / length(spirit_units),
  Alcopops = sum(rtd_units > 0) / length(rtd_units)
),
by = c("sex")]

drinkcat_mean_summary_sex <- melt(drinkcat_mean_summary_sex, variable.name = "Product", value.name = "prop")

p <- ggplot(drinkcat_mean_summary_sex) +
  geom_bar(aes(x = Product, y = prop, fill = Product), stat = "identity", position = "dodge") +
  facet_wrap(~ sex, nrow =) +
  theme_minimal() +
  ylab("Proportion of people") +
  xlab("Product") +
  ylim(0, 1) +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000"))

png(paste0(plot_dir, "/06_drink_prefs_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

### By IMD quintile
drinkcat_mean_summary_imd <- data[ , .(
  Beer = sum(beer_units > 0) / length(beer_units),
  Wine = sum(wine_units > 0) / length(wine_units),
  Spirits = sum(spirit_units > 0) / length(spirit_units),
  Alcopops = sum(rtd_units > 0) / length(rtd_units)
),
by = c("imd_quintile")]

drinkcat_mean_summary_imd <- melt(drinkcat_mean_summary_imd, variable.name = "Product", value.name = "prop")

p <- ggplot(drinkcat_mean_summary_imd) +
  geom_bar(aes(x = Product, y = prop, fill = Product), stat = "identity", position = "dodge") +
  facet_wrap(~ imd_quintile, nrow = 1) +
  theme_minimal() +
  ylab("Proportion of people") +
  xlab("Product") +
  ylim(0, 1) +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000"))

png(paste0(plot_dir, "/06_drink_prefs_imd.png"), units="in", width=20/1.5, height=6/1.5, res=600)
print(p)
dev.off()


##########################################################
# 07 - Calendar year trend in the distribution of preferences among beer, spirits, wine and alcopops for the overall population aged 16 to 89 years

### By year
drinkcat_meantrend_summary <- data[ , .(
  Beer = sum(beer_units > 0) / length(beer_units),
  Wine = sum(wine_units > 0) / length(wine_units),
  Spirits = sum(spirit_units > 0) / length(spirit_units),
  Alcopops = sum(rtd_units > 0) / length(rtd_units)
),
by = c("year")]

drinkcat_meantrend_summary <- melt(drinkcat_meantrend_summary, variable.name = "Product", value.name = "prop", id.vars = "year")

p <- ggplot(drinkcat_meantrend_summary, aes(x = year)) +
  geom_line(aes(y = prop, color = Product)) +
  xlim(2007, end_year) + # should try to change this to take it from the data
  theme_minimal() +
  xlab("Year") +
  ylab("Proportion of people") +
  ylim(0, 1) +
  scale_color_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000"))

png(paste0(plot_dir, "/07_drink_prefs_trend.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()






##########################################################
# 08 - Age trend in the distribution of average weekly consumption among beer, cider, wine and alcopops for the overall population aged 16 to 89 years

### By age
drinkagecat_meantrend_summary <- data[ , .(
  Beer = sum(beer_units > 0) / length(beer_units),
  Wine = sum(wine_units > 0) / length(wine_units),
  Spirits = sum(spirit_units > 0) / length(spirit_units),
  Alcopops = sum(rtd_units > 0) / length(rtd_units)
),
by = c("age")]

drinkagecat_meantrend_summary <- melt(drinkagecat_meantrend_summary, variable.name = "Product", value.name = "prop", id.vars = "age")

p <- ggplot(drinkagecat_meantrend_summary, aes(x = age)) +
  geom_line(aes(y = prop, color = Product)) +
  scale_x_continuous(breaks = seq(15, 90, 10)) +
  theme_minimal() +
  xlab("Age") +
  ylab("Proportion of people") +
  ylim(0, 1) +
  scale_color_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000"))

png(paste0(plot_dir, "/08_drink_prefs_agetrend.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()







### reserve plots below this line



##########################################################

# Summary characteristics of the population sample

## Distribution of number of individuals

pop_summary <- data[ , .(N = sum(wt_int, na.rm = T)), by = c("age", "sex", "imd_quintile")]
pop_summary[ , N := 1e5 * N / sum(N)]

sum(pop_summary$N)

pop_summary_plot <- copy(pop_summary)

pop_summary_plot[sex == "Male", N := -N]

### Overall population - DOES THIS SHOW EVERYTHING ALREADY
p <- ggplot(pop_summary_plot) +
  geom_bar(aes(x = age, y = N, fill = imd_quintile), stat = "identity", position = "stack") +
  geom_hline(yintercept = 0) +
  ylab("Number of individuals per 100 thousand") +
  coord_flip() +
  theme_minimal() +
  geom_text(aes(x = 80, y = -400), label = "Male", size = 4) +
  geom_text(aes(x = 80, y = 400), label = "Female", size = 4) +
  scale_y_continuous(breaks = c(-1000, -500, 0, 500, 1000), labels = c(1000, 500, 0, 500, 1000)) +
  scale_x_continuous(breaks = seq(10, 90, 10)) +
  scale_fill_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))

png(paste0(plot_dir, "/pop_dist.png"), units="in", width=15/1.5, height=9/1.5, res=600)
print(p +
        labs(title = "Distribution of number of individuals by age, sex and IMD quintile",
             subtitle = "Based on sum of survey weights from the Scottish Health Surveys 2008-2018"))
dev.off()

### By sex ? ### need to figure out better scale for y axis
p <- ggplot(pop_summary_plot) +
  geom_bar(aes(x = age, y = N, fill = sex), stat = "identity", position = "stack") +
  geom_hline(yintercept = 0) +
  ylab("Number of individuals per 100 thousand") +
  coord_flip() +
  theme_minimal() +
  geom_text(aes(x = 80, y = -400), label = "Male", size = 4) +
  geom_text(aes(x = 80, y = 400), label = "Female", size = 4) +
  scale_y_continuous(breaks = c(-1000, -500, 0, 500, 1000), labels = c(1000, 500, 0, 500, 1000)) +
  scale_x_continuous(breaks = seq(10, 90, 10)) +
  scale_fill_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))

png(paste0(plot_dir, "/pop_dist.png"), units="in", width=15/1.5, height=9/1.5, res=600)
print(p +
        labs(title = "Distribution of number of individuals by age, sex and IMD quintile",
             subtitle = "Based on sum of survey weights from the Scottish Health Surveys 2008-2018"))
dev.off()

### By sex 2
p <- ggplot(pop_summary) +
  geom_bar(aes(x = age, y = N, fill = sex), stat = "identity", position = "stack") +
  geom_hline(yintercept = 0) +
  ylab("Number of individuals per 100 thousand") +
  theme_minimal() +
  facet_wrap(~ sex, ncol = 1) +
  scale_y_continuous(breaks = c(-1000, -500, 0, 500, 1000), labels = c(1000, 500, 0, 500, 1000)) +
  scale_x_continuous(breaks = seq(10, 90, 10)) +
  scale_fill_manual(name = "Sex", values = c("#6600cc", "#00cc99"))

png(paste0(plot_dir, "/pop_dist_sex2.png"), units="in", width=15/1.5, height=9/1.5, res=600)
print(p +
        labs(title = "Distribution of number of individuals by sex",
             subtitle = "Based on sum of survey weights from the Scottish Health Surveys 2008-2018"))
dev.off()

### By IMD quintile ### need to figure out better scale for x axis
p <- ggplot(pop_summary) +
  geom_bar(aes(x = age, y = N, fill = imd_quintile), stat = "identity", position = "stack") +
  geom_hline(yintercept = 0) +
  ylab("Number of individuals per 100 thousand") +
  coord_flip() +
  theme_minimal() +
  facet_wrap(~ imd_quintile, nrow = 1) +
  scale_y_continuous(breaks = c(-1000, -500, 0, 500, 1000), labels = c(1000, 500, 0, 500, 1000)) +
  scale_x_continuous(breaks = seq(10, 90, 10)) +
  scale_fill_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))

png(paste0(plot_dir, "/pop_dist_imd.png"), units="in", width=15/1.5, height=9/1.5, res=600)
print(p +
        labs(title = "Distribution of number of individuals by IMD quintile",
             subtitle = "Based on sum of survey weights from the Scottish Health Surveys 2008-2018"))
dev.off()

###################################################################
###################################################################
# Alcohol consumption

# Rename drinker cats
data[ , drinker_cat := plyr::revalue(drinker_cat, c(
  "abstainer" = "Abstainer",
  "lower_risk" = "Lower risk",
  "increasing_risk" = "Increasing risk",
  "higher_risk" = "Higher risk"
))]


# Proportion of drinkers

# by IMD quintile
drnk_summary <- data[ , .N, by = c("drinker_cat", "imd_quintile")]
drnk_summary[ , prop := N / sum(N), by = "imd_quintile"]
drnk_summary[ , drinker_cat := factor(drinker_cat, levels = c("Abstainer", "Lower risk", "Increasing risk", "Higher risk"))]

p <- ggplot(drnk_summary) +
  geom_bar(aes(x = imd_quintile, y = prop, fill = drinker_cat), position = "dodge", stat = "identity") +
  theme_minimal() +
  xlab("IMD quintile") +
  ylab("Proportion") +
  scale_fill_manual(name = "Drinker\ncategory", values = c('#ceeab0', '#92d050', '#ffc000', '#c00000'))

png(paste0(plot_dir, "/drinkerplot_imd.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# by sex
drnk_summary <- data[ , .N, by = c("drinker_cat", "sex")]
drnk_summary[ , prop := N / sum(N), by = "sex"]
drnk_summary[ , drinker_cat := factor(drinker_cat, levels = c("Abstainer", "Lower risk", "Increasing risk", "Higher risk"))]

p <- ggplot(drnk_summary) +
  geom_bar(aes(x = sex, y = prop, fill = drinker_cat), position = "dodge", stat = "identity") +
  theme_minimal() +
  xlab("Sex") +
  ylab("Proportion") +
  scale_fill_manual(name = "Drinker\ncategory", values = c('#ceeab0', '#92d050', '#ffc000', '#c00000'))

png(paste0(plot_dir, "/drinkerplot_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by age
drnk_summary <- data[ , .N, by = c("drinker_cat", "ageband")]
drnk_summary[ , prop := N / sum(N), by = "ageband"]
drnk_summary[ , drinker_cat := factor(drinker_cat, levels = c("Abstainer", "Lower risk", "Increasing risk", "Higher risk"))]

p <- ggplot(drnk_summary) +
  geom_bar(aes(x = ageband, y = prop, fill = drinker_cat), position = "dodge", stat = "identity") +
  theme_minimal() +
  xlab("Sex") +
  ylab("Proportion") +
  scale_fill_manual(name = "Drinker\ncategory", values = c('#ceeab0', '#92d050', '#ffc000', '#c00000'))

png(paste0(plot_dir, "/drinkerplot_age.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


#############################################
# Average number of units drunk per week by drinkers

data[drinker_cat != "Abstainer", weekmean := ceiling(weekmean)]

# by IMD quintile
drnk_summary <- data[drinker_cat != "Abstainer", .N, by = c("weekmean", "imd_quintile")]
drnk_summary[ , prop := N / sum(N), by = "imd_quintile"]

p <- ggplot(drnk_summary) +
  geom_bar(aes(x = weekmean, y = prop, fill = imd_quintile), stat = "identity") +
  theme_minimal() +
  facet_wrap(~ imd_quintile, nrow = 1) +
  xlab("Average units per week") +
  ylab("Proportion") +
  scale_fill_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/drink_amount_imd.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by sex
drnk_summary <- data[drinker_cat != "Abstainer", .N, by = c("weekmean", "sex")]
drnk_summary[ , prop := N / sum(N), by = "sex"]
drnk_summary[ , sex := factor(sex, levels = c("Female", "Male"))]

p <- ggplot(drnk_summary) +
  geom_bar(aes(x = weekmean, y = prop, fill = sex), stat = "identity") +
  theme_minimal() +
  facet_wrap(~ sex, nrow = 1) +
  xlab("Average units per week") +
  ylab("Proportion") +
  scale_fill_manual(name = "Sex", values = c("#6600cc", "#00cc99")) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/drink_amount_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# by ageband
drnk_summary <- data[drinker_cat != "Abstainer", .N, by = c("weekmean", "ageband")]
drnk_summary[ , prop := N / sum(N), by = "ageband"]

p <- ggplot(drnk_summary) +
  geom_bar(aes(x = weekmean, y = prop, fill = ageband), stat = "identity") +
  theme_minimal() +
  facet_wrap(~ ageband, nrow = 1) +
  xlab("Average units per week") +
  ylab("Proportion") +
  scale_fill_manual(name = "Age", values = c('#4c0000', '#6d332e', '#8b615b', '#a78f8c', '#c0c0c0')) +
  theme(legend.position = "top")

png(paste0(plot_dir, "/drink_amount_age.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# Trends over age in the average amount consumed

drink_summary <- data[drinker_cat != "Abstainer"]

drnkunits <- drink_summary[ , .(weekmean_mu = mean(weekmean, na.rm = T),
                                se = sqrt(var(weekmean, na.rm = T) / .N),
                                n_drinkers = .N), by = c("age", "imd_quintile", "sex")]

p <- ggplot(drnkunits) +
  #geom_point(aes(x = age, y = weekmean_mu, colour = imd_quintile), size = .4, alpha = .7) +
  #geom_errorbar(aes(x = age, ymin = weekmean_mu - (1.96 * se), ymax = weekmean_mu + (1.96 * se), colour = imd_quintile), width = 0, size = .7) +
  geom_line(aes(x = age, y = weekmean_mu, colour = imd_quintile), linewidth = .4) +
  facet_wrap(~ sex + imd_quintile, nrow = 2) +
  ylab("units / week") +
  theme_minimal() +
  scale_colour_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))

png(paste0(plot_dir, "/drink_amount_agetrend.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


#############################################
# Distribution of amount consumed among alcohol beverages

drinker_summary <- data[ , .(
  Beer = sum(beer_units > 0) / length(beer_units),
  Wine = sum(wine_units > 0) / length(wine_units),
  Spirits = sum(spirit_units > 0) / length(spirit_units),
  RTDs = sum(rtd_units > 0) / length(rtd_units)
)]

drinker_summary <- melt(drinker_summary, variable.name = "Product", value.name = "prop")

p <- ggplot(drinker_summary) +
  geom_bar(aes(x = Product, y = prop, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  ylab("Proportion") +
  xlab("Product") +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000"))

png(paste0(plot_dir, "/drink_prefs.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by IMD quintile

drinker_summary <- data[ , .(
  Beer = sum(beer_units > 0) / length(beer_units),
  Wine = sum(wine_units > 0) / length(wine_units),
  Spirits = sum(spirit_units > 0) / length(spirit_units),
  RTDs = sum(rtd_units > 0) / length(rtd_units)
), by = "imd_quintile"]

drinker_summary <- melt(drinker_summary, variable.name = "Product", id.vars = "imd_quintile", value.name = "prop")

#drinker_summary[ , prop := value / sum(value), by = "imd_quintile"]

p <- ggplot(drinker_summary) +
  geom_bar(aes(x = Product, y = prop, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  facet_wrap(~ imd_quintile, nrow = 1) +
  ylab("Proportion") +
  xlab("Product") +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000")) +
  theme(legend.position = "top", axis.text.x = element_text(angle = 45))

png(paste0(plot_dir, "/drink_prefs_imd.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# by sex

drinker_summary <- data[ , .(
    Beer = sum(beer_units > 0) / length(beer_units),
    Wine = sum(wine_units > 0) / length(wine_units),
    Spirits = sum(spirit_units > 0) / length(spirit_units),
    RTDs = sum(rtd_units > 0) / length(rtd_units)
), by = "sex"]

drinker_summary <- melt(drinker_summary, variable.name = "Product", id.vars = "sex", value.name = "prop")

p <- ggplot(drinker_summary) +
  geom_bar(aes(x = Product, y = prop, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  facet_wrap(~ sex, nrow = 1) +
  ylab("Proportion") +
  xlab("Product") +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000")) +
  theme(legend.position = "top", axis.text.x = element_text(angle = 45))

png(paste0(plot_dir, "/drink_prefs_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by age

drinker_summary <- data[ , .(
  Beer = sum(beer_units > 0) / length(beer_units),
  Wine = sum(wine_units > 0) / length(wine_units),
  Spirits = sum(spirit_units > 0) / length(spirit_units),
  RTDs = sum(rtd_units > 0) / length(rtd_units)
), by = "ageband"]

drinker_summary <- melt(drinker_summary, variable.name = "Product", id.vars = "ageband", value.name = "prop")

p <- ggplot(drinker_summary) +
  geom_bar(aes(x = Product, y = prop, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  facet_wrap(~ ageband, nrow = 1) +
  ylab("Proportion") +
  xlab("Product") +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000")) +
  theme(legend.position = "top", axis.text.x = element_text(angle = 45))

png(paste0(plot_dir, "/drink_prefs_age.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# Conditional consumption

drinker_summary <- data[drinker_cat != "Abstainer", .(
  Beer = mean(beer_units[beer_units > 0]),
  Wine = mean(wine_units[wine_units > 0]),
  Spirits = mean(spirit_units[spirit_units > 0]),
  RTDs = mean(rtd_units[rtd_units > 0])
)]

drinker_summary <- melt(drinker_summary, variable.name = "Product")

p <- ggplot(drinker_summary) +
  geom_bar(aes(x = Product, y = value, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  ylab("units / week") +
  xlab("Product") +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000")) +
  theme(legend.position = "top", axis.text.x = element_text(angle = 45))

png(paste0(plot_dir, "/drinker_prefs_consumption.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# by IMD quintile

drinker_summary <- data[drinker_cat != "Abstainer", .(
  Beer = mean(beer_units[beer_units > 0]),
  Wine = mean(wine_units[wine_units > 0]),
  Spirits = mean(spirit_units[spirit_units > 0]),
  RTDs = mean(rtd_units[rtd_units > 0])
), by = "imd_quintile"]

drinker_summary <- melt(drinker_summary, variable.name = "Product", id.vars = "imd_quintile")

p <- ggplot(drinker_summary) +
  geom_bar(aes(x = Product, y = value, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  facet_wrap(~ imd_quintile, nrow = 1) +
  ylab("units / week") +
  xlab("Product") +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000")) +
  theme(legend.position = "top", axis.text.x = element_text(angle = 45))

png(paste0(plot_dir, "/drinker_prefs_consumption_imd.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# by sex

drinker_summary <- data[drinker_cat != "Abstainer", .(
  Beer = mean(beer_units[beer_units > 0]),
  Wine = mean(wine_units[wine_units > 0]),
  Spirits = mean(spirit_units[spirit_units > 0]),
  RTDs = mean(rtd_units[rtd_units > 0])
), by = "sex"]

drinker_summary <- melt(drinker_summary, variable.name = "Product", id.vars = "sex")

p <- ggplot(drinker_summary) +
  geom_bar(aes(x = Product, y = value, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  facet_wrap(~ sex, nrow = 1) +
  ylab("units / week") +
  xlab("Product") +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000")) +
  theme(legend.position = "top", axis.text.x = element_text(angle = 45))

png(paste0(plot_dir, "/drinker_prefs_consumption_sex.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()


# by age

drinker_summary <- data[drinker_cat != "Abstainer", .(
  Beer = mean(beer_units[beer_units > 0]),
  Wine = mean(wine_units[wine_units > 0]),
  Spirits = mean(spirit_units[spirit_units > 0]),
  RTDs = mean(rtd_units[rtd_units > 0])
), by = "ageband"]

drinker_summary <- melt(drinker_summary, variable.name = "Product", id.vars = "ageband")

p <- ggplot(drinker_summary) +
  geom_bar(aes(x = Product, y = value, fill = Product), stat = "identity", position = "dodge") +
  theme_minimal() +
  facet_wrap(~ ageband, nrow = 1) +
  ylab("units / week") +
  xlab("Product") +
  scale_fill_manual(name = "Product", values = c("#ffc000", "#00b050", "#7030a0", "#00b0f0", "#ff0000")) +
  theme(legend.position = "top", axis.text.x = element_text(angle = 45))

png(paste0(plot_dir, "/drinker_prefs_consumption_age.png"), units="in", width=10/1.5, height=6/1.5, res=600)
print(p)
dev.off()

# overall consumption distribution
dalc <- ggplot(data[weekmean > 0]) +
  geom_density(aes(x = weekmean, colour = imd_quintile, fill = imd_quintile), size = .4, position = "stack") +
  facet_wrap(~ sex + age_cat, nrow = 2) +
  theme_minimal() +
  xlab("average units / week") +
  scale_colour_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")) +
  scale_fill_manual(name = "IMD quintile", values = c("#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177"))


png(paste0(plot_dir, "/alc_dist.png"), units="in", width=15/1.5, height=9/1.5, res=600)
print(dalc +
        labs(title = "Distribution of average weekly alcohol consumption",
             subtitle = "Data from the Health Survey for England 2013-2018"))
dev.off()

