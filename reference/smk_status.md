# Cigarette smoking status

Categorise cigarette smoking into current, former and never regular
cigarette smoker.

## Usage

``` r
smk_status(data)
```

## Arguments

- data:

  Data table - the health survey dataset.

## Value

Returns two smoking variables:

- cig_smoker_status - current, former, never

- cig_ever - ever_smoker, never_smoker, based on current and former
  smokers from the variables above.

## Details

Note that if some smokes either regularly or occasionally, then they are
classified as a current regular cigarette smoker. People who used to
smoke regularly or occasionally are classified as former smokers, but
people who have only tried a cigarette once or twice are classified as
never smokers.

This variable is created for adults aged \>= 16 years, and children aged
8-15 years.

The data is processed from the Health Survey for England and the
Scottish Health Survey. The Scottish Health Survey only has data on
people \>= 16 years old.

## Examples

``` r

if (FALSE) { # \dontrun{

data_2016 <- read_2016()

data_2016 <- smk_status(data = data_2016)

} # }

```
