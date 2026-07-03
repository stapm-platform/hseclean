# Whether someone drinks and frequency of drinking

Clean the data on whether someone is a current drinker (drank in last 12
months) and if they did drink how frequently they did so. Several
definitions are used for youth drinking (\< 16 years).

## Usage

``` r
alc_drink_now_allages(data)
```

## Arguments

- data:

  Data table - the survey dataset.

## Value

- drinks_now:

  Drank at all in the last 12 months (drinker, non_drinker).

- drink_freq_7d:

  Frequency of drinking, expressed in terms of the expected number of
  drinking ocassions per week (numerical variable calculated from
  categorical responses to how frequently someone drinks).

- adrinkweek:

  Youth drinks at least once a week (yes, no).

- adrinkmonth:

  Youth drinks at least once a month (yes, no).

- adrinklastweek:

  Youth drank in the last week (yes, no).

## Details

Combines information from adults and children. In general, someone is
classed as a drinker even if they only reported drinking once or twice a
year - which is a less strict definition than used by some other
surveys. Any missing data is supplemented by responses to if currently
drinks or if always non-drinker.

For youth drinking, variables are also created for: drinks at least once
a week, drinks at least once a month, and drank in the last week.

Note: The Scottish Health Survey dataset does not have drinking data on
children younger than 16 years old.

## Examples

``` r

if (FALSE) { # \dontrun{
data <- read_2017()
data <- clean_age(data)
data <- alc_drink_now_allages(data)
} # }
```
