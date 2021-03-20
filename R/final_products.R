# Do the calculations of overlap etc --------------------------------------

# see calc_overlaps_job.R for msoa_pcon_lookup

library(dplyr)

full_msoa_pcon_lookup <- msoa_pcon_lookup %>%
  purrr::reduce(bind_rows) %>%
  arrange(msoa11cd, desc(contains_msoa_centroid)) %>%
  add_count(msoa11cd, name = "cons_overlapped", sort = TRUE)

full_msoa_pcon_lookup %>%
  write_csv(here("full_msoa_pcon_lookup.csv"))


rounded <- full_msoa_pcon_lookup %>%
  # if only 1 constituency is overlapped then by rights the overlap %
  # should always be 100%. Intervene to fix this where not the case
  # and slightly reduce our number of headaches below:
  mutate(across(intersect_pct, ~ case_when(
    cons_overlapped == 1 ~ 100,
    TRUE ~ .
  ))) %>%
  mutate(intersect_pct2 = round(100*intersect_area/shape_area, 1)) %>%
  mutate(intersect_pct2_fl = floor(intersect_pct2)) %>%
  mutate(intersect_pct2_rd = janitor::round_half_up(intersect_pct2)) %>%
  mutate(intersect_pct2_cl = ceiling(intersect_pct2)) %>%
  add_count(msoa11cd, wt = intersect_pct, name = "orig_total") %>%
  add_count(msoa11cd, wt = intersect_pct2, name = "n2_total") %>%
  mutate(n2_total = janitor::round_half_up(n2_total)) %>%
  add_count(msoa11cd, wt = intersect_pct2_fl, name = "floor_total") %>%
  add_count(msoa11cd, wt = intersect_pct2_rd, name = "round_total") %>%
  add_count(msoa11cd, wt = intersect_pct2_cl, name = "ceiling_total")


part1 <- rounded %>%
  filter(orig_total == 100) %>%
  select(!intersect_pct2:last_col())


part2 <- rounded %>%
  filter(!orig_total == 100) %>%
  filter(n2_total == 100) %>%
  mutate(intersect_pct = janitor::round_half_up(intersect_pct2)) %>%
  select(!intersect_pct2:last_col())

part3 <- rounded %>%
  filter(!orig_total == 100) %>%
  filter(!n2_total == 100) %>%
  filter(ceiling_total == 100) %>%
  mutate(intersect_pct = intersect_pct2_cl) %>%
  select(!intersect_pct2:last_col())

part4 <- rounded %>%
  filter(!orig_total == 100) %>%
  filter(!n2_total == 100) %>%
  filter(!ceiling_total == 100) %>%
  # just going to do these by hand :-|
  mutate(intersect_pct = c(71, 29, 5, 95, 56, 44, 8, 92)) %>%
  select(!intersect_pct2:last_col())


bind_rows(part1, part2, part3, part4) %>%
  select(!c("shape_area", "intersect_area")) %>%
  arrange(desc(cons_overlapped), msoa11cd, desc(intersect_pct)) %>%
  View()
  write_csv(here("smaller_corrected_msoa_pcon_lookup.csv"))
