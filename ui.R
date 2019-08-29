library("shiny")
library("shinythemes")
library("leaflet")
library("DT")


ui <- fluidPage(
  theme= shinytheme("united"),
  
titlePanel(HTML("Mapping the Gay Guides")),
fluidRow(
  column(3, wellPanel(
    selectInput("map.city", "Choose a city:", cities),
    selectInput("map_amenity_feature", "Choose an establishment feature:", c("Show All", "(PE) - Pretty Elegant", "Miami", "Nashville"), selected = "Show All", multiple = TRUE, selectize = TRUE, width = NULL, size = NULL),
    includeHTML("authors.html")
  )),
  column(9,
         leafletOutput("spaces_map"),
          sliderInput("map.year", "Year",
                       min = 1963, max = 1980,
                       value = 1900, sep = "", round = TRUE, step = 1, width = "100%")))
          
)

