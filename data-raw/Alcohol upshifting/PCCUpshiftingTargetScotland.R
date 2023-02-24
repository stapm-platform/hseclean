
# The aim of this code is to prepare the reference inputs for the
# upshifting of alcohol consumption to correct for under-reporting of
# alcohol consumption in survey data

rm(list=ls())

library(tidyverse)
library(readODS)
library(curl)
library(data.table)
library(readxl)

#Extracts per capita sales of alcohol for use in upshifting procedure from MESAS data
#on alcohol sales in Scotland:
#https://www.publichealthscotland.scot/publications/mesas-monitoring-report-2022/

##########################################################################


#Download Scotland alcohol sales data

 url <-  "https://www.publichealthscotland.scot/media/13691/mesas-monitoring-report-2022-alcohol-sales.xlsx"
 temp <- tempfile()
 temp <- curl_download(url=url, destfile=temp, quiet=FALSE, mode="wb")


 #Read in figures for Scotland

Scotland <- read_excel(temp,
                    sheet = "Scotland data",
                    range = "BY17:CL18") %>% setDT

per_capita_alc_for_upshift_scotland <- Scotland %>% pivot_longer(
  cols = "2008":"2021")

names(per_capita_alc_for_upshift_scotland)[1] <- "year"
names(per_capita_alc_for_upshift_scotland)[2] <- "PCC"

per_capita_alc_for_upshift_scotland$Country <- "Scotland"
per_capita_alc_for_upshift_scotland <- as.data.table(per_capita_alc_for_upshift_scotland)

usethis::use_data(per_capita_alc_for_upshift_scotland, overwrite = TRUE)




