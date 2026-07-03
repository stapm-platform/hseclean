# Alcohol average weekly consumption (adults)

We estimate the number of UK standard units of alcohol drunk on average
in a week from the questions on drinking in the last 12 months.

## Usage

``` r
alc_weekmean_adult(
  data,
  abv_data = hseclean::abv_data,
  volume_data = hseclean::alc_volume_data
)
```

## Arguments

- data:

  Data table - the health survey dataset

- abv_data:

  Data table - our assumptions on the alcohol content of different
  beverages in (percent units / ml)

- volume_data:

  Data table - our assumptions on the volume of different drinks (ml).

## Value

- beer_units - average weekly units of beer

- wine_units - average weekly units of wine

- spirit_units - average weekly units of spirits

- rtd_units - average weekly units of alcopops

- weekmean - total average weekly units

- perc_spirit_units - percentage of consumption that is spirits

- perc_wine_units - percentage of consumption that is wine

- perc_rtd_units - percentage of consumption that is alcopops

- perc_beer_units - percentage of consumption that is beer

- drinker_cat - categories of average weekly consumption

- spirits_pref_cat - whether doesn't drink, drinks some or mostly drinks
  spirits

- wine_pref_cat - whether doesn't drink, drinks some or mostly drinks
  wine

- rtd_pref_cat - whether doesn't drink, drinks some or mostly drinks
  alcopops

- beer_pref_cat - whether doesn't drink, drinks some or mostly drinks
  beer

## Details

The calculation has the following steps:

- Convert the categorical variables to numeric variables for the
  frequency with which each beverage is typically consumed (normal beer,
  strong beer, spirits, sherry, wine, alcopops).

- Convert the reported volumes usually consumed (e.g. small glass, large
  glass) into volumes in ml, using the beverage size assumptions above.
  In doing so, variations in recording among years and between the
  interview and self-complete questionnaire are accounted for.

- Combine the volumes (ml) usually consumed with the frequency of
  consumption to give the average volume of each beverage type drunk
  each week (assuming constant consumption across the year).

- Convert the expected volumes of each beverage consumed each week to UK
  standard units of alcohol consumed, using the alcohol content
  assumptions above.

- Collapse normal and strong beer into a single "beer" variable by
  summing their units. Collapse wine and sherry into a single "wine"
  variable by summing their units.

- Calculate total weekly units but summing across beverage categories.

- Calculate the beverage "preference vector" - the percentage of total
  consumption contributed by the consumption of each of four beverage
  types (beer, wine, spirits, alcopops).

- Cap the total units consumed in a week at 300 units, assuming that
  above this already very high level of consumption estimates of
  variation in consumption are less reliable.

- Categorise average weekly consumption into "abstainer", "lower_risk"
  (less than 14 units/week), "increasing_risk" (greater than or equal to
  14 units/week and less than 35 units/week for women, and less than 50
  units/week for men), "higher_risk".

- Categorise beverage preferences - for each of the four beverages,
  "does_not_drink", "drinks_some" (less than or equal to 50% of
  consumption), "mostly_drinks".

In 2007 new questions were added asking which glass size was used when
wine was consumed. Therefore the post HSE 2007 unit calculations are not
directly comparable to previous years' data.

## Examples

``` r

if (FALSE) { # \dontrun{

data <- read_2016()
data <- clean_age(data)
data <- clean_demographic(data)
data <- alc_drink_now(data)
data <- alc_sevenday(data)
data <- alc_weekmean(data)

} # }
```
