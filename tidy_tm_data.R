setwd("~/Workspace/R/uefa2016")
options(stringsAsFactors = F)
library("tidyr")
library("dplyr")
library("data.table")
library("lubridate")
library("stringr")

month_to_num <- function(x) {
  # My last attempt at trying to fix the dates... Function from the internet that is really 
  # simple and clever. Just returns the matching subset of a vector 
  # with all the months.
  c(jan=1,feb=2,mar=3,apr=4,may=5,jun=6,jul=7,aug=8,sep=9,oct=10,nov=11,dec=12)[tolower(x)]
}

# Loading the data from disk passing a custom NA string, 
# because some missing values in HTML tables are written as "-".
# This data is far dirtier than the UEFA data. Then again, the same was 
# true for the HTML.
tm_players <- fread("data/player_data_tm.csv", na.strings=c("NA", "-")) 

tm_players <- tm_players %>% 
  mutate(tm_debut = str_replace(tm_debut, ",", "")) %>% 
  separate(tm_debut, c("month", "day", "year"), sep = " ") %>% 
  mutate(month = month_to_num(month)) %>% 
  unite(debut, year, month, day, sep = "-") %>% 
  mutate(debut = ymd(debut)) %>% 
  mutate(tm_height = extract_numeric(tm_height))

write.csv(players, "data/player_data_tm_tidied.csv", row.names = FALSE)

