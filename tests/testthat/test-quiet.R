# .quiet argument silences informational messages

test_that(".quiet = TRUE silences version message", {
  expect_no_message(
    load_org_sample(2023:2024, .quiet = TRUE)
  )
})

test_that(".quiet = FALSE (default) emits version message", {
  expect_message(
    load_org_sample(2023:2024),
    "Using.*EPI CPS"
  )
})

# Global option works

test_that("epiextractr.quiet option silences messages", {
  withr::local_options(epiextractr.quiet = TRUE)
  expect_no_message(
    load_org_sample(2023:2024)
  )
})

test_that(".quiet argument overrides global option", {
  withr::local_options(epiextractr.quiet = TRUE)
  expect_no_message(load_org_sample(2023:2024))

  withr::local_options(epiextractr.quiet = FALSE)
  expect_message(load_org_sample(2023:2024), "Using.*EPI CPS")
})

# .quiet does not suppress warnings or errors

test_that(".quiet does not suppress version conflict error", {
  a <- tibble::tibble(x = 1)
  b <- tibble::tibble(x = 2)
  attr(a, "label") <- "EPI CPS Version 1.0"
  attr(b, "label") <- "EPI CPS Version 2.0"

  expect_error(
    epiextractr:::bind_cps(list(a, b), version_check = TRUE),
    "Version conflicts"
  )
})

test_that("version conflict with version_check = FALSE warns, not errors", {
  a <- tibble::tibble(x = 1)
  b <- tibble::tibble(x = 2)
  attr(a, "label") <- "EPI CPS Version 1.0"
  attr(b, "label") <- "EPI CPS Version 2.0"

  expect_warning(
    epiextractr:::bind_cps(list(a, b), version_check = FALSE),
    "multiple, different versions"
  )
})

# Version info gated on .quiet, not .version_check

test_that("version info shows when version_check = FALSE and quiet = FALSE", {
  expect_message(
    load_org_sample(2023:2024, .version_check = FALSE, .quiet = FALSE),
    "Using.*EPI CPS"
  )
})

test_that("version info hidden when quiet = TRUE regardless of version_check", {
  expect_no_message(
    load_org_sample(2023:2024, .version_check = TRUE, .quiet = TRUE)
  )
})

# cps_files() respects .quiet

test_that("cps_files is quiet when asked", {
  expect_no_message(
    cps_files("org_sample", 2023:2024, .quiet = TRUE)
  )
})

# 2025 "excludes October" message respects .quiet

test_that("2025 exclusion message appears by default", {
  expect_message(
    load_org_sample(2025),
    "excludes October"
  )
})

test_that("2025 exclusion message silenced by .quiet", {
  expect_no_message(
    load_org_sample(2025, .quiet = TRUE)
  )
})

test_that("cps_files 2025 exclusion message silenced by .quiet", {
  expect_message(
    cps_files("org_sample", 2025),
    "excludes October"
  )
  expect_no_message(
    cps_files("org_sample", 2025, .quiet = TRUE)
  )
})

# Monthly/incomplete-year message respects .quiet

test_that("monthly data message appears for 2026 by default", {
  expect_message(
    load_org_sample(2026),
    "only includes months 1"
  )
})

test_that("monthly data message silenced by .quiet for load", {
  expect_no_message(
    load_org_sample(2026, .quiet = TRUE)
  )
})

test_that("cps_files monthly message respects .quiet", {
  expect_message(
    cps_files("org_sample", 2026),
    "only includes months 1"
  )
  expect_no_message(
    cps_files("org_sample", 2026, .quiet = TRUE)
  )
})
