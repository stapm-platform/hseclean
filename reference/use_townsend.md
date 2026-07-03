# Use the Townsend Index of Deprivation

Produce a version of the Health Survey for England data that has the
Townsend Index in it, based on the probabilistic mapping between the
2015 English Index of Multiple Deprivation and the Townsend Index from
the 2001 census.

## Usage

``` r
use_townsend(data, imdq_to_townsend_map = hseclean::imdq_to_townsend)
```

## Arguments

- data:

  Data table - the Health Survey for England dataset

- imdq_to_townsend_map:

  Data table - laid out as a matrix that gives the probability that
  someone from each IMD quintile will be in each Townsend quintile.

## Value

Returns a re-sampled version of the Health Survey for England data, in
which each data point is duplicated 5 times (once for each Townsend
quintile) and the survey weights adjusted accordingly.

## Examples

``` r

if (FALSE) { # \dontrun{
kn <- 1e3

test_data <- data.table::data.table(
  imd_quintile =
    sample(c("5_most_deprived", "4", "3", "2", "1_least_deprived"),
    kn,
    replace = TRUE),
  wt_int = runif(kn)
)

data_with_townsend <- use_townsend(test_data)
} # }
```
