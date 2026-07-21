# epiextractr

The `epiextractr` package makes it easy to use the [EPI microdata
extracts](https://microdata.epi.org/) in R.

First download the CPS microdata using
[`download_cps()`](https://economic.github.io/epiextractr/reference/download_cps.md)
into a directory on your machine. The downloaded data will simply be
.feather files for each year of data.

For example, to download the Outgoing Rotation Group extracts into a
directory called `C:/data/cps`, try

``` r

library(epiextractr)
download_cps("org", "C:/data/cps")
```

Then you can use
[`load_org()`](https://economic.github.io/epiextractr/reference/load_cps.md)
to call a selection of years and columns:

``` r

load_org(2019:2021, year, female, wage, orgwgt, .extracts_dir = "C:/data/cps")
```

    #> # A tibble: 824,963 × 4
    #>     year orgwgt female      wage
    #>    <int>  <dbl> <int+lbl>  <dbl>
    #>  1  2019 11367. 1 [Female] 14   
    #>  2  2019  6541. 1 [Female] 20.9 
    #>  3  2019  6327. 0 [Male]    7.65
    #>  4  2019  6327. 0 [Male]    7.65
    #>  5  2019 11262. 1 [Female] 10   
    #>  6  2019  7867. 1 [Female] 28.8 
    #>  7  2019 11262. 1 [Female] 11   
    #>  8  2019  7943. 0 [Male]   NA   
    #>  9  2019  6092. 1 [Female] NA   
    #> 10  2019  7738. 0 [Male]   NA   
    #> # … with 824,953 more rows

For ease of use you can omit the `.extracts_dir` option by setting the
following environment variables equal to the directory of the extracts:

    EPIEXTRACTS_CPSBASIC_DIR
    EPIEXTRACTS_CPSORG_DIR
    EPIEXTRACTS_CPSMAY_DIR

For example, if your .Renviron file sets

    EPIEXTRACTS_CPSORG_DIR=C:/data/cps

then you can simply run

``` r

load_org(2019:2021, year, female, wage, orgwgt)
```

### More examples

#### Calculating employment rates by year and race

Calculate annual employment-to-population ratios by race/ethnicity from
the 2010-2019 Basic CPS using tidyverse functions:

``` r

library(tidyverse)
load_cps("basic", 2010:2019, year, basicwgt, wbhao, emp) %>%
  filter(basicwgt > 0) %>%
  summarize(value = weighted.mean(emp, w = basicwgt), .by = c(year, wbhao)) %>%
  mutate(name = as.character(haven::as_factor(wbhao))) %>%
  pivot_wider(id_cols = year)
```

    #> # A tibble: 10 × 6
    #> # Groups:   year [10]
    #>     year White Black Hispanic Asian Other
    #>    <int> <dbl> <dbl>    <dbl> <dbl> <dbl>
    #>  1  2010 0.595 0.523    0.590 0.601 0.501
    #>  2  2011 0.595 0.516    0.589 0.602 0.504
    #>  3  2012 0.594 0.527    0.595 0.604 0.521
    #>  4  2013 0.592 0.529    0.600 0.611 0.499
    #>  5  2014 0.594 0.540    0.612 0.607 0.519
    #>  6  2015 0.596 0.554    0.616 0.606 0.517
    #>  7  2016 0.598 0.562    0.620 0.612 0.525
    #>  8  2017 0.599 0.575    0.627 0.619 0.540
    #>  9  2018 0.601 0.583    0.632 0.619 0.538
    #> 10  2019 0.603 0.588    0.639 0.625 0.547
