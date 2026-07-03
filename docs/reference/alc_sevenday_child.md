# Alcohol consumption in last seven-days (children)

Processes the information from the questions on drinking in the last
seven days - whether different types of beverages have been drunk in
last 7 days, and if so, how much of each was drunk.

## Usage

``` r
alc_sevenday_child(
  data,
  abv_data = hseclean::abv_data,
  alc_volume_data = hseclean::alc_volume_data
)
```

## Arguments

- data:

  Data table - the Health Survey for England dataset

- abv_data:

  Data table - our assumptions on the alcohol content of different
  beverages in (percent units / ml)

- alc_volume_data:

  Data table - our assumptions on the volume of different drinks (ml).

## Value

- total_units7_ch - total units drunk in last 7 days

## Details

We estimate the number of UK standard units of alcohol drunk in the last
7 days by using the data on how many of what size measures of different
beverages were drunk, and combining this with our standard assumptions
about beverage volume and alcohol content.

MISSING DATA

Normally, if one of the constituent variables was missing, the whole
variable would be marked as missing. However, due to high missingness,
we just assume any missing = 0, and so are likely to make
underestimates.

## Examples

``` r

if (FALSE) { # \dontrun{

data <- read_2001()
data <- clean_age(data)
data <- clean_demographic(data)
data <- alc_drink_now_allages(data)
data <- alc_weekmean_adult(data)
data <- alc_sevenday_adult(data)
data <- alc_sevenday_child(data)

} # }
```
