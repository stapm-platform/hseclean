
# The aim of this code is to prepare the reference inputs for the
# upshifting of alcohol consumption to correct for under-reporting of
# alcohol consumption in survey data

rm(list=ls())

library(tidyverse)
library(readODS)
library(curl)
library(data.table)

#Extracts per capita sales of alcohol for use in upshifting procedure from HMRC data
#on duty receipts disaggregated by UK nation:
#https://www.gov.uk/government/statistics/disaggregation-of-hmrc-tax-receipts

##########################################################################
#Declare variables

#Select year from duty take data to use
YearSelect_vec <- c("2008-09", "2009-10", "2010-11", "2011-12", "2012-13", "2013-14",
                    "2014-15", "2015-16", "2016-17", "2017-18", "2018-19")

#YearSelect <- "2017-18"
#YearSelect <- "2018-19"

for(YearSelect in YearSelect_vec) {

  #Assumed Cider ABV
  CiderABV <- 0.045

  #Assumed Wine ABV
  WineABV <- 0.125

  #Current UK duty rates for 1l of ethanol (beer & spirits) or 1l of product (cider & wine)
  #Use rates from most common duty bands for simplicity (and because very little alcohol
  #is sold outside those bands)
  DutyRate <- data.frame(Product=c("Beer", "Cider", "Wine", "Spirits"),
                         DutyPerLitre=c(19.08, 0.4038, 2.9757, 28.74)) %>%
    mutate(DutyPerLitre=case_when(
      Product=="Cider" ~ DutyPerLitre/CiderABV,
      Product=="Wine" ~ DutyPerLitre/WineABV, TRUE ~ DutyPerLitre))

  ##########################################################################
  #Get 18+ population data from STAPM inputs
  PopDir <- "X:/ScHARR/PR_Mortality_data_TA/data/Processed pop sizes and death rates from VM/"

  Pops <- read.csv(paste0(PopDir, "pop_sizes_england_national_2001-2019_v1_2022-03-30_mort.tools_1.4.0.csv")) %>%
    mutate(Country="England") %>%
    bind_rows(read.csv(paste0(PopDir, "pop_sizes_wales_national_2001-2019_v1_2022-03-30_mort.tools_1.4.0.csv")) %>%
                mutate(Country="Wales")) %>%
    bind_rows(read.csv(paste0(PopDir, "pop_sizes_scotland_national_v1_2022-12-13_mort.tools_1.5.0.csv")) %>%
                mutate(Country="Scotland")) %>%
    filter(age>=16) %>%
    group_by(Country, year) %>%
    summarise(pops=sum(pops), .groups="drop") %>%
    #Filter to selected year (using the majority match to the financial year in the HMRC data)
    filter(year==as.numeric(substr(YearSelect, 1, 4)))

  ##########################################################################
  #Download disaggregated duty take data
  url <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/853132/Disaggregated_tax_and_NICs_receipts_-_statistics_table.ods"
  temp <- tempfile()
  temp <- curl_download(url=url, destfile=temp, quiet=FALSE, mode="wb")

  #Read in latest figures for each country
  Eng <- read_ods(temp, range="A46:AM65", col_names=FALSE) %>%
    select("A", "W", "X", "Y", "Z") %>%
    set_names("Year", "Spirits", "Beer", "Wine", "Cider") %>%
    gather(Product, Revenue, c(2:5)) %>%
    mutate(Country="England")

  Wal <- read_ods(temp, range="A88:AM107", col_names=FALSE) %>%
    select("A", "W", "X", "Y", "Z") %>%
    set_names("Year", "Spirits", "Beer", "Wine", "Cider") %>%
    gather(Product, Revenue, c(2:5)) %>%
    mutate(Country="Wales")

  Sco <- read_ods(temp, range="A130:AM149", col_names=FALSE) %>%
    select("A", "W", "X", "Y", "Z") %>%
    set_names("Year", "Spirits", "Beer", "Wine", "Cider") %>%
    gather(Product, Revenue, c(2:5)) %>%
    mutate(Country="Scotland")

  NI <- read_ods(temp, range="A172:AM191", col_names=FALSE) %>%
    select("A", "W", "X", "Y", "Z") %>%
    set_names("Year", "Spirits", "Beer", "Wine", "Cider") %>%
    gather(Product, Revenue, c(2:5)) %>%
    mutate(Country="Northern Ireland")

  #Combine
  per_capita_alc_for_upshift_temp <- bind_rows(Eng, Wal, Sco, NI) %>%
    filter(Year==YearSelect) %>%
    #Convert revenue to estimated total alcohol sales (in litres of ethanol)
    merge(DutyRate) %>%
    mutate(AlcVol=Revenue*1000000/DutyPerLitre) %>%
    group_by(Country) %>%
    summarise(AlcVol=sum(AlcVol), .groups="drop") %>%
    merge(Pops, all.x=T) %>%
    mutate(PCC=AlcVol/pops)

  setDT(per_capita_alc_for_upshift_temp)

  if(YearSelect == YearSelect_vec[1]) {

    per_capita_alc_for_upshift <- copy(per_capita_alc_for_upshift_temp)

  } else {

    per_capita_alc_for_upshift <- rbindlist(list(per_capita_alc_for_upshift, copy(per_capita_alc_for_upshift_temp)), use.names = T, fill = F)

  }

  cat(YearSelect, "\n")

}


# # 2019
# # Population
# data_2019 <- read.csv(paste0(PopDir, "pop_sizes_england_national_2001-2019_v1_2022-03-30_mort.tools_1.4.0.csv")) %>%
#   mutate(Country="England") %>%
#   bind_rows(read.csv(paste0(PopDir, "pop_sizes_wales_national_2001-2019_v1_2022-03-30_mort.tools_1.4.0.csv")) %>%
#               mutate(Country="Wales")) %>%
#   bind_rows(read.csv(paste0(PopDir, "pop_sizes_scotland_national_v1_2022-12-13_mort.tools_1.5.0.csv")) %>%
#               mutate(Country="Scotland")) %>%
#   filter(age>=16) %>%
#   group_by(Country, year) %>%
#   summarise(pops=sum(pops), .groups="drop") %>%
#   #Filter to selected year (using the majority match to the financial year in the HMRC data)
#   filter(year==as.numeric(2019))
#
#
# # Value for PCC for Scotland for 2019 taken from https://www.publichealthscotland.scot/publications/mesas-monitoring-report-2022/
# # as not available in the HMRC data on duty receipts
#
# data_2019$PCC <- ifelse(data_2019$Country == "Scotland", 9.9, NA)
# data_2019$AlcVol <- NA
#
# per_capita_alc_for_upshift <- rbind(per_capita_alc_for_upshift, data_2019, use.names = T, fill = F)

usethis::use_data(per_capita_alc_for_upshift, overwrite = TRUE)

