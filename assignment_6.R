# Assignment 6 - Linear Models

# Part 0: Read in my dataset, add libraries
library(ggplot2)
library(dplyr)
library(emmeans)
streams <- readRDS("assignment_2A_data_cleaning.rds")

# Part 1: Formulate a hypothesis about your data

# I hypothesize that a higher dissolved organic carbon concentration (DOC) is associated with higher cyanobacteria biomass. In this hypothesis, my predictor variable is [DOC] and my response variable is cyanobacteria biomass. I also hypothesize that this relationship will be impacted by year, with higher DOC (and therefore cyanobacteria biomass) in more recent years due to the progression of the SBW outbreak. 

## JD: I'm not quite following here. Do you mean that 22-25 are more affected than previous years? You can't test that by throwing the previous years out, obviously.

# Part 2: Make a linear model for your hypothesis

  # I first made a revised object that has data just for 2022-2025, since those were the years most impacted by the outbreak. There are also a few random NAs which I removed, I still have more than enough data
## JD: In general, it's good to describe NAs thoughtfully.
streams_4yr <- streams %>% 
  filter(year %in% c(2022, 2023, 2024, 2025)) %>%
  filter(!is.na(cyano.ug.cm2))
streams_4yr$year <- factor(streams_4yr$year) #I later had a lot of issues with year being treated as not-a-factor, so this was an attempt to get it to work properly
## JD: Yes, this the standard move to make year into a factor
  
lm1 <- lm(cyano.ug.cm2 ~ W_DOC.mgL * year, data = streams_4yr)
lm1

# Part 3: Draw and Discuss at least one of each of the following:
# Part 3a: Diagnostic Plot

plot(lm1)
# Those look awful, show my data needs to be log transformed 

## JD: It's good to be thoughtful about what you add before log transforming (if you even need to); that choice can make a big difference. 
lm2 <- lm(log(cyano.ug.cm2 + 0.000001) ~ W_DOC.mgL * year, data = streams_4yr)
lm2
plot(lm2)

# The residual vs fitted looks decent, the points are mostly following that red line and clustered horizontally around 0, indicating good linearity. there is a small group of samples in the bottom left, away from the others, which is slightly concerning, so I am going to try filtering out extremely low values and re-running before looking at the rest. 0.001 as a threshold was chosen based on the relative "normal" sizes of the data and avoided losing much information - only 8 samples were removed
streams_4yr_nosmall <- streams_4yr %>% 
  filter(cyano.ug.cm2 > 0.001)

## JD: All of this is bugging me just a bit, feels kind of random. I do agree those bottom left points are pretty concerning, but it's also worrying to just throw them out, I think. I would consider adding an offset that's informed by something about the measurement error. If you have a biggish, sensible offset, you might avoid all of these problems.

lm3 <- lm(log(cyano.ug.cm2 + 1e-06) ~ W_DOC.mgL * factor(year),
          data = streams_4yr_nosmall)
## JD: Why are you still adding an offset after removing small values?

# I still later had issues with year not being treated as a factor, so I retroactively added this here to try to fix the later issues (which worked finally)
## JD: That seems crazy, I'm skeptical. Maybe test again just remove that one piece.

lm3
plot(lm3)

# This looks better, we no longer have that small group in the bottom corner and can actually see the points. There is some clustering, which I believe may be by year considering there are four clusters, but points are mostly clustered around y=0 with minimal pattern observed. I am going to take this as a good sign of linearity. 
# The QQ plot looks great, some changes from the diagonal on the tails is to be expected, and most of my residuals are normal or nearly-normal. 
# The Scale-location graph looks pretty much the same as the residual vs fitted, so same discussion applies
# The residuals vs leverage looks good, as almost everything is clustered around ish 0 on the left hand side, and nothing is outside of cooks distance, so none of my outliers are really heavily distorting the model
# I am happy enough with these diagnostics to move on to the next step
 
# Part 3b: Prediction Plot

ggplot(streams_4yr_nosmall, aes(x = W_DOC.mgL, y = cyano.ug.cm2)) +
  geom_point(aes(color = factor(year)), size = 2, alpha = 0.5) +
  geom_smooth(aes(color = factor(year)), method = "lm", se = FALSE, linewidth = 1) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 1.2, linetype = "dashed") +
  labs(
    x = "DOC (mg/L)",
    y = "Cyanobacteria (ug/cm²)",
    color = "Year"
  ) +
  theme_minimal()

# To show my predictions, I plotted my data as a scatterplot and put lines of best fit for each year and overall. The warning messages were of low concern considering the size of my data - losing 24 points out of 471 is not a big loss
# Overall, higher DOC seems to be slightly correlated to higher cyanobacteria, however this difference is extremely minimal as evidenced by the shallow slope in the dotted black line
# The trends by year show much the same, with all of them having extremely shallow slopes (2023 and 2024 negative, 2022 and 2025 positive). 2025 has the strongest slope by year, but that isn't saying much as it too is very shallow. 
# Overall, it seems that there is little evidence of a clear association between DOC and Cyanobacteria, and year has very little impact either. This goes against my hypothesis. 

# Part 3c: Inferential Plot

DOC_slopes <- emtrends(lm3, ~ year, var = "W_DOC.mgL")
summary(DOC_slopes)
em_DOC_pairs <- pairs(DOC_slopes, adjust = "none")
print(em_DOC_pairs)
plot(em_DOC_pairs) +
  geom_vline(xintercept = 0, linetype = 2)

# What I can interpret from this plot is that there was a clear change in how year impacted the DOC-cyanobacteria relationship in 2025, as all pairwise comparisons involving 2025 had confidence intervals not crossing zero. Because the confidence intervals were on the negative side of zero, and 2025 came second in all pairwise comparisons, the slopes in 2025 were clearly more positive than any other year. The least strong interaction involving 2025 was 2022-2025, which was closest to 0, however the CI still remained entirely in the negative. This is reflected in the previous graph, where 2025 has a much steeper positive slope than other year, and 2022 is the only other year with a positive slope. 
# The other pairwise comparisons showed that there is no clear difference between the final three years, as the points are near 0 and confidence intervals cross over 0. 

## Grade 2/3
