library(hseclean)
library(magrittr)
library(data.table)
library(ggplot2)

source("R/read_2022.R")
source("R/alc_weekmean_adult.R")

data_11 <- read_2011()
data_12 <- read_2012()
data_13 <- read_2013()
data_14 <- read_2014()
data_15 <- read_2015()
data_16 <- read_2016()
data_17 <- read_2017()
data_18 <- read_2018()
data_19 <- read_2019()
data_22 <- read_2022()

years_to_process <- c(2011:2019, 2022)

cleaning_functions <- c(
  "clean_age",
  "clean_demographic",
  "clean_education",
  "clean_economic_status",
  "clean_family",
  "clean_income",
  "clean_health_and_bio",
  "smk_status",
  "smk_former",
  "smk_quit",
  "smk_life_history",
  "smk_amount",
  "alc_drink_now_allages",
  "alc_weekmean_adult"
)

for (year in years_to_process) {
  data_variable_name <- paste0("data_", substr(year, 3, 4))

  if (exists(data_variable_name)) {
    current_data <- get(data_variable_name)

    for (func_name in cleaning_functions) {
      if (exists(func_name, mode = "function")) {
        current_data <- do.call(func_name, list(current_data))
      } else {
        warning(paste("Function", func_name, "not found."))
      }
    }

    assign(data_variable_name, current_data)
    cat("Cleaned", data_variable_name, "\n")
  } else {
    warning(paste("Data frame", data_variable_name, "not found."))
  }
}

library(dplyr)

filtered_22 <- data_22 %>%
  select(hse_id, totalwu, weekmean) %>%
  group_by(hse_id) %>%
  mutate(difference = totalwu - weekmean)

# comparisons within year

ggplot(data = data_22, aes(x = weekmean, y = totalwu)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(
    title = "2022",
    x = "weekmean",
    y = "totalwu"
  ) +
  coord_cartesian(xlim = c(0, 325), ylim = c(0, 325)) +
  theme_minimal()

ggplot(data = data_22, aes(x = nbeer_units, y = nbeerwu)) +
  geom_point(color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "2022 - Normal Beer") +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 200)) +
  theme_minimal()

ggplot(data = data_22, aes(x = sbeer_units, y = sbeerwu)) +
  geom_point(color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "2022 - Strong Beer") +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 200)) +
  theme_minimal()

ggplot(data = data_22, aes(x = ncider_units, y = nciderwu)) +
  geom_point(color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "2022 - Normal Cider") +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 200)) +
  theme_minimal()

ggplot(data = data_22, aes(x = scider_units, y = sciderwu)) +
  geom_point(color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "2022 - Strong Cider") +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 200)) +
  theme_minimal()

ggplot(data = data_22, aes(x = spirit_units, y = spirwu)) +
  geom_point(color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "2022 - Spirits") +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 200)) +
  theme_minimal()

ggplot(data = data_22, aes(x = sherry_units, y = sherwu)) +
  geom_point(color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "2022 - Sherry") +
  coord_cartesian(xlim = c(0, 30), ylim = c(0, 30)) +
  theme_minimal()

ggplot(data = data_22, aes(x = wine_only_units, y = winewu)) +
  geom_point(color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "2022 - Wine") +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 200)) +
  theme_minimal()

ggplot(data = data_22, aes(x = rtd_units, y = popswu)) +
  geom_point(color = "purple") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(title = "2022 - RTDs") +
  coord_cartesian(xlim = c(0, 40), ylim = c(0, 40)) +
  theme_minimal()

ggplot(data = data_19, aes(x = weekmean, y = totalwu)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(
    title = "2019",
    x = "weekmean",
    y = "totalwu"
  ) +
  coord_cartesian(xlim = c(0, 325), ylim = c(0, 325)) +
  theme_minimal()

ggplot(data = data_18, aes(x = weekmean, y = totalwu)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(
    title = "2018",
    x = "weekmean",
    y = "totalwu"
  ) +
  coord_cartesian(xlim = c(0, 325), ylim = c(0, 325)) +
  theme_minimal()

ggplot(data = data_17, aes(x = weekmean, y = totalwu)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", se = FALSE, color = "red", linetype = "dashed") +
  labs(
    title = "2017",
    x = "weekmean",
    y = "totalwu"
  ) +
  coord_cartesian(xlim = c(0, 325), ylim = c(0, 325)) +
  theme_minimal()

# comparisons to trends

list_of_data <- list(data_11, data_12, data_13, data_14, data_15, data_16, data_17, data_18, data_19, data_22)

combined_data <- bind_rows(list_of_data)

yearly_averages <- combined_data %>%
  filter(age >= 18 & age <= 89) %>%
  group_by(year) %>%
  summarise(
    avg_weekmean_weighted = weighted.mean(weekmean, w = wt_int, na.rm = TRUE),
    avg_weekmean_unweighted = mean(weekmean, na.rm = TRUE)
  )

ggplot(yearly_averages, aes(x = year, y = avg_weekmean_weighted)) +
  geom_line(size = 1, color = "darkblue") +
  geom_point(size = 3, color = "darkblue") +
  labs(
    x = "Year",
    y = "Weighted Average `weekmean`"
  ) +
  theme_minimal(base_size = 14) +
  scale_x_continuous(breaks = yearly_averages$year)
