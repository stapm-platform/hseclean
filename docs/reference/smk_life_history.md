# Ages of smoking initiation, quit and censoring

Clean the ages that define when smokers started and stopped as recorded
in the health survey data.

## Usage

``` r
smk_life_history(data)
```

## Arguments

- data:

  Data table - the health survey dataset.

## Value

- smk_start_age

- smk_stop_age

- censor_age

## Details

For each individual smoker, the data recorded in the health survey
implies a single age at which a smoker started to smoke and, if they
stopped, an age at which they did so. This provides a simplified view of
what might be a complicated life history of smoking, e.g. smoking to
different frequencies or levels, or starting and stopping multiple
times.

Both the start age and stop age will have error in them e.g. due to
uncertainty in respondent recall, and, for England in years 2015+, due
to the reporting in categories of time intervals rather than single
years, which we then impute introducing random error.

Start age is likely to be biased towards earlier ages, because for
adults with missing values we use the age first tried a cigarette, and
for children the variable for start age does not necessarily mean the
start of regular smoking, it is just the age at which they started to
smoke.

We also create a variable for the age at which an individual was
censored from our data sample - this is their age at the survey + 1
year.

\# The variables computed using this function are used to reconstruct a
simple life history of smoking for each individual who has ever smoked
regularly. This information is then used by the smktrans R package to
estimate the age-specific probabilities of smoking initiation or
quitting smoking.

Any missing data is assigned the average start or stop age for each age,
sex and IMD quintile.

## Examples

``` r

if (FALSE) { # \dontrun{

data <- read_2001()
data <- clean_age(data)
data <- clean_demographic(data)
data <- smk_status(data)
data <- smk_former(data)
data <- smk_life_history(data)

} # }
```
