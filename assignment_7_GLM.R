# Assignment 7 - GLM

library(tidyverse)

# To make this assignment doable, I am using a new dataset with count data. This dataset was taken from the same location (Gaspesie) but instead of looking at water quality measures, it counts how many macroinvertebrates of different species were found at each site over a 6 year span
# This dataset is massive, with over a thousand entries, so I am going to trim it down for the sake of this assignment to include only Epeorus (a mayfly genus) counts from 2023. My thesis project actually involves the Epeorus, and I noticed an interesting trend during collection where they were more sparse in the more highly defoliated site. My thesis wasn't looking at invertebrate counts, so this stayed as just an observation and was not tested, so I am curious if there is a correlation. 

inverts0 <- readRDS("inverts.RDS")

# I am also going to get rid of the extra taxonomical columns to keep just the info needed for this assignment

inverts1 <- subset(inverts0, select = c(
  "Genus and Species", "site",
  "year", "count"
))

# Some genius decided to have the column name be multiple words, so lets fix that

names(inverts1)[names(inverts1) == "Genus and Species"] <- 'genus_and_species'

# Lets keep just the epeorus samples from 2023

epeorus_2023 <- inverts1 %>%
  filter(genus_and_species == "Epeorus") %>%
  filter(year == "2023")

# Perfect. Now, just site by itself isn't overly helpful, so I am going to add a column to show the level of defoliation at each site. 

