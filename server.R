library("shiny")
library("leaflet")
library("DT")
library("dplyr")



server <- function(input, output, session) {
  
    data.selected <- reactive({
      
      #city_filter <- strsplit(input$map.city, ", ")[[1]]
      
      map.data <- data %>% filter(Year == input$map.year)
      if(input$filter.verified == TRUE) {
        map.data <- map.data %>%
          filter(Status=="Verified Location" | Status =="Google Verified Location")
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
    
   #current.year.data <- data %>% filter(Year == input$map_year)
    
  output$spaces_map <- renderLeaflet({
      data <- data.selected()
      map <- leaflet() %>% addTiles() %>% addProviderTiles(providers$CartoDB.Positron) %>% addMarkers(lng = data$lon, lat = data$lat, clusterOptions = markerClusterOptions(), popup= paste("<b>Location Name:</b>", data$title, "<br><b>Description: </b>", data$description, "<br><b>Type: </b>", data$type, "<br><b>Status: </b>", data$Status))
      map
    

    })
  
  data.for.table <- reactive({
    
  
  })
  
  output$num.locations <- renderText({ 
    map.data <- data.selected()
    location.count <- length(map.data$title)
    paste("In ", input$map.year, " there are ", location.count, " locations. Scroll through each one in the table below." )
  })
  output$spaces.table <- renderDataTable({
    
    dft <- data.selected() %>% arrange(state, city, Year) %>%
      select(title, Year, description, streetaddress, city, state, amenityfeatures, type, Status)
    datatable(dft, options = list(lengthMenu = c(15,25,50,100), pageLength=50))
   
    
  })
  
  # Reset Filters
  observeEvent(input$reset_button, {
    updateSelectInput(session, "map.city", selected = "All locations")
    #updateSliderTextInput(session, "map.year", value = 1965)
    updateSelectInput(session, "map.am.feature", selected = "Show all")
    updateSelectInput(session, "map.type", selected = "Show all")
    updateCheckboxInput(session, "filter.verified", value = FALSE)
    updateSliderTextInput(session, "map.year", selected=1965)
  })
}