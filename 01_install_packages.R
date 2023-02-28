
# The aim of this code is to install
# the packages used by this package either to build it, run it or to create the package data

# Update R ad R studio
#installr::updateR()

project_lib <- "C:/Users/cm1dog/Documents/R"

.libPaths(project_lib)

###########################
# CRAN packages

# Package names
packages <- c(
  "boot", 
  "bit64",
  "bookdown",
  "crayon",
  "cowsay",
  "curl",
  "cowplot",
  "dvmisc",
  "DiagrammeR",
  "data.table",
  "DirichletReg",
  "demography",
  "dplyr",
  "devtools",
  "flextable",
  "fastmatch",
  "forecast",
  "ggplot2",
  "ggthemes",
  "git2r",
  "getPass",
  "Hmisc",
  "here",
  "ids",
  "knitr",   
  "lifecycle",
  "magrittr",
  "mice",
  "nnet",
  "openxlsx",
  "praise",
  "parallel",
  "plyr",
  "readxl",
  "roxygen2",
  "readr",
  "Rdpack",
  "readODS",
  "Rfast",
  "rmarkdown",
  "raster",
  "RColorBrewer",
  "stats",
  "survey",
  "stringr",
  "snowfall",
  "testthat",
  "tidyverse",
  "TTR",
  "usethis",
  "utils",
  "VGAM",
  "viridis",
  "writexl")


# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  #install.packages(packages[!installed_packages], type = "source", INSTALL_opts = "--byte-compile")
  install.packages(packages[!installed_packages], lib = project_lib)
  #install.packages(packages[!installed_packages])
}

# Install the hseclean package
devtools::install_git(
  "https://github.com/stapm/hseclean.git",
  build_vignettes = FALSE, quiet = TRUE)


