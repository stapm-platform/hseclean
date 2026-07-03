# Fills missing values with subgroup mean value

Replaces any values \< 0 with NA, calculates the subgroup mean, then
replaces missing values with the subgroup mean.

## Usage

``` r
impute_mean(
  data,
  var_names,
  remove_zeros = FALSE,
  strat_vars = c("year", "sex", "imd_quintile", "age_cat")
)
```

## Arguments

- data:

  Data table - the health survey data

- var_names:

  Character vector - the variable names to be imputed (numeric variables
  only)

- remove_zeros:

  Logical - should zeros be treated as missing data

- strat_vars:

  Character vector - the variables by which to stratify the subgroup
  means

## Value

Returns an updated version of data in which the variables specified have
had their missing values imputed with the subgroup means.

## Details

If not all NAs can be imputed with the fine scale starting amount of
stratification, imputation is attempted again, removing the
stratification variable specified last.

## Examples

``` r

if (FALSE) { # \dontrun{

data <- read_2001()
data <- clean_age(data)
data <- clean_demographic(data)
data <- impute_mean(data, var_names = c("d7many"))

} # }
```
