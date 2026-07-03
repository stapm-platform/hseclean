# Summarise the percentages of people with certain levels of a variable

Uses the 'survey' package to estimate the percentages with uncertainty
that accounts for survey sampling error and survey design.

## Usage

``` r
prop_summary(data, var_name, levels_1, levels_0, strat_vars = NULL)
```

## Arguments

- data:

  Data table of individual characteristics.

- var_name:

  Character - the name of the variable to be summarised.

- levels_1:

  Character vector - the levels that should be assigned 1 in the binary
  variable

- levels_0:

  Character vector - the levels that should be assigned 0 in the binary
  variable

- strat_vars:

  Character vector - the variables by which to stratify the estimates

## Value

Returns the estimate and standard error.

## Examples

``` r

if (FALSE) { # \dontrun{

prop_smokers <- prop_summary(
  data = data,
  var_name = "cig_smoker_status",
  levels_1 = "current",
  levels_0 = c("former", "never"),
  strat_vars = c("sex", "imd_quintile")
)

} # }
```
