library(here)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(janitor)
library(sf)
library(jogger)


# Source data URLs --------------------------------------------------------

# https://geoportal.statistics.gov.uk/datasets/ward-to-westminster-parliamentary-constituency-to-local-authority-district-to-upper-tier-local-authority-december-2020-lookup-in-the-united-kingdom-v2/data
pcon_lad_url <- "https://opendata.arcgis.com/datasets/063ccaa43b9a4f4281b3ad803c1ed2e8_0.csv"


# https://geoportal.statistics.gov.uk/datasets/output-area-to-lower-layer-super-output-area-to-middle-layer-super-output-area-to-local-authority-district-december-2020-lookup-in-england-and-wales
msoa_lad_url <- "https://opendata.arcgis.com/datasets/65664b00231444edb3f6f83c9d40591f_0.csv"


# https://visual.parliament.uk/msoanames
hocl_msoa_names_url <- "https://visual.parliament.uk/msoanames/static/MSOA-Names-Latest.csv"







# MSOA and Constituency boundary data -------------------------------------

# https://geoportal.statistics.gov.uk/datasets/westminster-parliamentary-constituencies-december-2019-boundaries-uk-bgc/
pcon_bounds_url <- "https://opendata.arcgis.com/datasets/937997590f724a398ccc0100dbd9feee_0.geojson"


# https://geoportal.statistics.gov.uk/datasets/middle-layer-super-output-areas-december-2011-boundaries-generalised-clipped-bgc-ew-v3
msoa_bounds_url <- "https://opendata.arcgis.com/datasets/abfccdf1071c43dd981a49eb7da13d2b_0.geojson"


# https://geoportal.statistics.gov.uk/datasets/middle-layer-super-output-areas-december-2011-population-weighted-centroids/
msoa_centroids_url <- "https://opendata.arcgis.com/datasets/b0a6d8a3dc5d4718b3fd62c548d60f81_0.geojson"




# Build MSOA table --------------------------------------------------------

msoa_lad <- read_csv(msoa_lad_url) %>%
  clean_names() %>%
  select(starts_with(c("msoa", "lad", "rgn"))) %>%
  distinct()

msoa_names <- read_csv(hocl_msoa_names_url) %>%
  clean_names() %>%
  select(!laname)


msoa_lad <- msoa_names %>%
  left_join(msoa_lad)



# Build PCON table --------------------------------------------------------

pcon_lad <- read_csv(pcon_lad_url) %>%
  clean_names() %>%
  filter(across(wd20cd, ~ str_detect(., "^[E|W]"))) %>%
  select(starts_with(c("pcon", "lad"))) %>%
  distinct() %>%
  mutate(across(pcon20nm, ~ case_when(
    . == "Birmingham,  Selly Oak" ~ "Birmingham, Selly Oak", # minor fix
    TRUE ~ .
  )))



# Build sf (geographical) tibbles -----------------------------------------

pcon_bounds <- st_read(pcon_bounds_url) %>%
  clean_names() %>%
  select(starts_with(c("pcon"))) %>%
  rename_with(~ str_replace_all(., "^pcon19", "pcon20")) %>%
  mutate(across(pcon20nm, ~ case_when(
    . == "Weston-Super-Mare" ~ "Weston-super-Mare", # fix ONS src data
    . == "Ynys Mon" ~ "Ynys Môn", # fix ONS src data for join success
    TRUE ~ .
  ))) %>%
  inner_join(pcon_lad)



msoa_bounds <- st_read(msoa_bounds_url) %>%
  clean_names() %>%
  # select(starts_with(c("msoa", "bng", "shape_area"))) %>%
  select(starts_with(c("msoa", "shape_area"))) %>%
  # rename_with(~ str_replace_all(., "^bng", "centroid")) %>%
  left_join(msoa_lad) %>%
  # dplyr::relocate(starts_with(c("centroid", "shape")), .after = rgn20nm)
  dplyr::relocate(shape_area, .after = rgn20nm)



# population-weighted centroids as opposed to pure geo centroids
msoa_centroids <- st_read(msoa_centroids_url) %>%
  clean_names() %>%
  select(starts_with("msoa")) %>%
  left_join(msoa_lad)



# Do the calculations of overlap etc --------------------------------------

# see calc_overlaps_job.R

msoa_pcon_lookup %>%
  write_csv(here("msoa_pcon_lookup.csv"))

