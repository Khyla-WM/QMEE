#Assignment 2B - Write a separate script that reads in your .rds file and does something with it: either a calculation or a plot

cleaned_streams <- readRDS("assignment_2A_data_cleaning.rds")

library(ggplot2)
library(dplyr)
library(tidyverse)

#Now that I have some idea of what is missing from each variable, I want to do my first "analysis". I am going to look at how dissolved organic carbon changed over the years using a line graph. Since I have two variables, DOC.mgL (2019-2023) and W_DOC.mgL (2022-2025), I am going to make a plot with two panels, one for each variable, to get some idea of how similar the two are and how dissolved organic carbon changed from 2019-2025

#First, I need to aggregate samples based on year and site
DOC_plot <- cleaned_streams %>%
  select(site, year, DOC.mgL, W_DOC.mgL) %>%
  pivot_longer(
    cols = c(DOC.mgL, W_DOC.mgL),
    names_to = "variable",
    values_to = "value"
  ) %>%
  filter(!is.na(value)) %>% #remove the years where there is only NA
  mutate(site_group = substr(site, 1, 1)) %>%
  group_by(site, year, variable) %>%
  summarise(
    mean_val = mean(value, na.rm = TRUE),
    sd_val = sd(value, na.rm = TRUE),
    n = sum(!is.na(value)),
    se_val = sd_val / sqrt(n),
    .groups = "drop"
  )

#Then I can make a plot
ggplot(DOC_plot, aes(x = year, y = mean_val, color = site)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_val - se_val, ymax = mean_val + se_val), width = 0.2) +
  facet_wrap(~variable, scales = "free_x") +  
  labs(
    x = "Year",
    y = "DOC (mg/L)",
    title = "Comparison of DOC variables over time by site"
  ) +
  theme_minimal()

# This shows that each site had similar values using both measurements, and shows a unexpected decline in DOC content in 2025 - may be interesting to see if this trend is observed in other nutrients

## JD: Clear and nice 2.2/3
