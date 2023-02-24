
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Health Survey Data Wrangling <img src="logo.png" align="right" style="padding-left:10px;background-color:white;" width="100" height="100" />

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)

<!-- badger::badge_doi("10.17605/OSF.IO/43N7P", "green") -->

[![](https://img.shields.io/badge/doi-10.17605/OSF.IO/43N7P-green.svg)](https://doi.org/10.17605/OSF.IO/43N7P)
<!-- badges: end -->

## The Sheffield Tobacco and Alcohol Policy Modelling Platform

This R package was developed as part of the Sheffield Tobacco and
Alcohol Policy Modelling <https://stapm.gitlab.io/> by the [School of
Health and Related Research at the University of
Sheffield](https://www.sheffield.ac.uk/scharr).

The aim of the research programme is to identify and evaluate approaches
to reducing the harm from tobacco and alcohol, with the aim of improving
commissioning in a public health policy context, i.e. providing
knowledge to support benefits achieved by policymakers.

The two objectives of the research programme are:

-   To evaluate the health and economic effects of past trends, policy
    changes or interventions that have affected alcohol consumption
    and/or tobacco smoking
-   To appraise the health and economic outcomes of potential future
    trends, changes to alcohol and/or tobacco policy or new
    interventions

The STAPM modelling is not linked to the tobacco or alcohol industry and
is conducted without industry funding or influence.

## Purpose of making the code open source

The code has been made open source for the following two reasons:

-   Transparency. Open science, allowing review and feedback to the
    project team on the code and methods used.
-   Methodology sharing. For people to understand the code and methods
    used so they might use aspects of it in their own work, e.g.,
    because they are doing something partially related that isn’t
    exactly the same job and might like to ‘dip into’ elements of this
    code for inspiration.

## Stage of testing and development

The code is functional and is being used in project work. It is being
reviewed and developed all the time. More tests and checks need to be
added.

The repository is not intended to be maintained by an open source
community wider than the development team.

## Data checks

Data checks are brief reports that show the results of survey data
processing using the hseclean package.

-   [Alcohol consumption in the Scottish Health
    Survey](https://stapm.gitlab.io/model-inputs/scot_nat_alc_data/shes_alc_data_report.html)
-   [Tobacco consumption in the Scottish Health
    Survey](https://stapm.gitlab.io/model-inputs/scotland_nat_tob_data/shes_tob_data_report.html)

## Code repositories

The code on Github is a mirror of the code in a private Gitlab
repository where the actual development takes place.

## Motivation for developing the package

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

## Functionality

hseclean works with data from annual surveys covering health and
health-related behaviours for England and Scotland. It does not function
without this data. However no datasets are provisioned. The code is
designed to work with the tab delimited versions of the data downloaded
from the [UK Data Service](https://ukdataservice.ac.uk/).

The package is primarily designed for users at the University of
Sheffield, working off the university’s networked drives. This is where
most of the testing has taken place so there might be unexpected issues
out of that environment.

What the software does in general and how it relates to data is
documented in the vignettes under “Technical Documentation”.

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

`hseclean` is publicly available via Github.

By default the user should install the latest tagged version of the
package. Otherwise, if you want to reproduce project work and know the
version of the package used, install that version.

If on a University of Sheffield managed computer, install the R, RStudio
and Rtools bundle from the Software Centre. Install Rtools - using the
[installr](https://cran.r-project.org/web/packages/installr/index.html)
package can make this easier. Then install the latest or a specified
version of `hseclean` from Github with:

``` r
#install.packages("devtools")

devtools::install_git(
  "https://github.com/stapm/hseclean.git", 
  ref = "x.x.x",
  build_vignettes = FALSE)

# ref = "x.x.x" is the version to install - change to the version you want e.g. "1.2.3"
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
