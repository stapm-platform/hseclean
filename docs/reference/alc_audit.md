# Alcohol Use Disorder Identification Test (AUDIT)

Calculating the AUDIT and AUDIT-C scores.

## Usage

``` r
alc_audit(data)
```

## Arguments

- data:

  Data table - the health survey dataset

## Value

- audit1-10 - score for individual AUDIT questions

- audit - full AUDIT score (1-40)

- audit_c - AUDIT-C score (1-12)

- audit_cat - categorisation of AUDIT; low risk (1-7), medium risk
  (8-15), higher risk (16-19), possible dependence (20-40)

- audit_c_cat - categorisation of AUDIT-C; low risk (1-4), medium risk
  (5-7), higher risk (8-10), possible dependence (11-12)

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
