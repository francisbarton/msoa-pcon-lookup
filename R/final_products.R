# Do the calculations of overlap etc --------------------------------------

# see calc_overlaps_job.R for msoa_pcon_lookup

full_msoa_pcon_lookup <- msoa_pcon_lookup %>%
  purrr::reduce(dplyr::bind_rows) %>%
  dplyr::arrange(msoa11cd, desc(contains_msoa_centroid)) %>%
  dplyr::add_count(msoa11cd, name = "cons_overlapped", sort = TRUE)

full_msoa_pcon_lookup %>%
  write_csv(here("full_msoa_pcon_lookup.csv"))


full_msoa_pcon_lookup %>%
  add_count(msoa11cd, wt = intersect_pct) %>%
  filter(n > 100)

# add in filter to get rid of areas with <5% intersects
# and round up the respective >95% areas to 100%
