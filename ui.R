
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
options(stringsAsFactors = F, scipen = 999)
library("shiny")
library("ggplot2")
library("plotly")
library("rvest")
library("tidyr")
library("dplyr")
library("data.table")
library("lubridate")
library("stringr")
library("httr")
library("jsonlite")
library("shinythemes")
tm_player_data <- fread("data/player_data_tm_tidied.csv")
uefa_player_data <- fread("data/player_data_tidied.csv")
wiki_player_data <- fread("data/wikipedia_data_tidied.csv")

shinyUI(fluidPage( 
  theme = "bootstrap.min.css",

  # Application title
  titlePanel("UEFA Euro 2016 -  Countries"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 20,
                  value = 20),
      selectInput("country",
                  "Country",
                  tm_player_data$country[order(tm_player_data$country)],
                  selected = TRUE
        
      ),
      width = 3
    ),

    # Show a plot of the generated distribution
    mainPanel(
      fluidRow(
        column(6, plotOutput("heightDistPlot")),
        column(6, plotOutput("ageDistPlot"))
      ),
      fluidRow(
        column(6, plotOutput("valueDistPlot"))
      )
    )
  )
))
