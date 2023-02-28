
# The aim of this code is to run the scripts that produce the data check

path <- "data-checks/Scotland_alcohol_data/"

source(paste0(path, "10_clean_shes.R"))
source(paste0(path, "15_Imputation.R"))
source(paste0(path, "30_QA_check_descriptive_plots.R"))
source(paste0(path, "35_av_weekly_consumption_detailed_check.R"))

rmarkdown::render(
  input = paste0(path, "shes_alc_data_report.Rmd"),
  output_dir = "docs",
  output_file = "shes_alc_data_report",
  quiet = TRUE)
