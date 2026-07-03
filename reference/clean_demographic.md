# Clean demographic variables

Creates variables for ethnicity, region, sex, and quintiles of the Index
of Multiple Deprivation (IMDQ).

## Usage

``` r
clean_demographic(data)
```

## Arguments

- data:

  Data table - the Health Survey for England/Scotland Health Survey
  dataset.

## Value

- ethnicity_4cat: 4 level variable (see above).

- ethnicity_2cat: 2 level variable (white/nonwhite).

- sex: m/f

- imd_quintile

## Details

See below

## Sex

1 = Male, 2 = Female.

## Index of Multiple Deprivation quintiles

5_most_deprived, 4, 3, 2, 1_least_deprived. The Scottish Health Survey
uses the Scottish Index of Multiple Deprivation. This is kept as a
separate variable to the English IMD variable as each country calculated
its own slightly different version of IMD. However, there has been a
study harmonising IMD measures across the four UK nations Abel et al.
(2016) that could be looked at in the future if we want to compare
across countries.

## Ethnicity

In an attempt to harmonise different years of data to the recommended
definitions, we have pooled the Asian and other categories.

- White (English, Irish, Scottish, Welsh, other European)

- Mixed / multiple ethnic groups

- Asian / Asian British (includes African-Indian, Indian, Pakistani,
  Bangladeshi), plus Other ethnic group (includes Chinese, Japanese,
  Philippino, Vietnamese, Arab)

- Black / African / Caribbean / Black British (includes Caribbean,
  African)

Following inspection of the data, the white/non-white classification
does look appropriate, especially given the likely limited sample
sizes - so the 2 level variable has also been created.

For 2008-2013 of the Scottish Health Survey, we can create the same
4-category variable as for the HSE, however for 2014 onwards, the
Scottish Health Survey 2018 only identifies 5 groups of ethnicity:

- White (Scottish)

- White (Other British)

- White (Other)

- Asian

- Other minority ethnic

On the basis of this, only the 2 level variable (white/non-white) has
been created for all years for Scotland.

## References

Abel GA, Barclay ME, Payne RA (2016). “Adjusted indices of multiple
deprivation to enable comparisons within and between constituent
countries of the UK including an illustration using mortality rates.”
*BMJ open*, **6**(11), e012750.

## Examples

``` r

if (FALSE) { # \dontrun{

data_2001 <- read_2001()

data_2001 <- clean_demographic(data = data_2001)

} # }
```
