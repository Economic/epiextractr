
<!-- README.md is generated from README.Rmd. Please edit that file -->

# epiextractr

<!-- badges: start -->

<!-- badges: end -->

epiextractr makes it easy to use the [EPI microdata
extracts](https://microdata.epi.org/) in R.

## Example

Load a selection of variables from the 2018-2019 EPI CPS ORG extracts:

``` r
library(epiextractr)
load_org(2018:2019, year, female, wage, orgwgt)
#> Using EPI CPS ORG Extracts, Version 1.0.11
#> # A tibble: 591,270 x 4
#>     year orgwgt     female  wage
#>    <int>  <dbl>  <int+lbl> <dbl>
#>  1  2018  8544. 0 [Male]    NA  
#>  2  2018  5985. 1 [Female]  NA  
#>  3  2018  7412. 1 [Female]  20.8
#>  4  2018 16209. 1 [Female]  10  
#>  5  2018  6954. 1 [Female]  25  
#>  6  2018 10195. 1 [Female]   9.5
#>  7  2018  8260. 0 [Male]    17  
#>  8  2018  8544. 0 [Male]    NA  
#>  9  2018  5985. 1 [Female]  NA  
#> 10  2018  4852. 1 [Female]  NA  
#> # … with 591,260 more rows
```

## Installation and basic usage

First, install the current version of the package from GitHub via
devtools

``` r
devtools::install_github("economic/epiextractr")
```

Then download the CPS microdata using `download_cps()`. For example,

``` r
download_cps("org", "C:\data\cps")
```

will download the latest EPI CPS ORG extracts from
<https://microdata.epi.org> and place them in the directory
`C:\data\cps`.

After the data is downloaded, load a selection of CPS data for your
analysis:

``` r
load_cps("org", 2000:2019, year, orgwgt, wage, wbho, .extracts_dir = "C:\data\cps")
```

See `vignette("epiextractr")` for more examples.
