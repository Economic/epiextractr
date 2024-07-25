library(tidyverse)

load_write_parquet = function(year) {
  file_name = paste0("epi_cpsorg_sample_", year, ".feather")
  file_name = file.path("inst", "extdata", file_name)

  vars = c(
    "year", "month", "orgwgt",
    "statefips", "wbho", "female", "educ",
    "wage", "wageotc",
    "emp", "lfstat"
  )

  data = epiextractr::load_org(year, all_of(vars))

  attributes(data)$label = paste("Demonstration sample", attr(data, "label"))

  arrow::write_feather(data, file_name)

  file_name
}

map(2019:2023, load_write_parquet)
