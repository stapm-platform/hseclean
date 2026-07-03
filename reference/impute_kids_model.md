# Multinomial model of number of kids in the household 2012-2014

To impute the missing data for number of kids in the household for years
2015+

## Usage

``` r
impute_kids_model
```

## Format

model object

## Source

The code used to fit the model is in data-raw/Impute Kids

## Details

This is a saved model object. It is a multinomial model fitted in the R
package nnet. multinom(formula = kids ~ age_cat + sex +
relationship_status + ethnicity_4cat + imd_quintile + eduend4cat +
degree + nssec3_lab + employ2cat + activity_lstweek, data = data, maxit
= 1000)
