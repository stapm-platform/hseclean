
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hseclean <img src="tools/hseclean_hex.png" align="right" style="padding-left:10px;background-color:white;" width="100" height="100" />

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)  
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3748784.svg)](https://doi.org/10.5281/zenodo.3748784)

The package is usable but there are still bugs and further developments
that are being worked through i.e. some code and documentation is still
incomplete or in need of being refined. The code and documentation are
still undergoing internal review by the analyst team.

## Motivation

`hseclean` was created as part of a programme of work on the health
economics of tobacco and alcohol at the School of Health and Related
Research (ScHARR), The University of Sheffield. This programme is based
around the construction of the Sheffield Tobacco and Alcohol Policy
Model (STAPM), which aims to use comparable methodologies to evaluate
the impacts of tobacco and alcohol policies, and investigate the
consequences of clustering and interactions between tobacco and alcohol
consumption behaviours.

The original motivation for `hseclean` was to standardised the way that
the Health Survey for England (HSE) data were cleaned and prepared for
our analyses and inputs to our decision-analytic models. The suite of
functions within `hseclean` reads the data for each year since 2001,
renames, organises and processes the variables that we use for our
analyses. The package also includes functions to multiply impute missing
data, and to summarise data considering survey design.

We have subsequently added functions to process the Scottish Health
Survey (SHeS) into a form that matches our processing of the Health
Survey for England.

> Health Survey for England and Scottish Health Survey data are accessed
> via the UK Data Service. `hseclean` is designed to read the tab
> delimited files.

## Usage

`hseclean` is a package for reading and cleaning the Health Survey for
England and Scottish Health Survey data.

The **inputs** are the raw survey data files for each year.

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

We would like to ask that since the code and documentation is still
under development and is complex, that you consult with the authors
before you use it.

Please cite the latest version of the package using:  
“Duncan Gillespie, Laura Webster, Colin Angus and Alan Brennan (2020).
hseclean: Health Survey Data Wrangling. R package version 0.3.4.
<https://dosgillespie.github.io/hseclean/>. DOI: 10.5281/zenodo.3748784”

-----

Since you will be downloading and installing a source package, you might
need to set your system up for building R packages:

It is a good idea to update R and all of your packages.

**Mac OS**: A convenient way to get the tools needed for compilation is
to install Xcode Command Line Tools. Note that this is much smaller than
full Xcode. In a shell, enter xcode-select –install. For installing
almost anything else, consider using [Homebrew](https://brew.sh/).

**Windows**: Install Rtools. This is not an R package\! It is “a
collection of resources for building packages for R under Microsoft
Windows, or for building R itself”. Go to
<https://cran.r-project.org/bin/windows/Rtools/> and install as
instructed.

-----

You can **install the development version of `hseclean`** from github
with:

``` r
#install.packages("devtools")
devtools::install_github("dosgillespie/hseclean")
```

-----

If there is an error with `install_github()`, one possible work-around
is

1.  Download the package “tarball” by copying this into your internet
    browser (making sure the numbers at the end indicate the latest
    version) `https://github.com/dosgillespie/hseclean/tarball/0.3.4`.
    When the window pops up, choose where to save the file. The file I
    downloaded was `dosgillespie-hseclean-0.3.4-0-g9864603.tar.gz` and I
    saved it to Downloads.

2.  Go to the Terminal window in R Studio (or a console window in
    Windows by searching for “cmd”) and install the package from the
    downloaded file by typing `R CMD INSTALL
    Downloads/dosgillespie-hseclean-0.3.4-0-g9864603.tar.gz`.

-----

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

## Getting started

To be able to **download data from the UK Data Service**, you will need
to **register with the UK Data Service website**, which will enable you
to request access to the datasets. Instructions on how to do this can be
found
[here](https://www.ukdataservice.ac.uk/get-data/how-to-access.aspx).

In ScHARR, all data is stored and processed according to the [ScHARR
Information Governance
Policy](https://www.sheffield.ac.uk/scharr/research/igov/policy00). The
HSE and SHeS data is stored in the university networked X-drive folder
`PR_Consumption_TA`, which is accessible only to team members who are
using data according to the purposes stated to the UK Data Service. No
individual-level data is included within this package on Github.

## Basic functionality

### Reading the HSE data files

There are separate functions in `hseclean` to read each year of HSE
data. You must specify the link to where the data is stored. The
functions read in all variables related to tobacco and alcohol and
selected socioeconomic and other descriptor variables.

``` r
test_2001 <- read_2001(
  root = "X:/",
  file = "ScHARR/PR_Consumption_TA/HSE/HSE 2001/UKDA-4628-tab/tab/hse01ai.tab"
)
```

-----

`hseclean` contains separate functions for reading the survey data for
each year, e.g. `read_SHeS_2008()`.

### Processing socioeconomic, demographic and health variables

There are separate functions that focus on processing a different theme
of socioeconomic, demographic and health variables. See
`vignette("covariate_data")`.

``` r
library(magrittr)

temp <- read_2017(root = root_dir) %>%
  clean_age %>%
  clean_family %>%
  clean_demographic %>% 
  clean_education %>%
  clean_economic_status %>%
  clean_income %>%
  clean_health_and_bio
```

### Alcohol data

Detailed description of how to clean the alcohol data are given in
`vignette("alcohol_data")`. As an example, here is the workflow to plot
the frquency of drinking among people who drank in 2017.

``` r
library(magrittr)
library(dplyr)
library(ggplot2)

# Frequency of drinking in 2017 among drinkers
root_dir <- "/Volumes/Shared/"
#root_dir <- "X:/"

read_2017(root = root_dir) %>%
  clean_age %>%
  clean_demographic %>%
  alc_drink_now_allages %>%
  filter(age < 90, age >= 8, drinks_now == "drinker") %>%
  group_by(imd_quintile, age_cat) %>% 
  summarise(av_freq = mean(drink_freq_7d, na.rm = T)) %>% 
  ggplot(aes(x = imd_quintile, y = av_freq, fill = age_cat)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal() +
  ylab("average number of days drink in a week")
```

### Clean all years of smoking and alcohol data

See `vignette("smoking_data")`.

``` r
library(magrittr)

# Wrap the individual cleaning functions in another function for applying to each year

cleandata <- function(data) {
  
  data %<>%
    clean_age %>%
    clean_family %>%
    clean_demographic %>% 
    clean_education %>%
    clean_economic_status %>%
    clean_income %>%
    clean_health_and_bio %>%
    smk_status %>%
    smk_former %>%
    smk_life_history %>%
    smk_amount %>%
    alc_drink_now_allages %>%
    alc_weekmean_adult %>%
    alc_sevenday_adult %>%
    alc_sevenday_child %>%
    
    select_data(
      ages = 12:89,
      years = 2001:2017,
      
      # variables to retain
      keep_vars = c("wt_int", "psu", "cluster", "year", "quarter",
                    "age", "age_cat", "sex", "imd_quintile",
                    "ethnicity_4cat", "ethnicity_2cat",
                    "degree", "relationship_status", "employ2cat", "social_grade", "kids", "income5cat",
                    "nssec3_lab", "man_nonman", "activity_lstweek", "eduend4cat",
                    
                    "hse_cancer", "hse_endocrine", "hse_heart", "hse_mental", "hse_nervous", "hse_eye", "hse_ear", "hse_respir", 
                    "hse_disgest", "hse_urinary", "hse_skin", "hse_muscskel", "hse_infect", "hse_blood",
                    
                    "weight", "height", "bmi",
                    
                    "cig_smoker_status", "years_since_quit", "years_reg_smoker", "cig_ever",
                    "cigs_per_day", "smoker_cat", "banded_consumption", "cig_type", "time_to_first_cig",
                    "smk_start_age", "smk_stop_age", "censor_age", "giveup_smk",
                    
                    "drinks_now", 
                    "drink_freq_7d", "n_days_drink", "peakday", "binge_cat",
                    "beer_units", "wine_units", "spirit_units", "rtd_units", 
                    "weekmean", 
                    "perc_spirit_units", "perc_wine_units", "perc_rtd_units", "perc_beer_units", 
                    "drinker_cat", 
                    "spirits_pref_cat", "wine_pref_cat", "rtd_pref_cat", "beer_pref_cat", 
                    "total_units7_ch"
      ),
      
      # The variables that must have complete cases
      complete_vars = c("age", "sex", "year", "quarter", "psu", "cluster")
    )
  
  return(data)
}

# Read and clean each year of data and bind them together in one big dataset
data <- combine_years(list(
  cleandata(read_2001(root = root_dir)),
  cleandata(read_2002(root = root_dir)),
  cleandata(read_2003(root = root_dir)),
  cleandata(read_2004(root = root_dir)),
  cleandata(read_2005(root = root_dir)),
  cleandata(read_2006(root = root_dir)),
  cleandata(read_2007(root = root_dir)),
  cleandata(read_2008(root = root_dir)),
  cleandata(read_2009(root = root_dir)),
  cleandata(read_2010(root = root_dir)),
  cleandata(read_2011(root = root_dir)),
  cleandata(read_2012(root = root_dir)),
  cleandata(read_2013(root = root_dir)),
  cleandata(read_2014(root = root_dir)),
  cleandata(read_2015(root = root_dir)),
  cleandata(read_2016(root = root_dir)),
  cleandata(read_2017(root = root_dir))
))

# clean the survey weights
data <- clean_surveyweights(data)
```

### Summarise data

The function `survey::svyby()` in the `survey` R package is used by the
function `prop_summary()` in `hseclean` to estimate the uncertainty
around proportions calculated from a binary variable - `prop_summary()`
was designed to simplify the process of estimating smoking prevalence
from the HSE data, stratified by a specified set of variables.

``` r
prop_smokers <- prop_summary(
  data = hse_data,
  var_name = "smk.state",
  levels_1 = "current",
  levels_0 = c("former", "never"),
  strat_vars = c("year", "sex", "imd_quintile")
)
```

### Missing data imputation

`hseclean` uses the function `mice::mice()` in the `mice` R package,
implemented in a basic way by the `impute_data_mice()` function. See
`vignette("missing_data")`.

``` r
# Run the imputation (takes a long time)
imp <- impute_data_mice(data = hse_data,
                        var_names = c("smk.state", "agegroup", "sex", 
                                      "imd_quintile", "degree", "kids", "income5cat",
                                      "relationship_status", "employ2cat", "social_grade"),
                        var_methods = c("", "", "", 
                                        "polr", "logreg", "polr", "polr",
                                        "polyreg", "logreg", "logreg"),
                        n_imputations = 5)

# imp$data is a single data.table containing all 5 imputed versions of the data
hse_data_imputed <- copy(imp$data)
```
