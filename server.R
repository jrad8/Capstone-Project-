# Install and import required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
# Import model_prediction R which contains methods to call OpenWeather API
# and make predictions
source("model_prediction.R")


test_weather_data_generation<-function(){
  # Test generate_city_weather_bike_data() function
  city_weather_bike_df<-generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(head(city_weather_bike_df))
  return(city_weather_bike_df)
}

# Create a RShiny server
shinyServer(function(input, output){
  # Define a city list
  
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))
  
  city_weather_bike_df <- test_weather_data_generation()
  
  # Create another data frame called `cities_max_bike` with each row contains city location info and max bike
  cities_max_bike <- city_weather_bike_df %>%
    group_by(CITY_ASCII, LAT, LNG, BIKE_PREDICTION, BIKE_PREDICTION_LEVEL,LABEL, DETAILED_LABEL ,FORECASTDATETIME ,TEMPERATURE) %>%
    summarise(count = n(), MAX_BIKE_PREDICTION = max(BIKE_PREDICTION, na.rm = TRUE))
  
  # prediction for the city
  
  # Then render output plots with an id defined in ui.R
  output$city_bike_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = cities_max_bike, lng = cities_max_bike$LNG, lat = cities_max_bike$LAT, popup = cities_max_bike$LABEL, 
                       col = "yellow", radius = 10, weight = 10)
  })
  
  # Observe drop-down event
  observeEvent(input$city_dropdown, {
    
    # If just one specific city was selected, then render a leaflet map with one marker
    # on the map and a popup with DETAILED_LABEL displayed
    if(input$city_dropdown != 'All') {
      
      leafletProxy("city_bike_map")
        clearShapes() 
      index <- which(cities_max_bike$CITY_ASCII == input$city_dropdown)
      leafletProxy("city_bike_map")
        addCircleMarkers(lng = cities_max_bike$LNG[index], lat = cities_max_bike$LAT[index],
                         label = cities_max_bike$DETAILED_LABEL[index])
        
    }
    
    # If All was selected from dropdown, then render a leaflet map with circle markers
    # and popup weather LABEL for all five cities
    else {
      leafletProxy("city_bike_map")
     
    }
  
         
  })
  

  
})
