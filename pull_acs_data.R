### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
###   NAME: ACS Data Pull
### AUTHOR: Chen Chen
### OUTPUT: CSV File
### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

# function.sources = list.files("./functions", full.names = TRUE)
# sapply(function.sources, source)
library(tidycensus)
# census_api_key("ddeca954163c60836e5c9d89fb8551c16cbe2bdc", install = TRUE)

### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> ----
county_pop <- get_acs(geography = "county", 
              variables = c(pop_2019 = "B01001_001"), 
              state = c(state.abb, 'DC'), 
              year = 2019)

write.csv(county_pop, file = './output/county_pop.csv', row.names = F)

### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
###   EOF
### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>