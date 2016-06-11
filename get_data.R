setwd("~/Workspace/R/uefa2016")
options(stringsAsFactors = F)

library("rvest")
library("stringr")
library("lubridate")
library("data.table")

get_players_urls <- function(url) {
  # function to get the URL for each player on a team.
  # Expects a url to a team page.
  # Returns a vector of URLs.
  res <- read_html(url) %>% 
    html_nodes("a.squad--player-img") %>% 
    html_attr("href") %>% 
    unique() %>% 
    sapply(url_absolute, start_url) 
}

get_player_data <- function(nodes) {
  # Expects a nodeset from html parsed by read_html().
  # Returns a data.frame of the player.
  
  
  # We get the UEFA-ID of the team and the player from the 
  # URLs in the 3rd-level navigation links.
  id <- nodes %>%  
    html_nodes("li.navbar-lv3-item:nth-child(3) > a") %>% 
    html_attr("href") %>% 
    str_extract_all("player=\\d+") %>% 
    str_extract("\\d+")

  team_id <- nodes %>% 
    html_nodes("li.navbar-lv3-item:nth-child(2) > a") %>% 
    html_attr("href") %>% 
    str_extract("team=\\d+") %>% 
    str_extract("\\d+")
  
  # For some reason the little info at the top of the page
  # has a more detailed position than the main table. So 
  # we get it from there.
  detailed_position <- nodes %>% 
    html_nodes("div.player-header_player-rank > span.player-category") %>% 
    html_text(trim = TRUE)
  
  # Reads the data from the main table. Sadly, this table isn't 
  # a nicely formatted html table that we could just scrape with html_table().
  # We have to scrape the date and labels separately and put them together later.
  # We add the ids and detailed_position later
  data <- nodes %>% 
    html_nodes("span.profile--list--data") %>% 
    html_text(trim = TRUE) 
  
  # Getting the labels
  labels <- nodes %>% 
    html_nodes("span.profile--list--label") %>% 
    html_text(trim = TRUE) 
  
  # Labeling the data and turning it into a data.frame
  # Because it is a named chr-vector, we have to first
  # turn it into a list.
  names(data) <- labels
  data <- data %>% 
    as.list() %>% 
    data.frame()
  
  # Adding the additional info 
  data$id <- id
  data$team_id <- team_id
  data$detailed_position <- detailed_position
  
  data
}


start_url <- "http://www.uefa.com/uefaeuro/"
strttme <- now()
# getting the data and making a data.table out of it
players <- read_html(start_url) %>% 
  html_nodes("a.table_team-name_block") %>% 
  html_attr("href") %>% 
  unique() %>% 
  sapply(url_absolute, start_url) %>% 
  lapply(get_players_urls) %>% 
  unlist() %>% 
  lapply(read_html) %>% 
  lapply(get_player_data) %>% 
  rbindlist(fill = TRUE)
endtme <- now()
total_time <- endtme - strttme
total_time
# save to csv
write.csv(players, "data/player_data.csv", row.names = FALSE)
