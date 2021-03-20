library(here)

source(here("R/data.R"))
source(here("R/scan_local_constituencies.R"))



msoas_split <- msoa_bounds %>%
  # slice_sample(n = 5) %>% # for testing
  split(.$lad20nm)


# if each MSOA loop takes 1s, this will take 2h, so run it as an
# RStudio job!!!
msoa_pcon_lookup <- msoas_split %>%
  map(
    ~ split(., .$msoa11cd) %>%
      map_df(~ scan_local_constituencies(., msoa_centroids, pcon_bounds))
  )

