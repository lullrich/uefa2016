setwd("~/Workspace/R/uefa2016")
options(stringsAsFactors = F)

library("rvest")
library("stringr")
library("lubridate")
library("data.table")

get_tm_data <- function(tm_player) {
  # Function to get the player info from a team page.
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
