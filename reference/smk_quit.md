# Quitting smoking **\[experimental\]**

Cleans the data on the motivation to quit smoking and the use of
support.

## Usage

``` r
smk_quit(data)
```

## Arguments

- data:

  Data table - the Health Survey for England data.

## Value

Returns an updated data table with:

- giveup_smk - whether a current smoker wants to quit smoking (yes, no).

## Details

Only tested on England data Use of support not currently incorporated

## Examples

``` r

if (FALSE) { # \dontrun{

data <- read_2001()
data <- smk_quit(data)

} # }
```
