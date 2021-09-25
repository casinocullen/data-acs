### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
###   NAME: ACS Codebook
### AUTHOR: Chen Chen
### OUTPUT: Googlesheet
### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

library(totalcensus)
library(googlesheets4)

acs.codebook.exist = totalcensus::dict_acs5_table
acs.codebook = totalcensus::lookup_acs5year_2019

# Write to googlesheet
ss = 'https://docs.google.com/spreadsheets/d/1O462cQ7EW4JqRCiEptYyCZ8U8zRn9HkZIOHsNW7T3Ww/edit#gid=0'
# options(httr_oob_default = TRUE)
# gs4_auth()

write_sheet(acs.codebook.exist, ss, "Year Availibility")
write_sheet(acs.codebook, ss, "Codebook")

### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
###   EOF
### <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>