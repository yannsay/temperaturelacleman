testthat::test_that("build_alplakes_request creates correct URL with custom parameters", {
  # Format the current date in UTC for testing
  test_date <- "2025-04-15"
  test_lat <- "46.45"
  test_lon <- "6.35"

  # Calculate expected timestamps in UTC
  start_time_cet <- as.POSIXct(paste(test_date, "00:00:00"), tz = "CET")
  end_time_cet <- as.POSIXct(paste(test_date, "23:00:00"), tz = "CET")
  expected_start <- format(start_time_cet, "%Y%m%d%H%M", tz = "UTC")
  expected_end <- format(end_time_cet, "%Y%m%d%H%M", tz = "UTC")

  req <- build_alplakes_request(test_date, test_lat, test_lon)

  # Extract URL parts
  url_parts <- strsplit(req$url, "/")[[1]]

  # Verify the URL structure
  expect_equal(url_parts[length(url_parts)-3], expected_start)
  expect_equal(url_parts[length(url_parts)-2], expected_end)
  expect_equal(url_parts[length(url_parts)-1], test_lat)

  # The last part will include the query string, need to extract just the longitude
  last_part <- strsplit(url_parts[length(url_parts)], "\\?")[[1]][1]
  expect_equal(last_part, test_lon)
})

testthat::test_that("build_alplakes_request warns for current or future weeks", {
  # Today's date
  today <- Sys.Date()

  # A date in the current week
  current_week_date <- today

  # Expect a warning for current week
  expect_warning(build_alplakes_request(current_week_date),
                 "AlpLakes API likely doesn't have data available")

  # A date in the future
  future_date <- today + 30

  # Expect a warning for future date
  expect_warning(build_alplakes_request(future_date),
                 "AlpLakes API likely doesn't have data available")

  # A date in a past week (should not warn)
  past_date <- today - 30

  # No warning expected
  expect_no_warning(build_alplakes_request(past_date))
})

httptest2::with_mock_api({
  testthat::test_that("get_data_from_alplakes handles successful API response", {

    # Mock the API response for a successful request
    expected_results <- readRDS(test_path("fixtures", "get_data_from_alplakes_2025-04-15.rds"))
    test_date <- "2025-04-15"
    result <- get_data_from_alplakes(test_date)

    expect_equal(result, expected_results)

  })
})


