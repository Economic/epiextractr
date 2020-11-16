# epiextractr

<!-- badges: start -->
<!-- badges: end -->

epiextractr makes it easy to use the [EPI microdata extracts](https://microdata.epi.org/) in R.

## Example
Load all variables in the 2018-2019 EPI CPS ORG extracts:
``` r
library(epiextractr)
load_cps("org", 2018:2019)
```

Load a selection of variables from the 2019 EPI Basic CPS extracts:
``` r
load_cps("basic", 2019, basicwgt, female, hispanic)
```

## Installation and basic usage

First, install the current version of the package from GitHub via devtools 
``` r
devtools::install_github("economic/epiextractr")
```
Then download the CPS microdata using `download_cps()`. For example,
``` r
download_cps("org", "C:\data\cps\")
```
will download the latest EPI CPS ORG extracts from https://microdata.epi.org and place them in `C:\data\cps\`.
After the data is downloaded, load a selection of CPS data for your analysis:
```r
load_cps("org", 2000:2019, year, orgwgt, wage, wbho)
```

### More examples
#### Calculating employment rates by year and race
Calculate annual employment-to-population ratios by race/ethnicity from the 2010-2019 Basic CPS using tidyverse functions:
``` r
library(tidyverse)
load_cps("basic",
         1989:2019,
         year, basicwgt, age, wbhao, emp) %>%
  filter(age >= 16) %>%
  group_by(year, wbhao) %>%
  summarize(value = weighted.mean(emp, w = basicwgt)) %>%
  mutate(wbhao = str_to_lower(as.character(haven::as_factor(wbhao)))) %>%
  pivot_wider(year, names_from = wbhao)
```

