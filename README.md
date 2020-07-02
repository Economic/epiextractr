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
library(epiextractr)
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

### Loading specific months
One current deficiency of `load_cps()` is that it pulls data from annual files, so it can't easily to grab data that is only available in monthly files. To get around that, commandeer the `epiextractr:::read_single_year()` function to grab individual months.

For example, to load January 2018 - May 2020 ORG data, try something like

``` r
cps <- load_cps(years = 2018:2019, sample = "org", variables = c("year", "month", "orgwgt", "age", "union"))
cps2020 <- map_df(1:5,
                  ~ epiextractr:::read_single_year(
                    paste0(2020, "_", .),
                    sample = "org",
                    variables = c("year", "month", "orgwgt", "age", "union"),
                    extracts_dir = "/data/cps/org/epi"))
bind_rows(cps, cps2020)
```

