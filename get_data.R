setwd("~/Workspace/R")
options(stringsAsFactors = F)
library("rvest")
library("stringr")
library("lubridate")
library("data.table")
start_url <- "http://www.uefa.com/uefaeuro/"

teams <- read_html(start_url) %>% 
  html_nodes("a.table_team-name_block") %>% 
  html_attr("href") %>% 
  unique() %>% 
  sapply(url_absolute, start_url) 

get_players_urls <- function(url) {
  res <- read_html(url) %>% 
    html_nodes("a.squad--player-img") %>% 
    html_attr("href") %>% 
    unique() %>% 
    sapply(url_absolute, start_url) 
}

get_player_data <- function(nodes) {
  # Expects a nodeset from html parsed by read_html().
  # Returns a data.frame of the player.
  
  
  # The UEFA-ID of the team and the player we can get from the links.
  # The last two links 
  ids <- nodes %>% 
    html_nodes("a.navbar-lv3-item-link") %>% 
    html_attr("href") %>% 
    str_extract_all("(player=)(\\d+)", simplify = TRUE)
  
  # For some reason the little info at the top of the page
  # has a more detailed position than the main table. So 
  # we get it from there.
  detailed_position <- nodes %>% 
    html_nodes("span.player-category") %>% 
    html_text(trim = TRUE) %>% 
    unique()
  
  # Reads the data from the main table. Sadly, this table isn't 
  # a nicely formatted html table that we could just scrape with html_table().
  # We have to scrape the date and labels separately and put them together later.
  # We append the id and detailed_position to the data
  data <- nodes %>% 
    html_nodes("span.profile--list--data") %>% 
    html_text(trim = TRUE) %>% 
    append(id) %>% 
    append(detailed_position)
  
  # Here we get the labels from the table and append 
  # the names for the data that wasn't in the table
  labels <- nodes %>% 
    html_nodes("span.profile--list--label") %>% 
    html_text(trim = TRUE) %>% 
    append("id") %>% 
    append("detailed_position")
    
  names(data) <- labels
  data.frame(as.list(data))
}

strttme <- now()
players <- teams %>% 
  lapply(get_players_urls) %>% 
  unlist() %>% 
  lapply(read_html) %>% 
  lapply(get_player_data)
endtme <- now()
endtme - strttme
players2 <- rbindlist(players, fill = TRUE)

test <- read_html("http://www.uefa.com/uefaeuro/season=2016/teams/player=250001968/index.html") %>% html_nodes("a.navbar-lv3-item-link") %>% 
  html_attr("href") %>% 
  str_extract_all("(player=|team=)(\\d+)", simplify = TRUE)

test <- read_html("http://www.uefa.com/uefaeuro/season=2016/teams/player=1901409/index.html") %>% get_player_data()
test[6]
names(test)
names(players2)
test_df <- rbindlist(list(test,test2), fill = TRUE)
class(test_df)


teststr <- "http://www.uefa.com/uefaeuro/season=2016/teams/player=1901409/index.html"


