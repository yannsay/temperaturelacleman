## code to prepare alplakes data json
httptest2::with_mock_api({
  alplakes_call20250415 <- get_data_from_alplakes(day = "2025-04-15")
})
httptest2::with_mock_api({
  req2 <- build_alplakes_request(day= "2025-05-28", end_day = "2025-05-31")
  response2 <- req2 |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_perform()
  alplakes_call20250528 <- response2 |> convert_json_to_list()
})
usethis::use_data(alplakes_call20250415, overwrite = TRUE)

usethis::use_data(alplakes_call20250528, overwrite = TRUE)
