httptest2::with_mock_dir("test_api",{
  test_that("we can collect data", {
    test_request <-  get_data_from_alplakes("20240609","20240615")
    expect_true(test_request$status == 200)

    test_request_error <-  get_data_from_alplakes("20240609","2024")
    expect_true(test_request_error$status != 200)

  })

})

httptest2::with_mock_dir("test_api",{
  test_that("Conversion to json list works correctly", {
      test_request <-  get_data_from_alplakes("20240609","20240615")
      test_json_to_list <- test_request |> convert_json_to_list()

      expected_output <- readRDS("tests/testthat/fixtures/json_to_list_output.RDS")
      expect_equal(test_json_to_list, expected_output)

      test_request_error <-  get_data_from_alplakes("20240609","2024")
      test_error_json_to_list <- test_request_error |> convert_json_to_list()
      expect_equal(test_error_json_to_list, alplakes_json_20240615)})
})

