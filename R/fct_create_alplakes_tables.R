#' create_alplakes_tables
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd

create_alplakes_tables <- function(alplakes_clean_data) {
  long_show_table <- alplakes_clean_data %>%
    dplyr::mutate(across(everything(), \(x) round(x,1))) %>%
    dplyr::select(profondeur, everything()) %>%
    dplyr::arrange(profondeur) %>%
    dplyr::mutate(profondeur = -profondeur)

  small_show_table <- long_show_table %>%
    dplyr::mutate(profondeur = round(profondeur)) %>%
    dplyr::filter(!duplicated(profondeur)) %>%
    dplyr::filter(profondeur %in% seq(0, -50, by = -5) )


  unique_days <- names(alplakes_clean_data)[-1] %>% lubridate::date() %>% unique() %>% as.character()
  # week_days <- unique_days %>% lubridate::date() %>% weekdays()

  long_show_table_day <- purrr::map(unique_days,
                             ~dplyr::select(long_show_table, profondeur, tidyr::contains(.x))) %>%
    purrr::set_names(unique_days)

  small_show_table_day <- purrr::map(unique_days,
                              ~dplyr::select(small_show_table, profondeur, tidyr::contains(.x))) %>%
    purrr::set_names(unique_days)

  return(list(small_show_table = small_show_table,
              long_show_table = long_show_table,
              long_show_table_day = long_show_table_day,
              small_show_table_day = small_show_table_day))
}
