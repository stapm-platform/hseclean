
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Health Survey Data Wrangling <img src="logo.png" align="right" style="padding-left:10px;background-color:white;" width="100" height="100" />

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
<!-- badges: end -->

## Motivation

The motivation for `hseclean` was to standardised the way that health
survey data were cleaned and prepared for our analyses and inputs to the
STAPM decision-analytic model. The data are annual surveys covering
health and health-related behaviours for England and Scotland. The suite
of functions within `hseclean` reads the data for each year, renames,
organises and processes the variables including multiple imputation and
basic data summaries.

`hseclean` was created as part of a programme of work on the health
economics of tobacco and alcohol at the School of Health and Related
Research (ScHARR), The University of Sheffield. This programme is based
around the construction of the Sheffield Tobacco and Alcohol Policy
Model (STAPM), which aims to use comparable methodologies to evaluate
the impacts of tobacco and alcohol policies.

We have subsequently added functions to process the Scottish Health
Survey (SHeS) into a form that matches our processing of the Health
Survey for England.

## Usage

`hseclean` is a package for reading and cleaning the Health Survey for
England and Scottish Health Survey data.

The **inputs** are the tab delimited survey data files for each year.

The **processes** applied by the functions in `hseclean` give options
to:

1.  Read tobacco and alcohol related variables and the information on
    individual characteristics that we use in our analyses.  
2.  Clean alcohol consumption data, applying assumptions about beverage
    size and alcohol content.  
3.  Clean data on current smoking and smoking history.  
4.  Clean data on individual characteristics including age, sex,
    ethnicity, economic status, family, health and income.  
5.  Multiply impute missing data.  
6.  Summarise categorical variables using proportions, considering
    survey design.

The **output** of these processes is a cleaned dataset that is ready for
further analysis. This dataset can be saved so that you don’t need to
run the cleaning processes in `hseclean` each time you want to use the
cleaned data.

## Installation

`hseclean` is currently available only to members of the project team -
there are plans afoot to make the code open access. To access - [sign-up
for a GitLab account](https://gitlab.com/) to be given access rights to
the STAPM project.

Install Rtools - using the `installr` package can make this easier. Then
install the latest or a specified version of `hseclean` from GitLab
with:

``` r
#install.packages("devtools")
#install.packages("getPass")

devtools::install_git(
  "https://gitlab.com/stapm/r-packages/hseclean.git", 
  credentials = git2r::cred_user_pass("uname", getPass::getPass()),
  ref = "x.x.x",
  build_vignettes = TRUE
)

# Where uname is your Gitlab user name.
# ref = "x.x.x" is the version to install - change to the version you want e.g. "1.2.3"
# this should make a box pop up where you enter your GitLab password
```

Or clone the package repo locally and use the ‘install and restart’
button in the Build tab of RStudio. This option is more convenient when
testing development versions.

Then load the package, and some other packages that are useful. Note
that the code within `hseclean` uses the `data.table::data.table()`
syntax.

``` r
# Load the package
library(hseclean)

# Other useful packages
library(dplyr) # for data manipulation and summary
library(magrittr) # for pipes
library(ggplot2) # for plotting
```
