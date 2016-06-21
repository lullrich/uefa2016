# Turns out Wikipedia has a nice page with all the teams, too.
# The format would be ideal - a table per team -, but to get the 
# links for the players and clubs some additional scraping needs 
# to be done.
# This script uses data.table more. The same could have been 
# achieved using dplyr.
url <- "https://en.wikipedia.org/wiki/UEFA_Euro_2016_squads"
wikipedia <- read_html(url)

# The bulk of the information can be got from the tables
wikipedia_players <- wikipedia %>% 
  html_nodes("table.sortable.wikitable") %>% 
  html_table() %>% 
  rbindlist()
wikipedia_teams <- wikipedia %>% 
  html_nodes("h3 > span.mw-headline") %>% 
  html_text()
wikipedia_country <- list() 

for (i in wikipedia_teams[1:24]) {
  wikipedia_country[i] <- list((rep(i, times = 23)))
}
wikipedia_country <- wikipedia_country %>% unlist()


# Club names and links are in the last column of the 
# tables. 
wikipedia_club_links <- wikipedia %>% 
  html_nodes("td:nth-child(7) > a") 
wikipedia_club_url <- wikipedia_club_links %>% 
  html_attr("href") %>% 
  lapply(url_absolute, url) %>% 
  unlist()
wikipedia_club_name <- wikipedia_club_links %>% 
  html_text()
wikipedia_club_name_detailed <- wikipedia_club_links %>% 
  html_attr("title")

# Getting the links to the player pages and the names. 
# Both lists are too long by one because the '(captain)'
# after the first team captain is a link too. 
# We drop those to make the new columns fit the data.
wikipedia_player_links <- wikipedia %>% 
  html_nodes(".wikitable.plainrowheaders th[scope=row] a")
wikipedia_player_name <- wikipedia_player_links %>% 
  html_attr("title") %>% 
  unique() %>% 
  .[-2] %>% 
  unlist()
wikipedia_player_url <- wikipedia_player_links %>% 
  html_attr("href") %>% 
  lapply(url_absolute, url) %>% 
  unique() %>% 
  .[-2] %>% 
  unlist()

# Adding it all to the data frame
wikipedia_players[, player_url := wikipedia_player_url]
wikipedia_players[, name := wikipedia_player_name]
wikipedia_players[, club_name_detailed := wikipedia_club_name_detailed]
wikipedia_players[, club_url := wikipedia_club_url]
wikipedia_players[, country := wikipedia_country]
# Getting the Wikidata links. This visits every player page 
# on Wikipedia to get the links. It is surprisingly fast
# on my PC, taking only 1-2 minutes.
st <- now()
wikipedia_players[, wikidata_item := get_wikidata_link(player_url), by = player_url]
et <- now()
et-st
# Write to csv
write.csv(wikipedia_players, "data/wikipedia_data.csv", row.names = FALSE)
