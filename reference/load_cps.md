# Load a selection of EPI CPS extracts

Select years and variables from the EPI CPS microdata extracts. These
data must first be downloaded using
[`download_cps()`](https://economic.github.io/epiextractr/reference/download_cps.md)
or from <https://microdata.epi.org>.

## Usage

``` r
load_cps(
  .sample,
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
)

load_basic(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
)

load_may(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
)

load_org(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
)

load_org_sample(
  .years,
  ...,
  .extracts_dir = NULL,
  .version_check = TRUE,
  .quiet = getOption("epiextractr.quiet", FALSE)
)
```

## Arguments

- .sample:

  CPS sample ("org", "basic", "march", "may")

- .years:

  years of CPS data (integers), or file paths from
  [`cps_files()`](https://economic.github.io/epiextractr/reference/cps_files.md)

- ...:

  tidy selection of variables to keep

- .extracts_dir:

  directory where EPI extracts are

- .version_check:

  when TRUE, confirm data are same version

- .quiet:

  Logical. Suppress informational messages? Defaults to
  `getOption("epiextractr.quiet", FALSE)`.

## Value

A tibble of CPS microdata

## Details

All columns are selected if `...` is missing.

`.years` accepts either integer years or file paths from
[`cps_files()`](https://economic.github.io/epiextractr/reference/cps_files.md).
When file paths are passed, the files are read directly and
`.extracts_dir` is ignored.

`.extracts_dir` is required, but if NULL it will look for the
environment variables

    EPIEXTRACTS_CPSBASIC_DIR
    EPIEXTRACTS_CPSORG_DIR
    EPIEXTRACTS_CPSMAY_DIR

which could be set in your .Renviron, for example.

## Functions

- `load_cps()`: base function group

- `load_basic()`: Load CPS Basic Monthly files

- `load_may()`: Load CPS May files

- `load_org()`: Load CPS ORG files

- `load_org_sample()`: Load a demonstration sample of CPS ORG files;
  only useful for examples

## Examples

``` r
# Load all columns from the demonstration sample
load_org_sample(2023:2024)
#> ℹ Using Demonstration sample EPI CPS ORG Extracts, Version 2026.2.12
#> # A tibble: 485,818 × 11
#>     year month orgwgt statefips wbho      female   educ     wage wageotc emp    
#>    <int> <int>  <dbl> <int+lbl> <int+lbl> <int+lb> <int+l> <dbl>   <dbl> <int+l>
#>  1  2023     1  8983. 1 [AL]    2 [Black] 0 [Male] 2 [Hig…  NA      NA   0 [NIL…
#>  2  2023     1 11509. 1 [AL]    2 [Black] 0 [Male] 2 [Hig…  NA      NA   0 [NIL…
#>  3  2023     1  9589. 1 [AL]    1 [White] 0 [Male] 3 [Som…  NA      NA   0 [NIL…
#>  4  2023     1  9691. 1 [AL]    1 [White] 0 [Male] 3 [Som…  27.5    27.5 1 [Emp…
#>  5  2023     1  9856. 1 [AL]    1 [White] 0 [Male] 1 [Les…  11      11   1 [Emp…
#>  6  2023     1  8670. 1 [AL]    1 [White] 0 [Male] 2 [Hig…  NA      NA   0 [NIL…
#>  7  2023     1  9232. 1 [AL]    1 [White] 0 [Male] 5 [Adv…  NA      NA   0 [NIL…
#>  8  2023     1 15947. 1 [AL]    2 [Black] 0 [Male] 2 [Hig…  41.1    41.1 1 [Emp…
#>  9  2023     1  7429. 1 [AL]    1 [White] 1 [Fema… 2 [Hig…  NA      NA   0 [NIL…
#> 10  2023     1  7523. 1 [AL]    1 [White] 1 [Fema… 3 [Som…  NA      NA   0 [NIL…
#> # ℹ 485,808 more rows
#> # ℹ 1 more variable: lfstat <int+lbl>

# Load a selection of columns
load_org_sample(2023:2025, year, month, female, wage)
#> ! Data for year 2025 excludes October
#> ℹ Using Demonstration sample EPI CPS ORG Extracts, Version 2026.2.12
#> # A tibble: 700,029 × 4
#>     year month female      wage
#>    <int> <int> <int+lbl>  <dbl>
#>  1  2023     1 0 [Male]    NA  
#>  2  2023     1 0 [Male]    NA  
#>  3  2023     1 0 [Male]    NA  
#>  4  2023     1 0 [Male]    27.5
#>  5  2023     1 0 [Male]    11  
#>  6  2023     1 0 [Male]    NA  
#>  7  2023     1 0 [Male]    NA  
#>  8  2023     1 0 [Male]    41.1
#>  9  2023     1 1 [Female]  NA  
#> 10  2023     1 1 [Female]  NA  
#> # ℹ 700,019 more rows

# Use cps_files() for targets workflows:
org_files = cps_files("org_sample", 2023:2025)
#> ! Data for year 2025 excludes October
load_org_sample(org_files, year, month, wage)
#> ℹ Using Demonstration sample EPI CPS ORG Extracts, Version 2026.2.12
#> # A tibble: 700,029 × 3
#>     year month  wage
#>    <int> <int> <dbl>
#>  1  2023     1  NA  
#>  2  2023     1  NA  
#>  3  2023     1  NA  
#>  4  2023     1  27.5
#>  5  2023     1  11  
#>  6  2023     1  NA  
#>  7  2023     1  NA  
#>  8  2023     1  41.1
#>  9  2023     1  NA  
#> 10  2023     1  NA  
#> # ℹ 700,019 more rows

if (FALSE) { # \dontrun{
# Load real CPS ORG data (requires downloaded extracts):
load_org(2010:2019, year, month, orgwgt, female, wage)
# This is equivalent to
load_cps("org", 2010:2019, year, month, orgwgt, female, wage)
} # }
```
