#' clean_alp_data
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd

clean_alplakes_data <- function(data_from_alplakes) {
  day_hour <- data_from_alplakes$time %>% lubridate::ymd_hms() %>% lubridate::with_tz("CET")
  dates_names <- day_hour %>% as.character() %>% stringr::str_replace_all("00:00", "00")

  data_from_alplakes$variables$temperature$data %>%
    purrr::map(~`names<-`(.x,dates_names)) %>% # name each sub list with the day and time
    `names<-`(data_from_alplakes$depth$data) %>% #name the list with the depth
    dplyr::bind_rows(.id = "profondeur") %>%
    dplyr::filter(rowSums(is.na(dplyr::across(-profondeur))) != ncol(.)-1) %>%
    dplyr::mutate(profondeur = as.numeric(profondeur))
}
