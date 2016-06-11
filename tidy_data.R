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
  separate(date_of_birth__age_, c("date_of_birth", "age"), sep = " ") %>% 
  separate(club, c("club", "league"), sep = "\\s\\(") %>% 
  separate(senior_debut, c("senior_debut_date", "senior_debut_match"), sep = ":\\s") %>% 
  separate(senior_debut_match, c("senior_debut_match", "senior_debut_match_location"), sep = "\\s\\(") %>% 
  separate(last_appearance, c("last_appearance_date", "last_appearance_match"), sep = ":\\s") %>% 
  separate(last_appearance_match, c("last_appearance_match", "last_appearance_location"), sep = "\\s\\(") %>% 
  mutate(height = extract_numeric(height)) %>% 
  mutate(weight = extract_numeric(weight)) %>% 
  mutate(age = extract_numeric(age)) %>% 
  mutate(league = str_replace_all(league, "\\)", "")) %>% 
  mutate(senior_debut_match_location = str_replace_all(senior_debut_match_location, "\\)", "")) %>% 
  mutate(last_appearance_location = str_replace_all(last_appearance_location, "\\)", "")) %>% 
  mutate(caps = as.numeric(caps)) %>% 
  mutate(goals = as.numeric(goals)) %>% 
  mutate(goals_conceded = as.numeric(goals_conceded)) 
  
# Convert all date columns into dates
for(cname in colnames(select(players, contains("date")))) {
  set(players, j = cname, value = dmy(players[[cname]]))
}

# save as new csv
write.csv(players, "data/player_data_tidied.csv", row.names = FALSE)

summary(players)

