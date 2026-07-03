# Family status

Process the data on the number of children in the household and the
relationship status of each respondent.

## Usage

``` r
clean_family(data)
```

## Arguments

- data:

  Data table - the Health Survey for England dataset.

## Value

Returns an updated version of data with the new family variables:

- 'kids' - number of children age \<= 15 years in the household (0, 1,
  2, 3+)

- 'relationship_status' of the respondent (single, married, cohabit,
  sep_div_wid)

## Details

NUMBER OF CHILDREN AGE 0-15 YEARS IN THE HOUSEHOLD

Categorised into: 0, 1, 2, 3+. The problem with the Health Survey for
England is that from 2015 onwards, the number of children in the
household is not provided as this information could be identifiable (you
can get it if you apply and pay for a secure dataset). Therefore, for
years 2015+, the number of children in the household is completely
missing and needs to be imputed.

In the Scottish Health Survey, the number of children in the household
is missing and needs to be imputed.

RELATIONSHIP STATUS

In previous versions of modelling (the SAPM alcohol binge model)
relationship status has been described as married/not-married. Here, we
include more detail by using:

- single

- married, civil partnership or cohabiting

- separated, divorced, widowed

## Examples

``` r

if (FALSE) { # \dontrun{

library(hseclean)

#data <- read_2015(root = "/Volumes/Shared/")

storage_location <- "/Users/duncangillespie/Documents/HSE/"
data <- readRDS(paste0(storage_location, "HSE_2015.rds"))

data <- clean_age(data)
data <- clean_demographic(data)
data <- clean_education(data)
data <- clean_economic_status(data)
data <- clean_family(data)

} # }
```
