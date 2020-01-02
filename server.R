library("shiny")
library("leaflet")
library("DT")
library("dplyr")



server <- function(input, output, session) {
  
    data.selected <- reactive({
      
      city_filter <- strsplit(input$map.city, ", ")[[1]]
      
      map.data <- data %>% filter(Year == input$map.year)
      
      if(input$map.am.feature != "Show all") {
        map.data <- map.data %>% 
          filter(grepl(input$map.am.feature, map.data$amenityfeatures))
      }
      if(input$map.type == "Hotel Bars") {
        map.data <- map.data %>%
          filter(grepl("hotel", map.data$type) & grepl("Bars/Clubs", map.data$type))
      } else if(input$map.type != "Show all") {
        map.data <- map.data %>% 
          filter(grepl(input$map.type, map.data$type))
      }
      
      
      if (all(city_filter != "All cities")) {
          map.data <- map.data %>% 
            filter(city == city_filter[1], state == city_filter[2])
      }
      
      map.data  
    
    })
    
   #current.year.data <- data %>% filter(Year == input$map_year)
    
  output$spaces_map <- renderLeaflet({
      data <- data.selected()
      map <- leaflet() %>% addTiles() %>% addMarkers(lng = data$lon, lat = data$lat, clusterOptions = markerClusterOptions(), popup= paste("<b>Location Name:</b>", data$title, "<br><b>Description: </b>", data$description, "<br><b>Type: </b>", data$type, "<br><b>Status: </b>", data$Status))
      map
    #leaflet(data.selected()) %>% addTiles() %>%
     #   addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions(), popup= )

    })
  
  data.for.table <- reactive({
    
  
  })
  
  output$num.locations <- renderText({ 
    map.data <- data.selected()
    location.count <- map.data %>% summarise(n = n())
    paste("There are ", location.count, " locations." )
  })
  output$spaces.table <- renderDataTable({
    
    dft <- data.selected() %>% arrange(state, city, Year) %>%
      select(title, Year, description, streetaddress, city, state, amenityfeatures, type, Status)
    
   
    
  })
  
  # Reset Filters
  observeEvent(input$reset_button, {
    updateSelectInput(session, "map.city", selected = "All cities")
    #updateSliderTextInput(session, "map.year", value = 1965)
    updateSelectInput(session, "map.am.feature", selected = "Show all")
    updateSelectInput(session, "map.type", selected = "Show all")
  })
}