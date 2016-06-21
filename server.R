
# This is the server logic for the Shiny web application.

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
tm_player_data <- fread("data/player_data_tm_tidied.csv")
uefa_player_data <- fread("data/player_data_tidied.csv")
wiki_player_data <- fread("data/wikipedia_data_tidied.csv")

shinyServer(function(input, output) {

  
  select_data <- reactive({
    country <- tm_player_data[country == input$country,]
    return(country)
    })
  output$heightDistPlot <- renderPlot({

    # generate bins based on input$bins from ui.R
    plot_data    <- select_data()
    player_height <- plot_data[,height]
    bins <- seq(min(player_height), max(player_height), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(player_height, breaks = bins, col = 'lightblue', border = 'white')

  })
  output$ageDistPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    plot_data    <- select_data()
    player_age <- plot_data[,age]
    bins <- seq(min(player_age), max(player_age), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(player_age, breaks = bins, col = 'lightblue', border = 'white')
    
  })
  output$valueDistPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    plot_data    <- select_data()
    player_value <- plot_data[, tm_value]
    bins <- seq(min(player_value), max(player_value), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(player_value, breaks = bins, col = 'lightblue', border = 'white', xaxt = "n")
    axis(1, axTicks(1), format(axTicks(1), big.mark   = ",", scientific = F))
  })

})
