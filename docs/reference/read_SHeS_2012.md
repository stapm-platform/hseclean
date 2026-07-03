# Read Scottish Health Survey 2012

Reads and does basic cleaning on the Scottish Health Survey 2012.

## Usage

``` r
read_SHeS_2012(
  root = "X:/ScHARR/PR_Consumption_TA/HSE/Scottish Health Survey (SHeS)/",
  file = "SHeS 2012/UKDA-7417-tab/tab/shes12i_archive_v3.tab"
)
```

## Arguments

- root:

  Character - the root directory.

- file:

  Character - the file path and name.

## Value

Returns a data table. Note that:

- Missing data ("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0",
  "N/A") is replace with NA, -8 ("don't know") is also missing.

- All variable names are converted to lower case.

- Each data point is assigned a weight of 1 as there is no weight
  variable supplied.

- A single sampling cluster is assigned.

- The probabilistic sampling unit have the year appended to them.

## Details

The Scottish Health Survey is designed to yield a representative sample
of the general population living in private households in Scotland every
year.

MISSING VALUES

- -1 Not applicable: Used to signify that a particular variable did not
  apply to a given respondent usually because of internal routing. For
  example, men in women only questions.

- -2 Schedule not applicable: Used mainly for variables on the
  self-completions when the respondent was not of the given age range,
  also used for children without legal guardians in the home who could
  not participate in the nurse schedule.

- -6 Schedule not obtained: Used to signify that a particular variable
  was not answered because the respondent did not complete or agree to a
  particular schedule (i.e. nurse schedule or selfcompletions).

- -8 Don't know, Can't say.

- -9 No answer/ Refused

## Examples

``` r

if (FALSE) { # \dontrun{

data_2012 <- read_SHeS_2012("X:/",
"ScHARR/PR_Tobacco_mup/Data/Scottish Health Survey/SHeS 2012/UKDA-7417-tab/tab/shes12i_archive_v3.tab")

} # }
```
