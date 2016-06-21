library("countrycode")
library("plyr")

# The league variable is stored in a 3 letter format that for the 
# most part matches the IOC country codes from the countrycode package. 
# The United Kingdom is coded as one though, because do not compete 
# in the Olympics as 4 different countries. We have to manually add 
# the codes for the 3 countries.
GB <- data.frame(country.name = c("England", "Scotland", "Wales"), ioc = c("ENG", "SCO", "WAL"))
countrycode_data <- rbind.fill(countrycode_data, GB)

# Loading the data from disk passing a custom NA string, 
# because some missing values were written in the table as "-"
players <- fread("data/player_data.csv", na.strings=c("NA", "-", "()")) 

# This gets rid of all whitespaces (including '\n' and replaces them
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
  mutate(goals_conceded = as.numeric(goals_conceded)) %>% 
  mutate(league = countrycode(league, "ioc", "country.name", warn = TRUE))

# Convert all date columns into dates
for(cname in colnames(select(players, contains("date")))) {
  set(players, j = cname, value = dmy(players[[cname]]))
}

# save as new csv
write.csv(players, "data/player_data_tidied.csv", row.names = FALSE)
