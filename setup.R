# Main setup script loading all the needed libraries and 
# defining the necessary functions.
setwd("~/Workspace/R/uefa2016")
options(stringsAsFactors = F, scipen = 999)

library("rvest")
library("tidyr")
library("dplyr")
library("data.table")
library("lubridate")
library("stringr")
library("httr")
library("jsonlite")

wikidata_endpoint <- "https://query.wikidata.org/sparql"

get_wikidata_link <- function (url) {
  # A function to get the Wikidata URL from
  # a Wikipedia page.
  # Expects the URL to the Wikipedia page.
  # Returns the Wikidata URI
  wikidata_link <- read_html(url) %>% 
    html_node("#t-wikibase > a") %>% 
    html_attr("href")
  wikidata_link
}


month_to_num <- function(x) {
  # My last attempt at trying to fix the dates... Function from 
  # the internet that is really simple and clever. Just returns 
  # the matching subset of a vector with all the months.
  c(jan=1,feb=2,mar=3,apr=4,may=5,jun=6,jul=7,aug=8,sep=9,oct=10,nov=11,dec=12)[tolower(x)]
}


get_player_urls <- function(url) {
  # function to get the URL for each player 
  # on a team from the UEFA website.
  # Expects a url to a team page.
  # Returns a vector of URLs.
  res <- read_html(url) %>% 
    html_nodes("a.squad--player-img") %>% 
    html_attr("href") %>% 
    unique() %>% 
    sapply(url_absolute, start_url) 
}


get_player_data <- function(nodes) {
  # Expects a nodeset from a UEFA player page parsed by read_html().
  # Returns a data.frame of the player.
  #################################################################
  
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

get_tm_data <- function(tm_player) {
  # Function to get the player info from transfermarkt.com.
  # The data is in a table, but the markup is horrible,
  # so we need to make do with scraping each item individually.
  # Expects a url to a team details page.
  # Returns a data.frame of the players for that team.
  
  # We start by initializing an empty list.
  # Then we add the atributes we scrape from tm. 
  players <- list()
  players$jersey_no <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[1]") %>% 
    html_text()
  players$name <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[2]/table/tr/td[2]/a") %>% 
    html_text()
  players$tm_id <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[2]/table/tr/td[2]/a") %>% 
    html_attr("id")
  players$tm_position <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[2]/table/tr[2]/td") %>% 
    html_text()
  players$birthday <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[3]") %>% 
    html_text()
  players$tm_team_id <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[4]/a") %>% 
    html_attr("id")
  players$tm_team <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[4]/a/img") %>% 
    html_attr("alt")
  players$foot <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[6]") %>% 
    html_text()
  players$tm_value <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[10]") %>% 
    html_text()
  players$height <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[5]") %>% 
    html_text()
  players$debut <- tm_player %>% 
    html_nodes(xpath = "//*[@id='yw1']/table/tbody/tr/td[9]") %>% 
    html_text()
  players$country <- tm_player %>% 
    html_nodes(xpath = "//*[@id='verein_head']/div/div/div[1]/div[1]/h1") %>% 
    html_text()
  # Lastly we convert the list into a data.frame
  # and return it:
  data.frame(players)
}


