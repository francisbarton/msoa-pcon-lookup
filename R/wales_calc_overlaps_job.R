library(here)

source(here("R/data.R"))
source(here("R/scan_local_constituencies.R"))

wales_msoas <- msoa_bounds

wales_msoa_pcon_lookup <- wales_msoas %>%
  split(.$msoa11cd) %>%
  map_df(~ scan_local_constituencies(., msoa_centroids, pcon_bounds))


