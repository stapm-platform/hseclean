# Drink frequency

Convert the surveyed drink frequency to a measure of days per week on
which drinking occurred.

## Usage

``` r
alc_drink_freq(x)
```

## Arguments

- x:

  Drinking frequency

## Value

Returns a numeric translation (days/week) of the categorical drinking
frequency variable.

- Almost every day:

  7

- Five or six days a week:

  5.5

- Three or four days a week:

  3.5

- Once or twice a week:

  1.5

- Once or twice a month:

  0.375

- Once every couple of months:

  0.188

- Once or twice a year:

  0.029

## Examples

``` r

if (FALSE) { # \dontrun{

alc_drink_freq(1)

} # }
```
