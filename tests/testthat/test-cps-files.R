test_that("cps_files returns correct paths for org_sample", {
  files <- cps_files("org_sample", 2023:2025)
  expect_length(files, 3)
  expect_true(all(file.exists(files)))
  expect_true(all(grepl("epi_cpsorg_sample_", files)))
  expect_s3_class(files, "cps_files")
})

test_that("cps_files errors for years with no data", {
  expect_error(cps_files("org_sample", 2000))
})

test_that("load_org_sample with cps_files matches .years", {
  files <- cps_files("org_sample", 2023:2025)
  by_files <- load_org_sample(files)
  by_years <- load_org_sample(2023:2025)
  expect_identical(by_files, by_years)
})

test_that("load_org_sample with cps_files and column selection", {
  files <- cps_files("org_sample", 2023:2025)
  by_files <- load_org_sample(files, year, month, wage)
  by_years <- load_org_sample(2023:2025, year, month, wage)
  expect_identical(by_files, by_years)
})

test_that("error when cps_files don't match sample type", {
  files <- cps_files("org_sample", 2023:2025)
  expect_error(load_basic(files), "org_sample.*files.*expected.*basic")
})

test_that("error when .years is stringified years", {
  expect_error(load_org(c("2023", "2025")), "numeric years or file paths")
})

test_that("plain character paths work after targets serialization", {
  files <- cps_files("org_sample", 2023:2025)
  plain <- unclass(files)
  attr(plain, "sample") <- NULL
  by_plain <- load_org_sample(plain)
  by_years <- load_org_sample(2023:2025)
  expect_identical(by_plain, by_years)
})
