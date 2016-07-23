# Main script to fetch and tidy the data
################################################
# SETUP
################################################
# Loading libraries and defining functions to set up the project
source("setup.R")
################################################
# DATA GATHERING & CLEANING
################################################
# Fetching data from uefa.com. This will take a while (roughly 5-10 minutes).
# This step can be skipped, as the data is saved as a csv.
source("data_gathering/get_data.R", echo = T)
# Cleaning the data
# This step can be skipped, as the data is saved as a csv.
source("data_cleaning/tidy_data.R", echo = T)
# Fetching data from transfermarkt.com. Takes less time than uefa.com
# This step can be skipped, as the data is saved as a csv.
source("data_gathering/get_tm_data.R", echo = T)
# Cleaning the data
# This step can be skipped, as the data is saved as a csv.
source("data_cleaning/tidy_tm_data.R", echo = T)
# Fetching data from wikipedia.org. Takes 1-2 minutes.
# This step can be skipped, as the data is saved as a csv.
source("data_gathering/get_wikipedia_data.R", echo = T)
# Cleaning the data
# WARNING: If this file is executed after "data_gathering/get_club_data.R",
# "data_gathering/get_club_data.R" will fail.
# This step can be skipped, as the data is saved as a csv.
source("data_cleaning/tidy_wikipedia_data.R", echo = T)
# Fetching data via SPARQL from wikidata.org. Takes about half a minute.
# WARNING: This script modifies "data/wikipedia_data_tidied.csv" to include 
# the club IDs from wikidata. This is a pre-requisite step to tidying the club data
# and means that this script depends on the wikipedia data being present.
# This step can be skipped, as the data is saved as a csv.
source("data_gathering/get_club_data.R", echo = T)
# Cleaning the data. The scary looking warning can safely be ignored...
# This step can be skipped, as the data is saved as a csv.
source("data_cleaning/tidy_club_data.R", echo = T)

################################################
# RUNNING THE APP
################################################
runApp()
