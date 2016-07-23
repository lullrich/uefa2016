# Script to get player data from transfermarkt.com
# and save to csv. Takes a couple of seconds to run.
start_url <- "http://www.transfermarkt.com/europameisterschaft-2016/startseite/pokalwettbewerb/EM16"

strttme <- now()

tm_players <- read_html(start_url) %>% 
  html_nodes("td.links.no-border-links.hauptlink > a.vereinprofil_tooltip") %>% 
  html_attr("href") %>% 
  unique() %>%
  sapply(url_absolute, start_url) %>% 
  str_c("/saison_id/2015/plus/1") %>% 
  str_replace("startseite", "kader") %>% 
  lapply(read_html) %>% 
  lapply(get_tm_data) %>% 
  rbindlist(fill = TRUE)

endtme <- now()
total_time <- endtme - strttme
total_time

# save to csv
write.csv(tm_players, "data/player_data_tm.csv", row.names = FALSE)
