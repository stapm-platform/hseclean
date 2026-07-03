# Education variables

Process the data on education.

## Usage

``` r
clean_education(data)
```

## Arguments

- data:

  Data table - the Health Survey for England dataset.

## Value

Returns an updated version of data with the new education variables:

- eduend4cat - 4 categories of when finished education,

- degree - 2 categories for degree or not.

## Details

The main education variable used is a four category description of the
age at which someone finished full-time education. The categories are:

- never went to school,

- left at 15 years or younger,

- left at 16-18,

- left at 19 years or over.

If someone was still in full time education at the time of the survey,
then if they were younger than 18 years, we assumed they would leave at
16-18, and if they were older than 18 years, we assumed they would leave
at 19 years or over.

A further education variable is also produced - which indicates whether
an individual reached a degree as their top qualification or not. Here a
degree is defined as an "NVQ4/NVQ5/Degree or equiv".

## Examples

``` r

if (FALSE) { # \dontrun{

data_2016 <- read_2016()

data_2016 <- clean_education(data = data_2016)

} # }
```
