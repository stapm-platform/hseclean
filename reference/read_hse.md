# Read HSE data **\[deprecated\]**

Reads and does basic cleaning of a selected year of the Health Survey
for England.

## Usage

``` r
read_hse(year, root = c("X:/", "/Volumes/Shared/"))
```

## Arguments

- year:

  Character - the file path and name.

- root:

  Character - the root directory.

## Value

Returns a data table of the year of data selected.

## Examples

``` r
if (FALSE) { # \dontrun{

data_2001 <- read_hse(year = 2001, root = "X:/")
} # }
```
