#Assignment 2A: Examine the structure of the data you imported and check it for problems, making sure you understand the r classes. Make one or two plots that might help you see whether your data have any errors or anomolies - report results and fix any problems you can see

#Load in the data
## JD: Is this the downloaded version?
streams <- readRDS("streams.RDS")

#Get a basic summary to review
summary(streams)

#That is a lot of columns, most of which I will not be using for analysis (yet, at least). Lets remove a bunch of columns, keeping only the ones related to nutrient content or periphyton to help answer my biological questions. This has to be done manually because the columns are not named in a way we can filter them to my liking. 
library(dplyr)

## JD: Maybe the way you did it matches your screen layout or your excellent eyesight. I would try to write this less spread out. I'll change it just for you to see, feel free to change back
streams_subset <- subset(streams, select = c(
	"site", "year", "date.collected"
	, "DOC.mgL", "DIC.mgL", "TP.mgL", "TN.mgL"
	, "cyano.ug.cm2", "green.ug.cm2", "diat.ug.cm2", "total.ug.cm2"
	, "W_DOC.mgL", "W_DIC.mgL", "W_TPO4.mgL", "W_TDN.mgL"
))
summary(streams_subset)

#I notice the W_TDN.mgL column is coming up as a character, this is because the values are sometimes written as "xxx(<0.2 mg/L DL)" when the xxx is below that threshold. I do not need to know these are below a threshold, and want just the xxx value so this column can be numeric
streams_subset <- streams_subset %>%
  mutate(
    W_TDN.mgL = gsub("\\(.*\\)", "", W_TDN.mgL),  
    W_TDN.mgL = as.numeric(W_TDN.mgL)             
  )
summary(streams_subset)

# From this summary, we can see that there are many NAs for each variable. I would like to see if these NAs are from specific sites/years to know how to proceed in the future (e.g. were some measures not collected in certain years? Were some site neglected? This could be important as it can determine what variables we use for what analyses) 

## JD: Better to keep library statements at top so people know your requirements
library(tidyverse)

## JD: Prefer the base pipe (“|>”)
streams_long <- streams_subset%>%
  pivot_longer(
    cols = -c(year, site, date.collected),
    names_to = "variable",
    values_to = "value"
  )

na_summary <- streams_long %>%
  group_by(year, site, variable) %>%
  summarise(
    n_samples = n(),
    n_na = sum(is.na(value)),
    perc_na = (n_na / n_samples) * 100,
    .groups = "drop"
  )

# Get a good order of panels for my facet wrap
var_order <- colnames(streams_subset)
var_order <- var_order[!var_order %in% c("year", "site", "date.collected")]
na_summary <- na_summary %>%
  mutate(variable = factor(variable, levels = var_order))


ggplot(na_summary, aes(x = factor(year), y = site, fill = perc_na)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#FFFFC0", high = "red", name = "% NA") +
  facet_wrap(~variable) +
  labs(
    x = "Year",
    y = "Site",
    title = "Percentage of NAs by Year, Site, and Variable"
  ) +
  theme_minimal()

#Based on this, it looks like they changed methods for nutrient detection (variables ending in mgL, so the top and bottom rows) somewhere around 2023, as the top row of panels have all NA for 2024 and 2025 (and 2023 for phosphorous) and the bottom row only started in 2022/2023. I asked the person who collected this, and they confirmed that this is the case, and confirmed that the methods gave comparable values (so variables like DOC.mgL/W_DOC.mgL can be used interchangably). W_TPO4.mgL was only collected in one year (2024), so it cannot be used in any time-related calculations. Aside from phosphorous, each nutrient has been measured every year, with some overlap in 2022/2023. 

#Additionally, while 2020 has no periphyton measures (middle row, probably due to COVID), there are consistent but minimal NA values for 2021 onwards, which is probably just field issues. I feel comfortable using these measurements despite the NAs because they make up less than 25% of the total measures. 

# There is one NA year for C05B, which I will now remove as I believe it is an error
streams_subset <- streams_subset %>%
  filter(!(site == "C05-B" & is.na(year)))

# I also noticed the site issue around C05. C05 used to be one site, but then a beaver created a dam and split the site into C05-A and C05-B. Based on the sites that had no samples (not NA, but just a blank space on the heat map), this split happened in 2024, as all variables had no C05-A/B measures pre 2024 and no C05 post 2024. Because this is not an NA and I am aware of it, I am comfortable leaving it as is, and making a note for myself to pay attention to that in future analyses if crossing the 2024 timepoint. 

saveRDS(streams_subset, file = "assignment_2A_data_cleaning.rds")
