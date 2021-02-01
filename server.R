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
        filter(grepl("Bars/Clubs", map.data$type, fixed = TRUE) & grepl("Hotel", map.data$type,  fixed = TRUE))
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
      arrange(state, city, Year) %>%
      select(title, Year, description, streetaddress, city, state, amenityfeatures, type, status, lat, lon)
  })
  
  
  
  output$spaces_map <- renderLeaflet({
    leaflet() %>%
      addTiles(options = tileOptions(minZoom = 3)) %>%
      setView(lat = 37.45, lng = -93.85, zoom = 3) %>%
      setMaxBounds(-173.048175,12.123149, -37.086542,73.348815)
  })

  
  output$spaces.table <- DT::renderDataTable({bib_for_table()},
                                         rownames = FALSE,
                                         class = "display compact",
                                         style = "bootstrap",
                                         options = list(pageLength=50))
  
  output$num.locations <- renderText({ 
    map.data <- data.selected()
    location.count <- length(map.data$title)
    paste("In ", input$map.year, " there are ", location.count, " locations. Scroll through each one in the table below." )
  })
  
  observe({
    df <- bib_for_map()
    
    leafletProxy("spaces_map", session) %>%
      clearMarkerClusters() %>%
      clearPopups()
    
      leafletProxy("spaces_map", data = df) %>%
        addMarkers(lng = ~lon, lat = ~lat, popup= paste("<b>Location Name:</b>", df$title, "<br><b>Description: </b>", df$description,"<br><b>Amenities: </b>", df$amenityfeatures, "<br><b>Type: </b>", df$type, "<br><b>Status: </b>", df$status), clusterOptions = markerClusterOptions(maxClusterRadius = 43))
    
      
      
  }) # End Observe
  observeEvent(input$reset_button, {
    updateSelectInput(session, "map.city", selected = "All locations")
    updateSelectInput(session, "map.am.feature", selected = "Show all")
    updateSelectInput(session, "map.type", selected = "Show all")
    updateCheckboxInput(session, "filter.verified", value = FALSE)
    updateSliderTextInput(session, "map.year", selected=1965)
  })
  
 
  
  }) # end ShinyServer function

