
# The aim of this code is to install
# the packages used by this package either to build it, run it or to create the package data

# Update R ad R studio
#installr::updateR()

project_lib <- "C:/Users/cm1dog/Documents/R"

.libPaths(project_lib)

###########################
# CRAN packages

# Package names
packages <- c("DiagrammeR",
              "here",
              "data.table",
              "ggplot2",
              "ggthemes",
              "readxl",
              "flextable",
              "magrittr",
              "knitr",
              "rmarkdown",
              "roxygen2",
              "usethis",
              "ids",
              "boot",
              "VGAM",
              "stringr",
              "testthat",
              "praise",
              "parallel",
              "readr",
              "cowsay",
              "snowfall",
              "bit64",
              "Rdpack",
              "lifecycle",
              "crayon",
              "DirichletReg",
              "writexl",
              "Rfast",
              "dvmisc",
              "fastmatch",
              "openxlsx",
              "utils",
              "stats",
              "mice",
              "Hmisc",
              "survey",
              "nnet",
              "tidyverse",
              "readODS",
              "curl")


# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  #install.packages(packages[!installed_packages], type = "source", INSTALL_opts = "--byte-compile")
  install.packages(packages[!installed_packages], lib = project_lib)
  #install.packages(packages[!installed_packages])
}




