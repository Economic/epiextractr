# Download EPI CPS extracts data

Download the EPI CPS extracts to your local machine

## Usage

``` r
download_cps(sample, extracts_dir = NULL, overwrite = FALSE)
```

## Arguments

- sample:

  CPS sample ("org", "basic", "may")

- extracts_dir:

  directory where EPI extracts should be placed

- overwrite:

  when TRUE, overwrite data

## Value

downloaded files

## Examples

``` r
if (FALSE) { # \dontrun{
download_cps(sample = "march", extracts_dir = "/data/cps")
} # }
```
