## code to prepare `alplakes_call20240615` dataset goes here
alplakes_call20240615 <- get_data_from_alplakes(start_day = "20240610",
                                                end_day = "20240616") |>
  convert_json_to_list()
usethis::use_data(alplakes_call20240615, overwrite = TRUE)
