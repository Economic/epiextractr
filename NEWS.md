# epiextractr 0.11.1
* normalize `cps_files()` file name expansion and print output

# epiextractr 0.11.0
* add `.quiet` argument to `load_cps()`, `load_org()`, `load_basic()`, `load_may()`, `load_org_sample()`, and `cps_files()` to suppress informational messages
* support global option `options(epiextractr.quiet = TRUE)` to silence messages for an entire session

# epiextractr 0.10.0
* add `cps_files()` to return file paths for CPS extracts, enabling targets-based workflows
* `load_org()`, `load_basic()`, `load_may()`, and other `load_X()` functions now accept file paths from `cps_files()` in place of `.years`

# epiextractr 0.9.3
* add note about data missing for October 2025 to `load_X()` output

# epiextractr 0.9.2
* fix `cps_citation()` to use correct year

# epiextractr 0.9.1
* update example data to increase compatibility with new `arrow` package

# epiextractr 0.9.0
* add example data "org_sample" available through `load_cps()` and `load_org_sample()`

# epiextractr 0.8.2
* fix DESCRIPTION imports warning to make r-universe friendly

# epiextractr 0.8.1
* if exists respect user-specified column order in `load_X`

# epiextractr 0.8.0
* added `load_X` functions for given CPS sample `X`
* added version/citation retrieval functions

# epiextractr 0.7.0
* add support for tidy selection syntax of variables

# epiextractr 0.6.0

* improve monthly file extraction
* add extract version metadata and version checking

# epiextractr 0.5.0

* Updated to use arrow 2.0.

# epiextractr 0.4.0

* Added percentages to one- and two-way cross tabulations
* Use environment variables for default data locations

# epiextractr 0.3.0

* Added crosstab utility

# epiextractr 0.2.0

* Added ability to extract monthly files
* Added download_cps()

# epiextractr 0.1.0

* The beginning!
