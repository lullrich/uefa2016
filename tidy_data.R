setwd("~/Workspace/R/uefa2016")
options(stringsAsFactors = F)
library("tidyr")
library("dplyr")
library("data.table")
library("lubridate")
library("stringr")
players <- fread("data/player_data.csv", na.strings=c("NA", "-"))

players <- players %>% 
  apply(2, str_replace_all, "\\s+", " ") %>% #replace whitespaces with single ws
  mutate(height = extract_numeric(height)) %>% 
  mutate(weight = extract_numeric(weight))

players
