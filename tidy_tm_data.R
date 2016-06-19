
# Loading the data from disk passing a custom NA string, 
# because some missing values in HTML tables are written as "-".
# This data is far dirtier than the UEFA data. Then again, the same was 
# true for the HTML.
tm_players <- fread("data/player_data_tm.csv", na.strings=c("NA", "-"))

tm_players <- tm_players %>% 
  separate(birthday, c("date_of_birth", "age"), sep = "\\s\\(") %>% 
  mutate(age = extract_numeric(age)) %>% 
  mutate(debut = str_replace(debut, ",", "")) %>% 
  mutate(date_of_birth = str_replace(date_of_birth, ",", "")) %>% 
  separate(debut, c("month", "day", "year"), sep = " ") %>% 
  separate(date_of_birth, c("bd_month", "bd_day", "bd_year"), sep = " ") %>% 
  mutate(month = month_to_num(month)) %>% 
  unite(debut, year, month, day, sep = "-") %>% 
  mutate(debut = ymd(debut)) %>% 
  mutate(bd_month = month_to_num(bd_month)) %>% 
  unite(date_of_birth, bd_year, bd_month, bd_day, sep = "-") %>% 
  mutate(date_of_birth = ymd(date_of_birth)) %>% 
  mutate(height = extract_numeric(height)) %>% 
  separate(tm_value, c("tm_value", "tm_unit", "tm_currency"), sep = " ") %>% 
  mutate(tm_value = extract_numeric(str_replace_all(tm_value, ",", ".")))

# Using the somewhat obscure data.table syntax to convert the market values 
# according to the unit and then drop the unit column.
# data.table replaces the values in-place, if the `:=` operator is used.
tm_players[tm_unit == 'Th.', tm_value := tm_value * 1000]
tm_players[tm_unit == 'Mill.', tm_value := tm_value * 1000000]
tm_players[, tm_unit := NULL]


write.csv(tm_players, "data/player_data_tm_tidied.csv", row.names = FALSE)

