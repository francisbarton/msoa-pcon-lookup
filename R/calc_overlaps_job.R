library(here)
library(dplyr)
library(purrr)
library(sf)



source(here("R/scan_local_constituencies.R"))


# if each MSOA loop takes 1s, this will take 2h, so run it as an
# RStudio job!!!

msoa_pcon_lookup <- msoa_bounds %>%
  # slice_sample(n = 5) %>% # for testing
  split(.$lad20cd) %>%
  map(
    ~ split(., .$msoa11cd) %>%
      map_df(~ scan_local_constituencies(., msoa_centroids, pcon_bounds))
  )
