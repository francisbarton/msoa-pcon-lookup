library(dplyr)


# Do the calculations of overlap etc --------------------------------------

# see calc_overlaps_job.R for creation of msoa_pcon_lookup

full_msoa_pcon_lookup <- msoa_pcon_lookup %>%
  purrr::reduce(bind_rows) %>%
  arrange(msoa11cd, desc(contains_msoa_centroid)) %>%
  add_count(msoa11cd, name = "cons_overlapped", sort = TRUE)

full_msoa_pcon_lookup %>%
  write_csv(here("full_msoa_pcon_lookup.csv"))



# try different rounding methods to get pcts to = 100 ---------------------


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



# split df into parts depending how easy to get pcts to = 100 -------------


part1 <- rounded %>%
  filter(orig_total == 100) %>%
  select(!intersect_pct2:last_col())

part2 <- rounded %>%
  filter(!orig_total == 100) %>%
  filter(n2_total == 100) %>%
  mutate(intersect_pct = round(intersect_pct2)) %>%
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


# bind the parts back together --------------------------------------------


tidy1 <- bind_rows(part1, part2, part3, part4) %>%
  select(!c("shape_area", "intersect_area")) %>%
  arrange(desc(cons_overlapped), msoa11cd, desc(intersect_pct)) %>%
  add_count(msoa11cd, wt = intersect_pct, name = "overlap_pct_total")

rm(part1, part2, part3, part4)



# more splitting to get 99s and 101s to be 100s ---------------------------

tidy2 <- tidy1 %>%
  filter(overlap_pct_total > 100) %>%
  split(.$msoa11cd) %>%
  map_df(~ mutate(., across(intersect_pct, ~ case_when(
    intersect_pct == min(intersect_pct) ~ intersect_pct - 1,
    TRUE ~ intersect_pct
  ))))

tidy3 <- tidy1 %>%
  filter(overlap_pct_total < 100) %>%
  split(.$msoa11cd) %>%
  map_df(~ mutate(., across(intersect_pct, ~ case_when(
    intersect_pct == max(intersect_pct) ~ intersect_pct + 1,
    TRUE ~ intersect_pct
  ))))

tidy4 <- tidy1 %>%
  filter(overlap_pct_total == 100)


# bind things back together again again -----------------------------------


tidy5 <- bind_rows(tidy2, tidy3, tidy4) %>%
  # get rid of the intersects that went to 0 in tidy2:
  filter(!intersect_pct == 0) %>%
  arrange(desc(cons_overlapped), msoa11cd, desc(intersect_pct)) %>%
  # nearly forgot! — got to redo counts:
  select(!c(overlap_pct_total, cons_overlapped)) %>%
  add_count(msoa11cd, name = "cons_overlapped", sort = TRUE) %>%
  add_count(msoa11cd, wt = intersect_pct, name = "overlap_pct_total")


# this is a pretty good stage to save a snapshot --------------------------


tidy5 %>%
  write_csv(here("smaller_corrected_msoa_pcon_lookup.csv"))


# just one more thing... extra rationalising, and redo count --------------


tidy6 <- tidy5 %>%
  # let's get rid of these 99:1 splits - they can't be worth keeping:
  mutate(across(intersect_pct, ~ case_when(
    cons_overlapped == 2 & intersect_pct == 99 ~ 100,
    cons_overlapped == 2 & intersect_pct == 1 ~ 0,
    TRUE ~ intersect_pct
  ))) %>%
  filter(!intersect_pct == 0) %>%
  select(!c(overlap_pct_total, cons_overlapped)) %>%
  add_count(msoa11cd, name = "cons_overlapped", sort = TRUE)

# last snapshot csv — this is what I was dreaming of when I started:
tidy6 %>%
  write_csv(here("final_tidy_compact_msoa_pcon_lookup.csv"))
