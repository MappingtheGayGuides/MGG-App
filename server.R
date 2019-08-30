library("shiny")
library("leaflet")
library("DT")
library("dplyr")



server <- function(input, output) {
  
      
    
   #current.year.data <- data %>% filter(Year == input$map_year)
    
  output$spaces_map <- renderLeaflet({
    
    city_filter <- strsplit(input$map.city, ", ")[[1]]
    
    data <- data %>% filter(Year == input$map.year)
    
    if (all(city_filter != "All cities")) {
      data <- data %>% 
        filter(city == city_filter[1], state == city_filter[2])
    }
      
      leaflet(data) %>% addTiles() %>%
        addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions())
      
    })
  
  data.for.table <- reactive({
   
  })
  
  
  output$spaces.table <- renderDataTable({
    city_filter <- strsplit(input$map.city, ", ")[[1]]
    
    dft <- data %>%
      filter(Year == input$map.year)
    
    if (all(city_filter != "All cities")){
      dft <- dft %>%
        filter(city == city_filter[1], state == city_filter[2])
    }  
    dft <- dft %>% arrange(state, city, Year) %>%
      select(title, Year, description, streetaddress, city, state, amenityfeatures)
    
    dft
  })
    
}