# Former smokers: time since quit and time as smoker

Cleans the data on the time since quitting and time spent as a regular
smoker among former smokers.

## Usage

``` r
smk_former(data)
```

## Arguments

- data:

  Data table - the Health Survey for England data.

## Value

Returns an updated data table with:

- years_since_quit

- years_reg_smoker

## Details

The main issue to be overcome is that in the Health Surveys for England
2015+, time since quit and time spent as a smoker is provided in
categories rather than single years. We simulate the single years by
just picking a value at random within the time interval.

We also fill missing data: for children 8-15 years, we assume that
missing values for former smokers = 1 year. For adults, we fill missing
values with the average value for each age, sex and IMD quintile
subgroup.

## Examples

``` r

if (FALSE) { # \dontrun{

library(hseclean)

data <- read_2017(root = "/Volumes/Shared/")
data <- clean_age(data)
data <- clean_demographic(data)
data <- smk_status(data)
data <- smk_former(data)

} # }
```
