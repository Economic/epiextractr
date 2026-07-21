# Retrieve metadata from CPS extract

Retrieve metadata from CPS extract

## Usage

``` r
cps_version(x)

cps_citation(x)

assert_cps_version(x, version)
```

## Arguments

- x:

  EPI CPS extract generated from
  [`load_cps()`](https://economic.github.io/epiextractr/reference/load_cps.md)
  functions

- version:

  String version number

## Value

`cps_version` and `cps_citation` return version or citation strings.

`assert_cps_version` returns an error when the provided version is
incorrect.

## Examples

``` r
cps_org <- load_org_sample(2023:2025)
#> ! Data for year 2025 excludes October
#> ℹ Using Demonstration sample EPI CPS ORG Extracts, Version 2026.7.8
cps_citation(cps_org)
#> ℹ You can cite `cps_org` as follows:
#> [1] "Economic Policy Institute. 2026. Current Population Survey Extracts, Version 2026.7.8, https://microdata.epi.org."
cps_version(cps_org)
#> [1] "2026.7.8"
```
