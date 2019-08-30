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
    #selectInput("variable", "Variable:",
              #  c("Cylinders" = "cyl",
               #   "Transmission" = "am",
                #  "Gears" = "gear")),
    selectInput("map.am.feature", "Choose an establishment feature:", 
                c("Show all" = "Show all",
                  "Very Popular" = "Very popular",
                  "Coffee, soft drinks and sometimes snacks" = "(C)",
                  "Dancing" = "(D)",
                  "Girls, but seldom exclusively" = "(G)" ), 
                selected = "Show all", multiple = FALSE, selectize = TRUE, width = NULL, size = NULL),
    includeHTML("authors.html")
  )),
  
  column(9,
          leafletOutput("spaces_map"),
          sliderInput("map.year", "Year",
                       min = 1965, max = 1980,
                       value = 1900, sep = "", round = TRUE, step = 1, width = "100%")),
          dataTableOutput("spaces.table", width="100%", height="auto")
  )

)

