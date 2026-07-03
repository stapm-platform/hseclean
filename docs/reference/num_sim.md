# Simulate single years from age/time category

Used to overcome the loss of variables (age, time since quit) in single
years in the Health Surveys for England 2015+.

## Usage

``` r
num_sim(x, lkup = NULL)
```

## Arguments

- x:

  Character - the age/time category e.g. "15-20".

- lkup:

  Data.table. Defaults to NULL. Must have column names ind, var, p. E.g.
  ind = endsmoke_cat, var = years_since_quit, p = probability.

## Value

Returns an integer.

## Details

Takes a category with beginning and end separated by "-" and randomly
assigns each observation a number within the age category. Or uses a
lookup file to sample from the probability distribution of single values
within each category.

## Examples

``` r

num_sim("15-20")
#> [1] 19
```
