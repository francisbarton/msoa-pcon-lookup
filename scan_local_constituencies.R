scan_local_constituencies <- function(msoa, msoa_centroids_df, pcon_df) {

  # msoa comes from splitting msoa_bounds into a list, 1 1-row sf per MSOA
  lad_code <- msoa %>%
    dplyr::pull(lad20cd)


  mutate_intersection <- function(pcon_area, msoa_area) {


    msoa_centroid <- msoa_area %>%
      sf::st_drop_geometry() %>%
      dplyr::semi_join(msoa_centroids_df, .)



    if (any(sf::st_intersects(pcon_area, msoa_area, sparse = FALSE))) {

      intersection_area <- sf::st_intersection(pcon_area, msoa_area) %>%
        sf::st_area() %>%
        as.numeric()

      contains_centroid <- sf::st_contains(pcon_area, msoa_centroid, sparse = FALSE) %>%
        any()

    } else {
      # intersection_area <- NA_integer_
      intersection_area <- 0
      contains_centroid <- FALSE
    }



    pcon_area %>%
      sf::st_drop_geometry() %>%
      dplyr::bind_cols(msoa_area, .) %>%
      sf::st_drop_geometry() %>%
      dplyr::mutate(contains_msoa_centroid = contains_centroid) %>%
      dplyr::mutate(intersect_area = intersection_area) %>%
      dplyr::mutate(intersect_pct = round(100*intersect_area/shape_area))
  }




  # find all the constituencies that overlap the MSOA's home LA
  # pcon_df is pcon_bounds
  pcon_df %>%
    dplyr::filter(lad20cd == lad_code) %>%
    dplyr::select(dplyr::starts_with("pcon")) %>%
    split(.$pcon20cd) %>%
    purrr::map_df(~ mutate_intersection(., msoa)) %>%
    # dplyr::filter(!is.na(intersect_area)) %>% # weirdly doesn't seem to work?
    # dplyr::filter(intersect_area > 0)
    dplyr::filter(intersect_pct > 0) %>% # assume tiny intersects are artifacts
    dplyr::mutate(best_fit = dplyr::case_when(
      intersect_pct == max(intersect_pct) ~ TRUE,
      TRUE ~ FALSE
    ))
}


