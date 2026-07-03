# Alcohol consumption in last seven-days (adults)

Processes the information from the questions on drinking in the last
seven days - how many times drank and characteristics of the heaviest
drinking day.

## Usage

``` r
alc_sevenday_adult(
  data,
  abv_data = hseclean::abv_data,
  alc_volume_data = hseclean::alc_volume_data
)
```

## Arguments

- data:

  Data table - the health survey dataset

- abv_data:

  Data table - our assumptions on the alcohol content of different
  beverages in (percent units / ml)

- alc_volume_data:

  Data table - our assumptions on the volume of different drinks (ml).

## Value

- n_days_drink - number of days drank in last 7.

- peakday - total units on heaviest drinking day

- d7nbeer_units

- d7sbeer_units

- d7ncider_units (HSE 2022+ only)

- d7scider_units (HSE 2022+ only)

- d7spirits_units

- d7sherry_units

- d7wine_units

- d7pops_units

- binge_cat (did_not_drink, binge, no_binge)

## Details

We estimate the number of UK standard units of alcohol drunk on the
heaviest drinking day by using the data on how many of what size
measures of different beverages were drunk, and combining this with our
standard assumptions about beverage volume and alcohol content.

In 2007 new questions were added asking which glass size was used when
wine was consumed. Therefore the post HSE 2007 unit calculations are not
directly comparable to previous years' data.

In HSE 2022, cider was split into normal (\<6 The d7typ variable mapping
also changed in 2022: - Pre-2022: d7typ3=spirits, d7typ4=sherry,
d7typ5=wine, d7typ6=rtds - HSE 2022+: d7typ3=ncider, d7typ4=scider,
d7typ5=spirits, d7typ6=sherry, d7typ7=wine, d7typ8=rtds

## Examples

``` r

if (FALSE) { # \dontrun{

library(hseclean)

data <- read_2017(root = "/Volumes/Shared/")
data <- clean_age(data)
data <- clean_demographic(data)
data <- alc_drink_now_allages(data)
data <- alc_sevenday_adult(data)

} # }
```
