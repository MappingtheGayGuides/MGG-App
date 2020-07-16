library("shiny")
library("leaflet")
library("DT")
library("dplyr")


shinyServer(function(input, output, session) {
  
  data.selected <- reactive({
    #Filter to map year
    map.data <- data %>% filter(Year == input$map.year)
    if(input$filter.verified == TRUE) {
      map.data <- map.data %>%
        filter(status=="Verified Location" | status =="Google Verified Location")
    }
    
    if(input$map.am.feature == "(G)" && input$map.year != 1980) {
      map.data <- map.data %>% filter(grepl("(G)", map.data$amenityfeatures, fixed = TRUE))  
    } else if (input$map.am.feature == "(G)" && input$map.year == 1980) {
      map.data <- map.data %>% filter(grepl("(L)", map.data$amenityfeatures, fixed = TRUE))  
    } else if(input$map.am.feature != "Show all") {
      map.data <- map.data %>% 
        filter(grepl(input$map.am.feature, map.data$amenityfeatures, fixed = TRUE))
    } 
    
    if(input$map.type == "Hotel Bar") {
      map.data <- map.data %>%
        filter(grepl("Bars/Clubs", map.data$type, fixed = TRUE) & grepl("Hotels", map.data$type,  fixed = TRUE))
    } else if(input$map.type != "Show all") {
      map.data <- map.data %>% 
        filter(grepl(input$map.type, map.data$type, fixed = TRUE))
    }
    
    
    if (all(input$map.city != "All locations")) {
      map.data <- map.data %>% 
        filter(state == input$map.city)
    }
    
    map.data  
    
  })
  
  bib_for_table <- reactive({
    data.selected() %>%
      arrange(state, city, Year) %>%
      select(title, Year, description, streetaddress, city, state, amenityfeatures, type, status)
  })
  
  bib_for_map <- reactive({
    data.selected() %>%
      arrange(state, city, Year)
  })
  
  
  
  output$spaces_map <- renderLeaflet({
    leaflet() %>%
      addTiles(options = tileOptions(minZoom = 3)) %>%
      setView(lat = 37.45, lng = -93.85, zoom = 4) %>%
      setMaxBounds(-125.0011, 24.9493, -66.9326, 49.5904)
  })
  
  
  output$spaces.table <- DT::renderDataTable({bib_for_table()},
                                         server = FALSE, rownames = FALSE,
                                         class = "display compact",
                                         style = "bootstrap",
                                         options = list(lengthMenu = c(15,25,50,100), pageLength=50))
  
  observe({
    df <- bib_for_map()
    
    leafletProxy("spaces_map", data = df) %>%
      clearMarkers() %>%
      clearPopups()
    
      leafletProxy("spaces_map", data = df) %>%
        addMarkers(lng = ~lon, lat = ~lat, clusterOptions = markerClusterOptions(),popup= paste("<b>Location Name:</b>", df$title, "<br><b>Description: </b>", df$description,"<br><b>Amenities: </b>", df$amenityfeatures, "<br><b>Type: </b>", df$type, "<br><b>Status: </b>", df$status))
    
      #clusterOptions = markerClusterOptions(), popup= paste("<b>Location Name:</b>", data$title, "<br><b>Description: </b>", data$description,"<br><b>Amenities: </b>", data$amenityfeatures, "<br><b>Type: </b>", data$type, "<br><b>Status: </b>", data$status))
      
  }) # End Observe
  
  
  }) # end ShinyServer function

