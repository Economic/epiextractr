# Changelog

## epiextractr 0.11.0

- add `.quiet` argument to
  [`load_cps()`](https://economic.github.io/epiextractr/reference/load_cps.md),
  [`load_org()`](https://economic.github.io/epiextractr/reference/load_cps.md),
  [`load_basic()`](https://economic.github.io/epiextractr/reference/load_cps.md),
  [`load_may()`](https://economic.github.io/epiextractr/reference/load_cps.md),
  [`load_org_sample()`](https://economic.github.io/epiextractr/reference/load_cps.md),
  and
  [`cps_files()`](https://economic.github.io/epiextractr/reference/cps_files.md)
  to suppress informational messages
- support global option `options(epiextractr.quiet = TRUE)` to silence
  messages for an entire session

## epiextractr 0.10.0

- add
  [`cps_files()`](https://economic.github.io/epiextractr/reference/cps_files.md)
  to return file paths for CPS extracts, enabling targets-based
  workflows
- [`load_org()`](https://economic.github.io/epiextractr/reference/load_cps.md),
  [`load_basic()`](https://economic.github.io/epiextractr/reference/load_cps.md),
  [`load_may()`](https://economic.github.io/epiextractr/reference/load_cps.md),
  and other `load_X()` functions now accept file paths from
  [`cps_files()`](https://economic.github.io/epiextractr/reference/cps_files.md)
  in place of `.years`

## epiextractr 0.9.3

- add note about data missing for October 2025 to `load_X()` output

## epiextractr 0.9.2

- fix
  [`cps_citation()`](https://economic.github.io/epiextractr/reference/cps_metadata.md)
  to use correct year

## epiextractr 0.9.1

- update example data to increase compatibility with new `arrow` package

## epiextractr 0.9.0

- add example data “org_sample” available through
  [`load_cps()`](https://economic.github.io/epiextractr/reference/load_cps.md)
  and
  [`load_org_sample()`](https://economic.github.io/epiextractr/reference/load_cps.md)

## epiextractr 0.8.2

- fix DESCRIPTION imports warning to make r-universe friendly

## epiextractr 0.8.1

- if exists respect user-specified column order in `load_X`

## epiextractr 0.8.0

- added `load_X` functions for given CPS sample `X`
- added version/citation retrieval functions

## epiextractr 0.7.0

- add support for tidy selection syntax of variables

## epiextractr 0.6.0

- improve monthly file extraction
- add extract version metadata and version checking

## epiextractr 0.5.0

- Updated to use arrow 2.0.

## epiextractr 0.4.0

- Added percentages to one- and two-way cross tabulations
- Use environment variables for default data locations

## epiextractr 0.3.0

- Added crosstab utility

## epiextractr 0.2.0

- Added ability to extract monthly files
- Added download_cps()

## epiextractr 0.1.0

- The beginning!
