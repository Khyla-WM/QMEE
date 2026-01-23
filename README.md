# QMEE
## Data set description
The (new) dataset chosen for this assignment was collected from 12 watersheds in Gaspe, Quebec. This region has been suffering an outbreak of Eastern Spruce Budworm since 2016, resulting in massive forest damage mostly due to defoliation and tree mortality. My lab, in conjunction with NRCan, has been investigating how this terrestrial damage has impacted stream ecosystems in the forest, utlizing 12 watersheds that create a gradient of defoliation. The dataset I have pulled for this class contains data from water chemistry samples from each of the streams from 2019-2024. It is a large dataset with a lot of different variables measured, so to narrow it down, I want to focus on the nutrient and periphyton content of the streams and investigate whether that changes based on site/defoliation level and/or time.

## Assignment 2
My first script, "assignment_2A_data_cleaning.R", takes my original large dataset and trims it to a workable dataset that includes 6 years worth of stream nutrient and periphyton samples from the Gaspe streams. Once this dataset was trimmed, I looked at the summary of the remaining columns and made some cleaning edits to the column R classes. Then I investigated the NAs present in the columns, cuurious if the NAs were concentrated to certain years/sites, and removed one row which had NA as the year. This script can be found on the main page of my repository, and can be run from my github directory

My second script, "assignment_2B_DOC_plot", investigated how dissolved organic carbon changed in streams across 6 years. It also was an eye test to see if the DOC.mgL and W_DOC.mgL variables (which I was told were mostly equivalent) gave similar results for the years they overlapped. Though not a statistical confirmation, it looked promising. This script can also be found on the main page of my repository, and can be run from the main directory provided you have run 2A first and have a copy of "assignment_2A_data_cleaning.rds" made from that. 

I think I want to investigate the changes in the other nutrients first and see if they have comparable yearly patterns to dissolved organic carbon, and then examine if the 2025 drop impacted the periphyton communities. I would break this into nutrients and then periphyton to ensure replicability. 

## Assignment 3
This assignment looked at data visualization and using the principles learned in class to create good plots using ggplot. Because my data has so many sites, it is hard to make a good looking graph, but I think I was able to accomplish this. 





### Legend for the streams dataset column names
This information was pulled from project_metadata.RDS 

Dissolved Organic Matter Absorbance Values

fi --> fluorescence index. unitless ratio

hix --> humification index. unitless ratio

mhix --> modified humification index. unitless ratio

bix --> biological fluorescence index. unitless ratio

a254 --> absorbance coefficient at 254nm. /m

a300 --> absorbance coefficient at 300nm. /m

E2_E3 --> absorbance ratio 250nm/365nm. unitless ratio

S275_295 --> Ratio used for calculation of SR. unitless ratio

S350_400 --> Ratio used for calculation of SR. unitless ratio

SR --> Spectral slope Ratio. unitless ratio. 

Nutrient Detection

DOC.mgL --> Dissolved Organic Carbon. mg/L. Lower Detection Limit = 0.4

DIC.mgL --> Dissolved Inorganic Carbon. mg/L. Lower Detection Limit = 0.5

SRP.mgL --> Soluble Reactive Phosphorous. mg/L. Lower Detection Limit = 0.001

TP.mgL --> total phosphorous. mg/L. Lower Detection Limit = 0.001

TN.mgL --> total nitrogen. mg/L. Lower Detection Limit = 0.2

Water Quality
pH --> pH. unitless. Lower Detection Limit = 3

cond.umho.cm --> specific conductance. umho/cm

alk.meqL --> total alkalinity. meq/L


Element Detection (.mgL)

Ca --> Calcium. mg/L. Lower Detection Limit = 0.01

K --> Potassium. mg/L. Lower Detection Limit = 0.01

Mg --> Magnesium. mg/L. Lower Detection Limit = 0.01

Na --> Sodium. mg/L. Lower Detection Limit = 0.01

SO4 --> Sulphate. mg/L. Lower Detection Limit = 0.2

Cl --> Chloride. mg/L. Lower Detection Limit = 0.2

SiO2 --> Silica Dioxide. mg/L. Lower Detection Limit = 0.25

Al --> Aluminum. mg/L. Lower Detection Limit = 0.005

Fe --> Iron. mg/L. Lower Detection Limit = 0.005

Mn --> Manganese. mg/L. Lower Detection Limit = 0.0005

Zn --> Zinc. mg/L. Lower Detection Limit = 0.001

Cd --> Cadmium. mg/L. Lower Detection Limit = 0.0005

Cu --> Copper. mg/L. Lower Detection Limit = 0.0005

Ni --> Nickel. mg/L. Lower Detection Limit = 0.0005

Pb --> Lead. mg/L. Lower Detection Limit = 0.0005

As --> Arsenic. mg/L. Lower Detection Limit = 0.0005

B --> Boron. mg/L. Lower Detection Limit = 0.01

Ba --> Barium. mg/L. Lower Detection Limit = 0.001

Co --> Cobalt. mg/L. Lower Detection Limit = 0.0005

Cr --> Chromium. mg/L. Lower Detection Limit = 0.0005

Mo --> Molybdenum. mg/L. Lower Detection Limit = 0.001

Se --> Selenium. mg/L. Lower Detection Limit = 0.001

Sr --> Strontium. mg/L. Lower Detection Limit = 0.001

Cl.mgL_tm --> Chloride. mg/L. Lower Detection Limit = 0.2 (_tm is a different lab, same concept)

SO4.mgL_tm --> Sulphate. mg/L. Lower Detection Limit = 0.5

SiO2.mgL_tm --> Silica Dioxide. mg/L. Lower Detection Limit = 0.02

TP.mgL_tm --> Total Phosphorous. mg/L. Lower Detection Limit = 0.002

W_DOC.mgL --> Dissolved Organic carbon. mg/L. Lower Detection Limit = 0.4 (W is a different lab and measuring system)

W_TDN.mgL --> Total Dissolved Nitrogen. mg/L. Lower Detection Limit = 0.2

W_DIC.mgL --> Dissolved Inorganic Carbon. mg/L. Lower Detection Limit = 0.5

W_SiO2.mgL --> Total Silica Dioxide. mg/L. Lower Detection Limit = 1

W_TOP4.mgL --> Total Phosphorous. mg/L. 

Periphyton

cyano.ug.cm2 --> cyanobacteria biomass. ug/cm2

green.ug.cm2 --> green algae biomass. ug/cm2

diat.ug.cm2 --> diatom biomass. ug/cm2

total.ug.cm2 --> total periphyton biomass. ug/cm2

Nitrogen

NO2.NO3.mgL --> Dissolved nitrate and nitrite. mg/L. Lower Detection Limit = 0.04

NH4.mgL --> dissolved ammonia. mg/L. Lower Detection Limit = 0.01

