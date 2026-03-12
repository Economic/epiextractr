library(tidyverse)

load_write_parquet = function(year) {
  file_name = paste0("epi_cpsorg_sample_", year, ".feather")
  file_name = file.path("inst", "extdata", file_name)

  vars = c(
    "year",
    "month",
    "orgwgt",
    "statefips",
    "wbho",
    "female",
    "educ",
    "wage",
    "wageotc",
    "emp",
    "lfstat"
  )

  data = epiextractr::load_org(year, all_of(vars))

  attributes(data)$label = paste("Demonstration sample", attr(data, "label"))

  arrow::write_feather(data, file_name)

  file_name
}

map(2023:2025, load_write_parquet)

# write a single monthly file for 2026 to test monthly/incomplete-year messaging
load_write_monthly = function(year, month) {
  file_name = paste0("epi_cpsorg_sample_", year, "_", month, ".feather")
  file_name = file.path("inst", "extdata", file_name)

  vars = c(
    "year",
    "month",
    "orgwgt",
    "statefips",
    "wbho",
    "female",
    "educ",
    "wage",
    "wageotc",
    "emp",
    "lfstat"
  )

  data = epiextractr::load_org(year, all_of(vars)) |>
    filter(month == !!month)

  attributes(data)$label = paste("Demonstration sample", attr(data, "label"))

  arrow::write_feather(data, file_name)

  file_name
}

load_write_monthly(2026, 1)
