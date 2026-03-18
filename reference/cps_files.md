# Get file paths for EPI CPS extracts

Returns file paths for the specified CPS sample and years. Useful for
targets-based workflows where file dependencies need to be tracked. The
result can be passed directly to
[`load_cps()`](https://economic.github.io/epiextractr/reference/load_cps.md)
or the
[`load_org()`](https://economic.github.io/epiextractr/reference/load_cps.md),
[`load_basic()`](https://economic.github.io/epiextractr/reference/load_cps.md),
etc. wrappers in place of `.years`.

## Usage

``` r
cps_files(
  sample,
  years,
  extracts_dir = NULL,
  .quiet = getOption("epiextractr.quiet", FALSE)
)
```

## Arguments

- sample:

  CPS sample ("org", "basic", "march", "may")

- years:

  years of CPS data (integers)

- extracts_dir:

  directory where EPI extracts are

- .quiet:

  Logical. Suppress informational messages? Defaults to
  `getOption("epiextractr.quiet", FALSE)`.

## Value

A character vector of file paths

## Examples

``` r
cps_files("org_sample", 2023:2025)
#> ! Data for year 2025 excludes October
#> [1] "/home/runner/work/_temp/Library/epiextractr/extdata/epi_cpsorg_sample_2023.feather"
#> [2] "/home/runner/work/_temp/Library/epiextractr/extdata/epi_cpsorg_sample_2024.feather"
#> [3] "/home/runner/work/_temp/Library/epiextractr/extdata/epi_cpsorg_sample_2025.feather"

# Pass directly to load functions:
load_org_sample(cps_files("org_sample", 2023:2025), year, month, wage)
#> ! Data for year 2025 excludes October
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
# Use with targets
library(tarchetypes)
tar_assign({
  org_files = cps_files("org", 2020:2025) |> tar_file()
  org_data = load_org(org_files, year, month, wage) |> tar_target()
})
} # }
```
