# Script to get the player data from the UEFA website.
# Starts at the homepage for EURO 2016 and scrapes the
# team and player pages. This takes a couple of minutes 
# to run. On my PC it takes between 3 and 10 minutes.
start_url <- "http://www.uefa.com/uefaeuro/"
strttme <- now()
# getting the data and making a data.table out of it
players <- read_html(start_url) %>% 
  html_nodes("a.table_team-name_block") %>% 
  html_attr("href") %>% 
  unique() %>% 
  sapply(url_absolute, start_url) %>% 
  lapply(get_player_urls) %>% 
  unlist() %>% 
  lapply(read_html) %>% 
  lapply(get_player_data) %>% 
  rbindlist(fill = TRUE)

endtme <- now()
total_time <- endtme - strttme
total_time
# re-name cols and save to csv
colnames(players) <- str_to_lower(colnames(players)) %>% 
  str_replace_all("\\.", "_")
write.csv(players, "data/player_data.csv", row.names = FALSE)
