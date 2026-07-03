# Select variables and apply filters

Selects the variables required for analysis and selects only the rows
without missing data for specified variables.

## Usage

``` r
select_data(
  data,
  ages = 8:89,
  years = 2001:2018,
  keep_vars = c("age", "sex", "imd_quintile"),
  complete_vars = c("age", "sex", "imd_quintile")
)
```

## Arguments

- data:

  Data table - the Health Survey for England dataset.

- ages:

  Integer vector - the ages in single years to retain (defaults to 8 to
  89 years).

- years:

  Integer vector - the years in single years to retain.

- keep_vars:

  Character vector - the names of the variables to keep.

- complete_vars:

  Character vector - the names of the variables on which the selection
  of complete cases will be based.

## Value

Returns a reduced version of data

## Examples

``` r

if (FALSE) { # \dontrun{

data <- select_data(data, keep_vars = c("age", "sex", "imd_quintile", "cig_smoker_status"))

} # }
```
