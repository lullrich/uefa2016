
# Joining the 2 data.tables proved to be much harder than expected. 
# Since the transliteralisation (is that a word) of foreign names
# into English equivalents is different, we cannot use them as keys
# to join on. Because other data like height and caps were different
# as well, I wound up using a combination of birthday and country.
# 11 players fell through the cracks and are missing from the joined 
# data, but 11 out of 552 should not impact the analysis that much.
players <- fread("data/player_data_tidied.csv") 
tm_players <- fread("data/player_data_tm_tidied.csv")
players_joined <- merge(players, tm_players, by = c("date_of_birth", "country"), suffixes = c("", "_tm")) %>% unique() %>% data.table()


