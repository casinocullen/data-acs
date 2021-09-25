get_acs_source = function(acs_var, 
                          year, 
                          states, 
                          geo, 
                          survey = "acs5", 
                          moe = F) {
  library(httr)
  library(dplyr)
  library(sf)
  library(data.table)
  library(tidyr)
  library(janitor)

  # Census key
  key = "ddeca954163c60836e5c9d89fb8551c16cbe2bdc"
  
  # If no specific states defined, then read state.txt to get all states
  if (missing(states)) {
    states.territories <- c("AS", "GU", "MP", "VI", "UM")
    states <-read.table("../base/source/states.txt", sep = "|", header = 1) %>%
      filter(!(STUSAB %in% states.territories)) %>%
      pull(STATE)
  }
  
  county_df = fread('../base/us_county_2020.csv', colClasses = c(STATEFP="character", 
                                                    COUNTYFP="character", 
                                                    COUNTYNS="character", 
                                                    GEOID="character"))
    
  
  for (y in year) {
    base = paste0("https://api.census.gov/data/", y, "/acs/", survey, "?get=")
    if (geo %in% c("county", "state", "us")) {
      
      geo_url = geo
      
      query = base
      for (var in acs_var) {
        sample_query = paste0(base, var, "E%2C", "NAME&for=", geo_url,":*&key=", key)
        test_avail = GET(sample_query) %>% 
          httr::content(as = "text", encoding = "UTF-8")
        
        while (grepl(test_avail, pattern = "HTTP Status 404")) {
          test_avail = GET(sample_query) %>% 
            httr::content(as = "text", encoding = "UTF-8")
        }

        if (grepl(test_avail, pattern = "error: unknown variable")) {
          print(paste0("The variable ", var, " is not available."))
          print("========== Skipping ==========")
          
          next
        } else {
          print(paste0("The variable ", var, " is available!"))
          print("========== Attaching ==========")
          
          if (moe) {
            query = paste0(query, var, "E%2C", var, "M%2C")
          }else{
            query = paste0(query, var, "E%2C")
          }
        }
      }
      
      final_query = paste0(query, "NAME&for=", geo_url,":*&key=", key)
      
      if (geo == "county") {
        one_var = GET(final_query) %>% 
          httr::content(as = "text", encoding = "UTF-8") 
        
        while (grepl(one_var, pattern = "HTTP Status 404")) {
          one_var = GET(final_query) %>% 
            httr::content(as = "text", encoding = "UTF-8") 
        }
        
        one_var = one_var %>%
          jsonlite::fromJSON(flatten = TRUE) %>% 
          as.data.frame(as.factor = F) %>% 
          row_to_names(row_number = 1) %>% 
          select(-NAME) %>% 
          gather(key, value, -state, -county)
      } else if (geo == "state") {
        one_var = GET(final_query) %>% 
          httr::content(as = "text", encoding = "UTF-8") 
        
        while (grepl(one_var, pattern = "HTTP Status 404")) {
          one_var = GET(final_query) %>% 
            httr::content(as = "text", encoding = "UTF-8") 
        }
        
        one_var = one_var %>%
          jsonlite::fromJSON(flatten = TRUE) %>% 
          as.data.frame(as.factor = F) %>% 
          row_to_names(row_number = 1) %>% 
          select(-NAME) %>% 
          gather(key, value, -state)
      } else if (geo == "us") {
        one_var = GET(final_query) %>% 
          httr::content(as = "text", encoding = "UTF-8") 
        
        while (grepl(one_var, pattern = "HTTP Status 404")) {
          one_var = GET(final_query) %>% 
            httr::content(as = "text", encoding = "UTF-8") 
        }
        
        one_var = one_var %>%
          jsonlite::fromJSON(flatten = TRUE) %>% 
          as.data.frame(as.factor = F) %>% 
          row_to_names(row_number = 1) %>% 
          select(-NAME) %>% 
          gather(key, value, -us)
        
      }
    }
    
    # After finish one year ----
    # Write to `sch_source`
    print("====================================")
    print("====================================")
    print(paste0("Finished all variables for ", y))
    one_var =  one_var %>% 
      mutate(year = y)
    
    if ("key" %in% names(one_var)) {
      table_name = paste0(survey, "_", gsub(pattern = " ", replacement = "_", geo), "_", y, "_all")
      print(paste0("Wring to `../base/", table_name, "`..."))
      write.csv(x = one_var, file = table_name, row.names = F)
    }
    
  }
}