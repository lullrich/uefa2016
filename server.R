
# This is the server logic for the Shiny web application.

options(stringsAsFactors = F, scipen = 999)
library("shiny")
library("data.table")
library("leaflet")
library("ggplot2")
library("ggthemes")
library("plotly")
library("scales")
library("stringr")

clubs_data <- fread("data/tidy_club_data.csv")
tm_player_data <- fread("data/player_data_tm_tidied.csv")
uefa_player_data <- fread("data/player_data_tidied.csv")
wiki_player_data <- fread("data/wikipedia_data_tidied.csv")


shinyServer(function(input, output) {
  
  
  select_data1 <- reactive({
    country1 <- tm_player_data[country == input$country1,]
    return(country1)
  })
  select_data2 <- reactive({
    country2 <- tm_player_data[country == input$country2,]
    return(country2)
  })
 
  output$heightDistPlot1 <- renderPlotly({
    
    plot_data    <- select_data1()
    t <- str_c(unique(plot_data$country), " - Height")
    p <- ggplot(plot_data, aes(x = height)) +
      ggtitle(t) +
      geom_histogram(colour = "white", fill = "lightblue", bins = input$bins + 1) +
      geom_vline(aes(xintercept = median(height, na.rm = T)),   
                 color="indianred2", size=.5) +
      theme_hc()
    ggplotly(p)
    
  })
  output$heightDistPlot2 <- renderPlotly({
    
    plot_data    <- select_data2()
    t <- str_c(unique(plot_data$country), " - Height")
    p <- ggplot(plot_data, aes(x = height)) +
      ggtitle(t) +
      geom_histogram(colour = "white", fill = "lightblue", bins = input$bins + 1) +
      geom_vline(aes(xintercept = median(height, na.rm = T)),   
                 color="indianred2", size=.5) +
      theme_hc()
    ggplotly(p)
  })
  output$ageDistPlot1 <- renderPlotly({
    plot_data    <- select_data1()
    t <- str_c(unique(plot_data$country), " - Age")
    p <- ggplot(plot_data, aes(x = age)) +
      ggtitle(t) +
      geom_histogram(colour = "white", fill = "lightblue", bins = input$bins + 1) +
      geom_vline(aes(xintercept = median(age, na.rm = T)),   
                 color="indianred2", size=.5) +
      theme_hc()
    ggplotly(p)
  })
  output$ageDistPlot2 <- renderPlotly({
    plot_data    <- select_data2()
    t <- str_c(unique(plot_data$country), " - Age")
    p <- ggplot(plot_data, aes(x = age)) +
      ggtitle(t) +
      geom_histogram(colour = "white", fill = "lightblue", bins = input$bins + 1) +
      geom_vline(aes(xintercept = median(age, na.rm = T)),   
                 color="indianred2", size=.5) +
      theme_hc()
      
    ggplotly(p)
    
  })
  output$valueDistPlot1 <- renderPlotly({
    plot_data <- select_data1()
    t <- str_c(unique(plot_data$country), " - Value")
    p <- ggplot(plot_data, aes(x = tm_value)) +
      ggtitle(t) +
      geom_histogram(colour = "white", fill = "lightblue", bins = input$bins + 1) +
      geom_vline(aes(xintercept = median(tm_value, na.rm = T)),   
                 color="indianred2", size=.5) +
      scale_x_continuous(labels = comma) +
      theme_hc()
    ggplotly(p)
  })
  output$valueDistPlot2 <- renderPlotly({
    plot_data    <- select_data2()
    t <- str_c(unique(plot_data$country), " - Value")
    p <- ggplot(plot_data, aes(x = tm_value)) +
      ggtitle(t) +
      geom_histogram(colour = "white", fill = "lightblue", bins = input$bins + 1) +
      geom_vline(aes(xintercept = median(tm_value, na.rm = T)),   
                 color="indianred2", size=.5) +
      scale_x_continuous(labels = comma) +
      theme_hc()
    ggplotly(p)
  })
  output$map <- renderLeaflet({
    leaflet(clubs_data) %>% 
      addProviderTiles("CartoDB.Positron") %>% 
      addCircleMarkers(radius = sqrt(clubs_data$number_of_players) * 5, 
                       color = "#369", 
                       weight = 0.5,
                       popup = clubs_data$popup_content)
  })
})
