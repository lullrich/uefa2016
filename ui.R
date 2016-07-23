
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
options(stringsAsFactors = F, scipen = 999)
library("shiny")
library("data.table")
library("leaflet")
library("shinythemes")
library("ggplot2")
library("ggthemes")
library("plotly")
library("scales")
library("stringr")

clubs_data <- fread("data/tidy_club_data.csv")
tm_player_data <- fread("data/player_data_tm_tidied.csv")
uefa_player_data <- fread("data/player_data_tidied.csv")
wiki_player_data <- fread("data/wikipedia_data_tidied.csv")


shinyUI(fluidPage( 
  theme = "bootstrap.min.css",
  
  # Application title
  titlePanel("UEFA Euro 2016 -  Countries"),
  
  # Sidebar with a slider input for number of bins and select input for two countries to compare
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 20,
                  value = 20),
      selectInput("country1",
                  "Country One",
                  tm_player_data$country[order(tm_player_data$country)],
                  selected = T
                  
      ),
      selectInput("country2",
                  "Country Two",
                  tm_player_data$country[order(tm_player_data$country)],
                  selected = T
                  
      ),
      width = 3
    ),
    
    # Show a plot of the generated distributions
    mainPanel(
      tabsetPanel(
        type="tab",
        tabPanel(
          "Histograms",
          h3("Team histograms"),
          p("The distributions of player attributes (height, age, market value) for each country. 
            The red line marks the median value.
            Select two countries in the sidebar to compare teams."),
          fluidRow(
            column(6, plotlyOutput("heightDistPlot1")),
            column(6, plotlyOutput("heightDistPlot2"))
          ),
          fluidRow(
            column(6, plotlyOutput("ageDistPlot1")),
            column(6, plotlyOutput("ageDistPlot2"))
          ),
          fluidRow(
            column(6, plotlyOutput("valueDistPlot1")),
            column(6, plotlyOutput("valueDistPlot2"))
          )
        ),
        tabPanel(
          "Map",
          h3("Map of player clubs"),
          p("A map of every club that has players participating in EURO 2016. 
            The size of the marker is equivalent to the number of players the club sent to France. 
            Click on a circle to see information about the club."),
          leafletOutput("map", height = 600)
        )
      )
    )
  )
))
