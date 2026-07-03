# Income

Process the data on income.

## Usage

``` r
clean_income(data)
```

## Arguments

- data:

  Data table - the Health Survey for England dataset.

## Value

- income5cat: quintiles of equivalised household income.

## Details

There are a few different options for classifying income - the need to
have a measure that is consistent across years of the Health Survey for
England has led us to use equivalised income quintiles only. Past SAPM
modelling has used years of the Health Survey for England for which a
continuous variable for equivalised income was provided. From this, we
calculated our own income groups. In later years, this continuous income
variable is not available (except if we were to apply for a secure
access version of the data).

In the past a measure of in poverty / not in poverty has been used,
where the poverty threshold is defined as 60 to make an exact
calculation of poverty. But it will coincide approximately with the
lowest 2 income quintiles.

It would also be possible from the Health Survey for England to classify
people as being in receipt of benefits or not. This is not done
currently, and would have to have some thought on how to deal with the
changing definitions of benefits over time.

## Examples

``` r

if (FALSE) { # \dontrun{

data <- read_2004()
data <- clean_income(data = data)

} # }
```
