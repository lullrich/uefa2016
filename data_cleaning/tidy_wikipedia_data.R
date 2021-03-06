
# Renaming the columns and dropping un-needed columns
wikipedia_players <- fread("data/wikipedia_data.csv")
cnames <- colnames(wikipedia_players) %>% tolower() %>% trimws() %>% str_replace_all("\\W+", "_")
setnames(wikipedia_players, cnames)
setnames(wikipedia_players, "pos_", "position")
setnames(wikipedia_players, "date_of_birth_age_", "date_of_birth")
wikipedia_players[, player := NULL]
wikipedia_players[, `0_0` := NULL]
# Cleaning names
wikipedia_players[, name := str_replace(name, "\\s?\\(.*", "")]
# Extract birthday
wikipedia_players[, date_of_birth := str_extract(date_of_birth, "\\([0-9-]*\\)")]
wikipedia_players[, date_of_birth := ymd(str_replace_all(date_of_birth, "[^0-9-]", ""))]
# Extract position
wikipedia_players[, position_id := extract_numeric(position)] 
wikipedia_players[, position := str_replace_all(position, "\\d+", "")]
# Speel out position
wikipedia_players[position == "GK", position := "Goalkeeper"]
wikipedia_players[position == "MF", position := "Midfield"]
wikipedia_players[position == "DF", position := "Defender"]
wikipedia_players[position == "FW", position := "Forward"]
# Write to csv
write.csv(wikipedia_players, "data/wikipedia_data_tidied.csv", row.names = FALSE)
