calc_rSVI <- function(county, state, year = NULL, full_frame = FALSE) {
  
  #Recovery Social Vulnerability Index (rSVI) developed by Hannah Boettcher as a part of the Rising Above the Deluge Project.
  #working paper for rSVI as a part of the project can be found here: https://pdfhost.io/v/nqdM1eDHu_WP_5_SVI
  #R function created by Chris Olson. 
  #Function only supports calculations for years 2019, 2020 and 2021. Other years can be called but the full frame should be returned to check the accuracy.
  #Function can only make calculations for one county at a time due to tidycensus limitations. 
  #Return tibble with the GEOID, the tract name and the rSVI value unless full_frame is set to TRUE
  #Args:
  #county: the county name as per the Census Bureau, must be in quotes for API Call
  #state: the postal abreviation of the state, example: "LA"
  #year: the year for which data will be pulled from the ACS
  #full_frame: If set as TRUE, all data and calculated fields for the calculation will be returned. Defaults to FALSE.
  #Example:
  #KingrSVI <- calc_rSVI(county = "King", state = "WA", year = 2021, full_frame = TRUE)
  
  #Information about variables used listed below:
  #variables starting with B (from a detailed table) are returned as raw number and need to be normalized by tract population
  #variables below are for 2021 ACS
  #B17001A_001: population below poverty
  #DP03_0009P: percent of unemployed population
  #B06011_001: median income
  #DP04_0047P: percentage of homes renter occupied
  #B11010_008: total male householder over 65 living alone
  #B11010_015: total female householder over 65 living alone
  #B10052_001: total of individuals with a disability
  #B06001_002: population under 5
  #B06009_002: over age 25 and education less than high school
  #B26001_001: Group quarters population
  #S2801_C02_019: percentage of households without internet
  #S0601_C01_001: total tract population
  #DP02_0115P: percentage of households that speak English less than "very well"
  #DP04_0014P: percentage of mobile homes
  #DP04_0012: number of units in a structure with 10 to 19 units
  #DP04_0013: number of units in a structure with 20+ units
  #DP04_0006: total housing units
  #DP04_0051P: percent moved in 2019 or later in 2021 ACS, less than 4 years in home. 2017 or later in 2019 ACS
  #DP04_0058P: percentage of households without a car
  #DP04_0079P: percentage of rooms occupied by 1.51 or more people defined as a crowded household
  #B01001H_001: total population white alone
  #DP02_0007: male single parents with children under 18
  #DP02_0011: female single parents with children under 18
  
  #variables below are for 2019 and are different from 2021 and 2020
  #DP02_0114P: percentage of households that speak English less than "very well"
  #DP04_0051P: Percent Year householder moved in to unit 2017 or later
  #DP04_0052P: Percent Year householder moved in to unit 2015 to 2016
  
  require(tidycensus)
  require(tidyverse)
  if(is.null(Sys.getenv("CENSUS_API_KEY"))){
    return(simpleError(message = "No Census API Key found"))
  }
  if(year == 2019){
    variables <-  c("B17001A_001", "DP03_0009P", "B06011_001", "DP04_0047P", "B11010_008", "B11010_015", "B10052_001", 
                    "B06001_002", "B06009_002", "B26001_001", "S2801_C02_019", "S0601_C01_001", "DP02_0114P", "DP04_0014P",
                    "DP04_0012", "DP04_0013", "DP04_0006", "DP04_0051P", "DP04_0058P", "DP04_0079P", "B01001H_001",
                    "DP02_0007", "DP02_0011", "DP04_0052P") #set variables to pull
    acs <- get_acs(geography = "tract", variables = variables, state = state, county = county, survey = "acs5", year = year) #make api call, if no year is specified then the default from tidycensus is used
    wide_acs <- pivot_wider(acs, id_cols = c("GEOID", "NAME"), names_from = "variable", values_from = "estimate") #exclude MOE in values_from drops the MOEs
    wide_acs <- mutate(wide_acs, single_parents = DP02_0007 + DP02_0011, multi_unit_housing_percent = (DP04_0012 + DP04_0013)/DP04_0006, non_white_pop = S0601_C01_001 - B01001H_001,
                       over65_lives_alone = B11010_008 + B11010_015, tenure_less_four_percent = DP04_0051P + DP04_0052P, .keep = "all")
  }else{variables <-  c("B17001A_001", "DP03_0009P", "B06011_001", "DP04_0047P", "B11010_008", "B11010_015", "B10052_001", 
                        "B06001_002", "B06009_002", "B26001_001", "S2801_C02_019", "S0601_C01_001", "DP02_0115P", "DP04_0014P",
                        "DP04_0012", "DP04_0013", "DP04_0006", "DP04_0051P", "DP04_0058P", "DP04_0079P", "B01001H_001",
                        "DP02_0007", "DP02_0011") #set variables to pull
  acs <- get_acs(geography = "tract", variables = variables, state = state, county = county, survey = "acs5", year = year) #make api call, if no year is specified then the default from tidycensus is used
  wide_acs <- pivot_wider(acs, id_cols = c("GEOID", "NAME"), names_from = "variable", values_from = "estimate") #exclude MOE in values_from drops the MOEs
  wide_acs <- mutate(wide_acs, single_parents = DP02_0007 + DP02_0011, multi_unit_housing_percent = (DP04_0012 + DP04_0013)/DP04_0006, non_white_pop = S0601_C01_001 - B01001H_001,
                     over65_lives_alone = B11010_008 + B11010_015, .keep = "all")}
  vars_to_norm <- c("single_parents", "non_white_pop", "over65_lives_alone", "B17001A_001", "B06001_002", "B06009_002", "B26001_001", "B10052_001")
  for (i in vars_to_norm) {
    norm_var = paste0(i,"_percent")
    wide_acs[[norm_var]] <- wide_acs[[i]]/wide_acs$S0601_C01_001
  }#loop to normalize raw numbers by total tract population
  if(year == 2019){
    vars_to_rank <- c("single_parents_percent", "non_white_pop_percent", "over65_lives_alone_percent", "B17001A_001_percent", 
                      "B06001_002_percent", "B06009_002_percent", "B26001_001_percent", "multi_unit_housing_percent", "DP03_0009P",
                      "DP04_0047P", "S2801_C02_019", "DP02_0114P", "DP04_0014P", "DP04_0051P", "DP04_0058P", "DP04_0079P", "B10052_001_percent", "tenure_less_four_percent")
  } else{
    vars_to_rank <- c("single_parents_percent", "non_white_pop_percent", "over65_lives_alone_percent", "B17001A_001_percent", 
                      "B06001_002_percent", "B06009_002_percent", "B26001_001_percent", "multi_unit_housing_percent", "DP03_0009P",
                      "DP04_0047P", "S2801_C02_019", "DP02_0115P", "DP04_0014P", "DP04_0051P", "DP04_0058P", "DP04_0079P", "B10052_001_percent" )
  }
  for (i in vars_to_rank) {
    rank_name <- paste0(i,"_rank")
    wide_acs[[rank_name]] <- percent_rank(wide_acs[[i]])
  }#loop to put in ranks, percent_rank is equivalent to percentile.inc
  wide_acs <- mutate(wide_acs, B06011_001_rank = percent_rank(desc(B06011_001)), .keep = "all") #inverse rank of median income
  flags_to_sum <- str_subset(colnames(wide_acs), "_rank") #extract list of ranks from frame
  wide_acs$flag_sum <- rowSums(select(wide_acs, all_of(flags_to_sum))) #rowSum the ranks/flags
  wide_acs$flag_percentile <- percent_rank(wide_acs$flag_sum) #calculate the percentile of the flag sum
  wide_acs <- mutate(wide_acs, rSVI = case_when(
    flag_percentile <=.25 ~ 1,
    flag_percentile <=.5 ~ 2,
    flag_percentile <=.75 ~ 3,
    flag_percentile >.75 ~ 4
  ))# assign the rSVI on a 1 through 4 scale
  if(full_frame == TRUE){
    wide_acs2 <- pivot_wider(acs, id_cols = c("GEOID", "NAME"), names_from = "variable", values_from = c("estimate", "moe")) #include MOE
    whole_frame <-  cbind(wide_acs2, wide_acs[26:max(col(wide_acs))])
    return(whole_frame)
  }else{
    rSVI_frame <- select(wide_acs, c("GEOID", "NAME", "rSVI")) #return only the geoid, name and rSVI
    return(rSVI_frame)
  }
}