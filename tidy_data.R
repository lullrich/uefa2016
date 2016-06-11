setwd("~/Workspace/R/uefa2016")
options(stringsAsFactors = F)
library("tidyr")
library("dplyr")
library("data.table")
library("lubridate")
library("stringr")

# Loading the data from disk passing a custom NA string, 
# because some missing values were written in the table as "-"
players <- fread("data/player_data.csv", na.strings=c("NA", "-")) 

# This gets rid of all whitespaces and replaces them
# with a single whitespace. This is mostly cosmetics 
# and makes printing look nicer.
for(cname in colnames(players)) {
  set(players, j = cname, value = str_replace_all(players[[cname]], "\\s+", " "))
}

players <- players %>% 
  mutate(height = extract_numeric(height)) %>% 
  mutate(weight = extract_numeric(weight)) %>% 
  seperate(date_of_birth__age_, c("date_of_birth", "age"), sep = " ") %>% 
  mutate(age = extract_numeric(age)) %>% 
  separate(club, c("club", "league"), sep = " ") %>% 
  separate(senior_debut, c("senior_debut_date", "senior_debut_match"), sep = ": ") %>% 
  separate(last_appearance, c("last_appearance_date", "last_appearance_match"), sep = ": ")

players
