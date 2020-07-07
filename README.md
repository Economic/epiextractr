# epiextractr

<!-- badges: start -->
<!-- badges: end -->

epiextractr makes it easy to use the [EPI microdata extracts](https://microdata.epi.org/) in R.

## Example
Load all variables in the 2018-2019 EPI CPS ORG extracts:
``` r
library(epiextractr)
load_cps(years = 2018:2019, sample = "org")
```

Load a selection of variables from the 2019 EPI Basic CPS extracts:
``` r
load_cps(years = 2019, 
         sample = "basic", 
         variables = c("basicwgt", "female", "hispanic"))
```

## Installation and usage

### 1. Install the package
The best way to install the package is using drat. drat allows you to update non-CRAN packages via `update.packages()`. If you don't have drat already, first

```r
install.packages("drat")
```

Then add the EPI drat repo and install the package
```r
drat:::add("Economic")
install.packages("epiextractr")
```

Alternatively if you want to update the package manually you can install the current version from GitHub via devtools 
``` r
devtools::install_github("economic/epiextractr")
```

### 2. Download the microdata
Use `download_cps()` or just download the data from https://microdata.epi.org.

### 3. Use the package
#### Basic analysis
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

#### Load monthly files
The EPI CPS extracts are available as annual files, except when there is not a full calendar year of data. When only monthly files are available, you can use the months option:

```r
cps_2020 <- load_cps(years = 2020, sample = "org", months = 1:5)
```

And then you can combine these data with prior years with your favorite binding command, like 

```r
load_cps(years = 2018:2019, sample = "org") %>% bind_rows(cps_2020)
```
