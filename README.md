
<!-- README.md is generated from README.Rmd. Please edit that file -->

# epiextractr

<!-- badges: start -->
<!-- badges: end -->

epiextractr makes it easy to use the [EPI microdata
extracts](https://microdata.epi.org/) in R.

## Example

Load a selection of variables from the 2019-2021 EPI CPS ORG extracts:

``` r
library(epiextractr)
load_org(2019:2021, year, female, wage, orgwgt)
#> Using EPI CPS ORG Extracts, Version 1.0.55
#> # A tibble: 824,963 × 4
#>     year female      wage orgwgt
#>    <int> <int+lbl>  <dbl>  <dbl>
#>  1  2019 1 [Female] 14    11367.
#>  2  2019 1 [Female] 20.9   6541.
#>  3  2019 0 [Male]    7.65  6327.
#>  4  2019 0 [Male]    7.65  6327.
#>  5  2019 1 [Female] 10    11262.
#>  6  2019 1 [Female] 28.8   7867.
#>  7  2019 1 [Female] 11    11262.
#>  8  2019 0 [Male]   NA     7943.
#>  9  2019 1 [Female] NA     6092.
#> 10  2019 0 [Male]   NA     7738.
#> # ℹ 824,953 more rows
```

## Installation and basic usage

First, install the current version of the package from R-Universe:

``` r
install.packages("epiextractr", repos = c("https://economic.r-universe.dev", "https://cloud.r-project.org"))
```

Then download the CPS microdata using `download_cps()`. For example,

``` r
download_cps("org", "C:\data\cps")
```

will download the latest EPI CPS ORG extracts in .feather format from
<https://microdata.epi.org> and place them in the directory
`C:\data\cps`.

After the data is downloaded, load a selection of CPS data for your
analysis:

``` r
load_cps("org", 2000:2019, year, orgwgt, wage, wbho, .extracts_dir = "C:\data\cps")
```

See `vignette("epiextractr")` for more examples.
