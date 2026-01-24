#Assignment 3 - Construct some ggplots using your data. Discuss what you are trying to show, some of the choices you made, and the reasoning for these choices

# Lets load in the cleaned streams data and set up our libraries
cleaned_streams <- readRDS("assignment_2A_data_cleaning.rds")

library(ggplot2)
library(dplyr)
## BMB: dplyr and tidyverse are part of ggplot2, this is redundant ...
library(tidyverse)

##### For my first plot, I want to directly compare the years nutrient data for the years of overlap to make sure they are comparable for later analyses. #####

# First, to remind myself of what years overlap, I am going to refer to assignment 2As graph, which informed me that:
  # DOC and W_DOC overlap for 2022 and 2023
  # DIC and W_DIC overlap for 2023
  # TP and W_TPO4 do not overlap
  # TN and W_TDN overlap for 2022 and 2023
# Second, I will subset my cleaned_streams object to include just one pair of variables at a time, otherwise the graph will be too crowded since I want to look by site to make sure no sites had substantially different values depending on data analysis method. I will start with just DOC, and can later copy/paste/alter the code to look at DIC and TN

doc_comp <- cleaned_streams %>%
  select(site, year, DOC.mgL, W_DOC.mgL) %>%
  filter(year %in% c(2022, 2023)) %>%
  pivot_longer(
    cols = c(DOC.mgL, W_DOC.mgL),
    names_to = "variable",
    values_to = "value"
  ) %>%
  filter(!is.na(value))

site_order <- c("U01", "U02", "U03", "C04", 
                "C05", "C06", "C07", "L08", 
                "L09", "L10", "L11", "L12") #I considered ordering from highest to lowest DOC, but If I want to make DIC and TN graphs later for comparison, I think putting them in numerical order makes the most sense so I don't have to search for a site on both graphs
## BMB: reasonable (this case, where someone is going to be looking up particular values, is a good exception to
## "use a third variable of interest to sort the levels")

doc_comp <- doc_comp %>% 
  mutate(site = factor(site, levels = site_order), 
         variable = recode(variable, 
                           "DOC.mgL" = "Old (2019-2023)", 
                           "W_DOC.mgL" = "New (2022-2025)"), 
         variable = factor (variable, levels = c("Old (2019-2023)", 
                                                 "New (2022-2025)")) # I chose to change the variable names to provide more context as to the difference between them - the technical differences could go in a figure caption, but I want my reader to understand the basic information needed about the two variables to understand the graph (ie, that one method replaced the other). I also chose to make the "old" box go on the left and the "new" on the right since that makes more logical sense based on how we view time. 
  )
colours <- c("Old (2019-2023)" = "#FFc067", 
             "New (2022-2025)" = "#50C878") # These colours were chosen to mimic sepia tones for old and spring/fresh green for new to automatically make the reader correlate those colours with the associated times

DOC_improved <- ggplot(doc_comp, aes(x = site, y = value, fill = variable)) +
  geom_boxplot(position = position_dodge(width = 0.8)) +
  facet_wrap(~year) +
  labs(
    x = "Site",
    y = "DOC (mg/L)",
    fill = "DOC Analysis
    Method",
    title = "Comparing DOC analysis methods by site (overlapping years only)"
  ) +
 scale_fill_manual(values = colours) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1), 
    panel.grid.minor = element_blank()
    )

print(DOC_improved)

# The choices I made accomplished the following
  # 1) By plotting both DOC measures along a common scale (in this case, on the same graph as two box plots), I made it easy to directly compare the results at each site, rather than having one graph per DOC measure and making your eyes jump around, as per Cleveland's Hierarchy. 
  # 2) Faceting by year and creating boxes around the panels made each year visually distinct, making it easier to read and avoiding clutter on a single graph
  # 3) Ordering the sites numerically, though they also have letter groupings, tells a better story as it reflects the latitudinal order of each site (which in turn plays a large role on SBW defoliation patterns), and makes more sense to our brains even if the letters come first in the name, and will make comparisons with other nutrient calculations (DIC, TN) later more intuitive. 

## BMB: consider flipping coordinates, *or* just printing the graph with a wide _aspect ratio_, to avoid
## having to rotate x-axis labels (since they're reasonably short)
## might want to override default black colour for outlier points. This is a little tricky since they use
## the 'colour' aesthetic by default. 

#### For my second graph (instead of just repeating the DOC one on the other measures), I want to look at my periphyton data. ####

# I am curious if the total periphyton mass is substantially different across sites and whether the total periphyton mass changes over the years. To accomplish this, I am going to make a line graph Where each line is the periphyton mass of a single site, the X axis is year, and the Y axis is periphyton mass. I will be using 2021-2025 data since 2019 is substantially NA and 2020 is all NA. 

periphyton_plot <- cleaned_streams %>%
  select(site, year, total.ug.cm2) %>%
  filter(year %in% c(2021, 2022, 2023, 2024, 2025)) %>%
  group_by(site, year) %>%
  summarise(
    mean_val = mean(total.ug.cm2, na.rm = TRUE),
    se_val = sd(total.ug.cm2, na.rm = TRUE) / sqrt(sum(!is.na(total.ug.cm2))),
    .groups = "drop"
  )  ## BMB: use .by ? if you're going to be calculating SE regularly, set up a 'utils.R' file?

site_order <- periphyton_plot %>%
  group_by(site) %>%
  summarise(avg_mass = mean(mean_val, na.rm = TRUE)) %>%
  arrange(desc(avg_mass)) %>%
  pull(site)
periphyton_plot <- periphyton_plot %>%
  mutate(site = factor(site, levels = site_order))

ggplot(periphyton_plot, aes(x = year, y = mean_val, color = site)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 1.2) +
  geom_errorbar(aes(ymin = mean_val - se_val, ymax = mean_val + se_val), width = 0.1, linewidth = 0.7) +
  labs(
    x = "Year",
    y = "Total Periphyton Mass (µg/cm2)",
    title = "Comparison of Periphyton mass over time by site",
    color = "Site"
  ) +
  theme_bw()

# This graph also uses some of the fundamentals, such as keeping all the sites on the same graph to compare between them, and ordering the sites in the legend so they correspond to the order of periphyton biomass reflected in the graph. There were some issues, such as not being able to clearly see the colours of the lines, so I made them thicker but not so thick that they made the graph more crowded. I considered using hues instead of 14 different colours, since the Rausman video highlighted that hues can be more useful, however 14 hues were also too similar to tell apart
## BMB: identifying 14 colours by category is going to be hard no matter what you do. It helps that the
## legend/factor levels are in a sensible order. One possibility would be to facet by site first letter (U, C, L:
## I'm not sure what these denote), so that each panel would have fewer subsites to compare

# I am going to repeat this with a facet for the different periphyton components (cyanobacteria, green algae, diatoms)

peri_sep <- cleaned_streams %>%
  select(site, year, cyano.ug.cm2, green.ug.cm2, diat.ug.cm2) %>%
  pivot_longer(
    cols = c(cyano.ug.cm2, green.ug.cm2, diat.ug.cm2),
    names_to = "variable",
    values_to = "value"
  ) %>%
  filter(year %in% c(2021, 2022, 2023, 2024, 2025)) %>%
  mutate(site_group = substr(site, 1, 1)) %>%
  group_by(site, year, variable) %>%
  summarise(
    mean_val = mean(value, na.rm = TRUE),
    sd_val = sd(value, na.rm = TRUE),
    n = sum(!is.na(value)),
    se_val = sd_val / sqrt(n),
    .groups = "drop"
  )

peri_labels <- c("cyano.µg.cm2" = "Cyanobacteria", 
                 "diat.µg.cm2" = "Diatoms", 
                 "green.µg.cm2" ="Green Algae")

peri_site_order <- peri_sep %>%
  group_by(site) %>%
  summarise(total_mass = sum(mean_val, na.rm = TRUE)) %>%
  arrange(desc(total_mass)) %>%
  pull(site)
peri_sep <- peri_sep %>%
  ## BMB: could use across()
  mutate(site = factor(site, levels = peri_site_order))


ggplot(peri_sep, aes(x = year, y = mean_val, color = site)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.2) +
  geom_errorbar(aes(ymin = mean_val - se_val, ymax = mean_val + se_val), width = 0.1, linewidth = 0.7) +
  facet_wrap(~variable, labeller = labeller(variable = peri_labels)) +
  labs(
    x = "Year",
    y = "Periphyton Mass (µg/cm2)",
    title = "Comparison of Periphyton mass over time by site",
    color = "Site"
  ) +
  theme_bw() +
  scale_y_log10()

## BMB: adding a log scale helps a little bit ...

# These have all the same components as the previous, but we have faceted the different types of periphyton. I did originally have scales = free_y so that we could see more details within each type of periphyton (for example, its hard to discern what site is higher in the cyanobacteria panel since it is all at the bottom), but then decided to have the y axis fixed so you could compare the types of periphyton to each other. With free_y, it would have been a lot harder to see that diatoms are far more mass than cyanobacteria or green algae, even if it is hard to make out the mass of lines at the bottom of the cyanobacteria and algae panels. 

## mark: 2.2
