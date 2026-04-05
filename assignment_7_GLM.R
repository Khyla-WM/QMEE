# Assignment 7 - GLM

## BMB: don't need to load dplyr, ggplot2 explicitly if you load tidyverse
library(dplyr)
library(tidyverse)
library(ggplot2)
library(emmeans)

# To make this assignment doable, I am using a new dataset with count data. This dataset was taken from the same location (Gaspesie) but instead of looking at water quality measures, it counts how many macroinvertebrates of different species were found at each site over a 6 year span
# This dataset is massive, with over a thousand entries, so I am going to trim it down for the sake of this assignment to include only Epeorus (a mayfly genus) counts from 2023. My thesis project actually involves the Epeorus, and I noticed an interesting trend during collection where they were more sparse in the more highly defoliated site. My thesis wasn't looking at invertebrate counts, so this stayed as just an observation and was not tested, so I am curious if there is a correlation. 

inverts0 <- readRDS("inverts.RDS")

# I am also going to get rid of the extra taxonomical columns to keep just the info needed for this assignment

inverts1 <- subset(inverts0, select = c(
  "Genus and Species", "site",
  "year", "count"
))

# Some genius decided to have the column name be multiple words, so let's fix that

## BMB: dplyr::rename() is a little more convenient
names(inverts1)[names(inverts1) == "Genus and Species"] <- 'genus_and_species'

# Lets keep just the epeorus samples from 2023

epeorus_2023 <- inverts1 %>%
  filter(genus_and_species == "Epeorus") %>%
  filter(year == "2023")

# Perfect. Now, just site by itself isn't overly helpful, so I am going to add a column to show the level of defoliation at each site. I have pulled this data from my own thesis, so I am going to trim it and add it to my epeorus data

defo_data_2023 <- readRDS("defo_data_2023.RDS")
## BMB: can use full_join() from dplyr
epeorus_2023_defo = merge(epeorus_2023, defo_data_2023, by = "site")
epeorus <- subset(epeorus_2023_defo, select = c(
  "site", "genus_and_species", "year.y", "cdefo", "count"
))

# Now I am ready to begin my GLM! I chose a quasipoisson since my data is independent counts with no set maximum, and quasi gives more flexibility with the model

glm1 <- glm(count ~ cdefo, data = epeorus, family = quasipoisson(link = "log"))

## BMB: why are the counts not integers? that's a red flag/needs to be explained ... (for C04, C05, L12)


## plot all together
op <- par(mfrow=c(2,2))
plot(glm1)
par(op)

# These don't give me a good feeling, they don't really show what I am expecting for each plot, but lets graph this with ggplot to see what is happening 
## BMB: data set is small enough that I don't find any of these patterns concerning

gg0 <- ggplot(epeorus, aes(cdefo, count)) + geom_point()
gg1 <- gg0 + geom_smooth(method = "glm", colour = "red", 
                         formula = y~x,
                         method.args = list(family = "quasipoisson"))
gg1

# There are two data points that are much larger than the others, with counts of ~700 and ~450. Les see how much overdispersion there is
deviance(glm1) / df.residual(glm1)

## BMB: quasipoisson model **is already correcting for overdispersion**
## (in a different way from Gamma etc.; it does a post-hoc correction of the standard errors, p-values etc.
##  based on the observed degree of dispersion)
## if your data are counts, best to stick with counts


# The notes say that it should be around 1, and that anything above 3 is very worrisome. I got 195. So thats not great, poisson is clearly not appropriate. I am going to try a different model. After some googling, I think Gamma would be the best option so lets try that. 



glm2 <- glm(count ~ cdefo, data = epeorus, family = Gamma(link = "log"))
op <- par(mfrow=c(2,2))
plot(glm2)
par(op)

## BMB: not much difference

# Gamma doesn't have to worry about over dispersion since it estimates dispersion. These diagnostic graphs look better than the other ones, still not great but better. There is some less variance in the residual vs fitted graph with a less extreme arc to the red line, the points better follow the dotted line in Q-Q, Scale location is nearly horizontal with only the usual suspects deviating, and residuals vs leverage has points further from the cook distance lines and a less jagged red line. I'll take it. 

gg2 <- gg0 + geom_smooth(method = "glm", colour = "red", 
                         formula = y~x,
                         method.args = list(family = Gamma(link = "log")))
gg2
# Even this looks a bit better, if still a bit odd because of the extremely high count numbers in two sites. 

# Now onto inferential plots using emmeans

## BMB: I would probably do these with round numbers (e.g. 
emm_defo <- emmeans(glm2,
                    ~ cdefo,
                    at = list(cdefo = 4:15),
                    type = "response")

plot(emm_defo)
summary(glm2)

# Based on the graph, there isn't any strong relationship between epeorus count and cdefo value. While the emmeans on the graph seem to decrease slightly with increasing defoliation (meaning more defoliation = less epeorus), the confidence intervals overlap the entire way and are absolutely massive, meaning this is extremely unclear. The patterns observed here are probably due to a number of factors, including a small sample size and the presence of extreme values. 
# Additionally looking at the summary, we can see that the p value is 0.167, which does not provide evidence of a clear statistical relationship. 
# If I were to do this again, I could try looking at multiple years to try to increase sample size, however that has its own issues as defoliation changes at unequal rates at sites - some sites had increased defoliation from 2022-2023, some had decreased, and the amplitude varies greatly, so that could be another factor to have to consider. 

## BMB: this is generally fine, although I think you're still a little unclear on the GLM machinery (quasipoisson, or negative binomial,
## would be the best choices here)
## mark: 2
