
wikipedia_players <- fread("data/wikipedia_data_tidied.csv")
clubs_data <- fread("data/club_data.csv")

clubs_data[, club_wikidata_id := str_extract(team.value, "Q.*")]
n_players <- wikipedia_players[,list(number_of_players = .N), "club_wikidata_id"]
setkey(n_players, club_wikidata_id)
setkey(clubs_data, club_wikidata_id)
clubs <- merge(clubs_data, n_players) %>% 
  separate(coords.value, into = c("longitude", "latitude"), sep=" ")

clubs[, longitude := extract_numeric(longitude)]
clubs[, latitude := extract_numeric(latitude)]
clubs[, team_twitter.value := str_c("<a href='https://twitter.com/", team_twitter.value,"' target='_blank'>@", team_twitter.value,"</a>")]
clubs[is.na(team_twitter.value), team_twitter.value := "unknown"]
clubs[!is.na(image.value), image.value := str_c("<img src='", image.value, "' width='300' />")]
clubs[is.na(image.value), image.value := ""]
clubs[, popup_content := str_c("<h5>", teamLabel.value, "</h5>",
                               image.value,
                               "<hr><table><tr><td><b>EURO 2016 Players:</b></td><td>",
                               number_of_players,"</td></tr>",
                               "<tr><td><b>Stadium:</b></td><td>", 
                               venueLabel.value, "</td></tr>",
                               "<tr><td><b>Capacity:</b></td><td>",
                               capacity.value,
                               "</td></tr><tr><td><b>Twitter:</b></td><td>",
                               team_twitter.value,
                               "</td></tr>",
                               "</table>")]
write.csv(clubs, "data/tidy_club_data.csv", row.names = FALSE)
