# Economic status

Process the data on employment and occupation.

## Usage

``` r
clean_economic_status(data)
```

## Arguments

- data:

  Data table - the Health Survey for England dataset.

## Value

- employ2cat: "employed", "unemployed" (in paid work or not)

- nssec3_lab: "Managprof", "Intermediate", "Routinemanual", "Other".
  Social class/occupation based on the NS-SEC system. A four level
  variable for managerial and professional occupations, intermediate
  occupations and routine and manual occupations. The fourth level is
  'other' that includes anyone (young/old/unemployed) who do not have an
  occupation.

- social_grade: "ABC1", "C2DE". 2 level social grade classification.

- man_nonman: "Manual", "Non-manual", "Other"

- activity_lstweek: "Managprof" (employed), "Intermediate" (employed),
  "Routinemanual" (employed), "Unemployed", "In education", "Looking
  after home or family", "Sickness, injury or disability", "Retired"

## Details

First apply the function \[hseclean::clean_age()\] to the data because
this function uses the age variable.

The issues around using occupation-based social classifications for
social survey research are discussed by Connelly et al. (2016) . They
advise using a range of alternative measures, but not creating new
measures beyond what is already established.

The classifications considered are:

- Employed / in paid work or not.

- The [NS-SEC
  measure](https://www.ons.gov.uk/methodology/classificationsandstandards/otherclassifications/thenationalstatisticssocioeconomicclassificationnssecrebasedonsoc2010),
  which was constructed to measure the employment relations and
  conditions of occupations (i.e. it classifies people based on their
  employment occupation). It is therefore not that good at classifying
  people who are not employed for various reasons.

- The [NRS social grade
  system](https://humanrights.brightblue.org.uk/blog-1/2016/5/6/measuring-social-class).
  This measure is the one used in the Tobacco and Alcohol Toolkit
  studies, but is not reported in the Health Survey for England. We
  create this variable by recategorising the NS-SEC 8 level variable.
  This is important to facilitate the link of analysis to the Toolkit
  Study.

- Manual vs. non-manual occupation. In the 2017 Tobacco control plan for
  England, there was a specific target to reduce the difference in rates
  of smoking between people classified with a manual or non-manual
  occupation. We create this variable from the 3 level NS-SEC
  classification by grouping Managerial and professional with
  intermediate occupations to give the non-manual group.

- Economic status - retired / employed / unemployed.

- Activity status for last week that adds more detail such as 'in
  education' and 'looking after home or family'.

## References

Connelly R, Gayle V, Lambert PS (2016). “A Review of occupation-based
social classifications for social survey research.” *Methodological
Innovations*, **9**. ISSN 2059-7991 2059-7991.
[doi:10.1177/2059799116638003](https://doi.org/10.1177/2059799116638003)
.

## Examples

``` r

if (FALSE) { # \dontrun{

data <- read_2016(root = "/Volumes/Shared/")

data <- clean_economic_status(data = data)

} # }
```
