# epiextractr

<!-- badges: start -->
<!-- badges: end -->

epiextractr makes it easy to use the [EPI microdata extracts](https://microdata.epi.org/) in R.

## Installation
``` r
# Install current version from GitHub
devtools::install_github("economic/epiextractr")
```

## Examples
### Loading CPS data and basic analysis
Load all variables in the 2018-2019 EPI CPS ORG extracts:
``` r
library(epiextractr)
load_cps(years = 2018:2019, sample = "org")
```

Load a selection of variables from the 2019 EPI CPS ORG extracts:
``` r
load_cps(years = 2019, 
         sample = "org", 
         variables = c("basicwgt", "female", "hispanic"))
```

Calculate annual employment-to-population ratios by race/ethnicity from the 2010-2019 Basic CPS using tidyverse and labelled functions:
``` r
library(tidyverse)
load_cps(years = 2010:2019,
         sample = "basic",
         variables = c("year", "basicwgt", "age", "wbho", "emp")) %>%
  filter(age >= 16) %>%
  group_by(year, wbho) %>%
  summarize(epop = weighted.mean(emp, w = basicwgt)) %>%
  mutate(wbho = str_to_lower(labelled::to_character(wbho))) %>%
  pivot_wider(year, names_from = wbho, values_from = epop)
```

### Load monthly files
The EPI CPS extracts are available as annual files, except when there is not a full calendar year of data. When only monthly files are available, you can use the months option:

```r
cps_2020 <- load_cps(years = 2020, sample = "org", months = 1:5)
```

And then you can combine these data with prior years with your favorite binding command, like 

```r
load_cps(years = 2018:2019, sample = "org") %>% bind_rows(cps_2020)
```
