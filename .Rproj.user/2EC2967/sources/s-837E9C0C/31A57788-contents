library("shiny")
library("leaflet")
library("DT")

data <- read.csv(file = "NGSData/CompleteDataset.csv", stringsAsFactors = FALSE)
#Define server logic required to draw a histogram ----

server <- function(input, output, session) {
  
    selected.data <- reactive({
      
      city_filter <- strsplit(input$map_city, ", ")[[1]]
      
      current.year.data <- data %>% filter(Year == input$map_year)
      
      
      if (all(city_filter != "All cities")) {
        current.year.data <- current.year.data %>%
          filter(city == city_filter[1], state == city_filter[2])
      }
      current.year.data
    })
  
  
  
  
    output$spaces_map <- renderLeaflet({
      
     
       leaflet(current.year.data) %>% addTiles() %>%
        addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions())
      
    })
    
}