# Health and biometric variables

Cleans data on presence/absence of certain categories of health
condition, and on height and weight.

## Usage

``` r
clean_health_and_bio(data)
```

## Arguments

- data:

  The Health Survey for England dataset.

## Value

- Returns a variable indicating the presence/absence of each health
  condition (hse_cancer, hse_endocrine, hse_heart, hse_mental,
  hse_nervous, hse_eye, hse_ear, hse_respir, hse_disgest, hse_urinary,
  hse_skin, hse_muscskel, hse_infect, hse_blood, hse_other).

- height and weight.

- BMI (numeric)

## Details

HEATH CONDITIONS

There are a set of 15 categories of conditions that are ascertained
consistently across all years of the Heath Survey for England. These
are:

- Cancer

- Endocrine or metabolic condition

- Mental health condition

- Nervous system condition

- Eye condition

- Ear condition

- Heart or circulatory system condition

- Respiratory condition

- Digestive condition

- Genito-urinary condition

- Skin condition

- Musculo-skeletal condition

- Infectious disease

- Blood and related organs condition

- Other

HEIGHT AND WEIGHT

Height (cm) and weight (kg). Weight is estimated above 130kg. Missing
values of height and weight are replaced by the mean height and weight
for each age, sex and IMD quintile. BMI is calculated according to kg /
m^2.

## Examples

``` r

if (FALSE) { # \dontrun{

data_2001 <- read_2001()

data_2001 <- clean_health_and_bio(data = data_2001)

} # }
```
