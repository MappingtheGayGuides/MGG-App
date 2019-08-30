library("shiny")
library("leaflet")
library("DT")
library("dplyr")



server <- function(input, output, session) {
  
    data.selected <- reactive({
      
      city_filter <- strsplit(input$map.city, ", ")[[1]]
      
      map.data <- data %>% filter(Year == input$map.year)
      
      if (all(city_filter != "All cities")) {
          map.data <- map.data %>% 
            filter(city == city_filter[1], state == city_filter[2])
      }
      
      map.data  
    
    })
    
   #current.year.data <- data %>% filter(Year == input$map_year)
    
  output$spaces_map <- renderLeaflet({
      
    leaflet(data.selected()) %>% addTiles() %>%
        addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions())
    
    })
  
  data.for.table <- reactive({
    
  
  })
  
  
  output$spaces.table <- renderDataTable({
    
    dft <- data.selected() %>% arrange(state, city, Year) %>%
      select(title, Year, description, streetaddress, city, state, amenityfeatures)
    
   
    
  })
    
}