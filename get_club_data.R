# Script to get club information for the clubs the players
# play for. Gets the Wikidata links from Wikipedia and 
# inserts the IDs into the query. The VALUES keyword limits
# the amount of values for the teams to the IDs.

# Loading the data
wikipedia_players <- fread("data/wikipedia_data_tidied.csv")

# Getting the Wikidata links from the club pages.
# Takes about half a minute.
st <- now()
clubs <- wikipedia_players[, unique(club_url)] %>% 
  sapply(get_wikidata_link)
et <- now()
et-st

# adding the URLs to the data
wikipedia_players[, club_wikidata_item := clubs[club_url]]
# extracting the Wikidata IDs from the URLs
wikipedia_players[, club_wikidata_id := str_extract(club_wikidata_item, "Q.*")]
# preparing the IDs to be inserted into the query
formatted_ids <- str_c("(wd:", unique(wikipedia_players$club_wikidata_id), ")", collapse = " ")
# inserting the IDs into the query using the sprintf function
# which is a bit more readable than paste or str_c in this case.
query <- sprintf("SELECT ?team ?teamLabel ?venueLabel ?capacity ?coords ?team_twitter WHERE {
  VALUES (?team) {%s}.
  ?team wdt:P641 wd:Q2736.
  ?team wdt:P115 ?venue.
  ?venue wdt:P625 ?coords.
  ?venue wdt:P1083 ?capacity.
  OPTIONAL{
    ?team wdt:P2002 ?team_twitter.
    }
  SERVICE wikibase:label{bd:serviceParam wikibase:language 'en'.}}", formatted_ids)

res <- GET(wikidata_endpoint, query = list(query = query)) %>% 
  content("text") %>% 
  fromJSON(flatten = TRUE)
clubs_data <- res$results$bindings
clubs_data <- clubs_data[, str_detect(colnames(clubs_data), "value")] %>% data.table()
clubs_data[, club_wikidata_id := str_extract(team.value, "Q.*")]
tm_player_data <- fread("data/player_data_tm_tidied.csv")
test <- inner_join(wikipedia_players, clubs_data, by = "club_wikidata_id")
test2 <- merge(tm_player_data, test, by = c("name", "date_of_birth"))

