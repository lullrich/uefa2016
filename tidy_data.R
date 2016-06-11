setwd("~/Workspace/R/uefa2016")
options(stringsAsFactors = F)
library("tidyr")
library("dplyr")
library("data.table")
library("lubridate")
library("stringr")
players <- fread("data/player_data.csv", na.strings=c("NA", "-"))
colnames(players) <- str_to_lower(colnames(players)) %>% 
  str_replace_all("\\.", "_")
players$height <- players %>% transmute(height = extract_numeric(height))
players$weight <- players %>% transmute(weight = extract_numeric(weight)) 

german <- filter(players, Country == "Germany")
