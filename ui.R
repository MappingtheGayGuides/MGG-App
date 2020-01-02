library("shiny")
library("shinythemes")
library("leaflet")
library("DT")
library("shinyWidgets")

rng <- 1965:1980
ui <- fluidPage(
  theme= shinytheme("united"),
  tags$head(
    tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                type="text/javascript")
  ),  
  fluidRow(
    column(3, wellPanel(
      selectInput("map.city", "Choose a city:", cities),
      selectInput("map.am.feature", "Choose an establishment feature:", 
                  c("Show all" = "Show all",
                    "Very Popular" = "Very popular",
                    "After Hours" = "(AH)",
                    "At Your Own Risk - Dangerous - Usually Fuzz" = "(AYOR)",
                    "Blacks Frequent" = "(B)",
                    "Bare-Ass (Usually nude beach" = "(BA)",
                    "Bring Your Own Bottle" = "(BYOB)",
                    "Coffee, soft drinks and sometimes snacks" = "(C)",
                    "Dancing" = "(D)",
                    "Dangerous - Usually Fuzz" = "(HOT)",
                    "Entertainment" = "(E)",
                    "Final Fiat of America, or ask your friendly SM Serviceman" = "(FFA)",
                    "Hotel, Motel, Resort, or other overnight accomodations" = "(H)",
                    "Girls, but seldom exclusively" = "(G)",
                    "Heads Frequent" = "(H)",
                    "Mixed - Some Straights" = "(M)",
                    "Metropolitan Community Church" = "(MCC)",                  
                    "Older/More Mature Crowd" = "(OC)",
                    "Private-Inquire Locally as to Admission" = "(P)",
                    "Pretty Elegant - Often Coat or Tie " = "(PE)",
                    "Pool Table" = "(PT)",
                    "Restaurant" = "(R)",
                    "Raunchy Types - Hustlers, Drags, and other 'Downtown Types'" = "(RT)",
                    "Shows--Impersonators or Pantomime Acts--Often Touristy" = "(S)",
                    "Some Motorcycle & leather" = "(SM)",
                    "Western or Cowboy Types" = "(W)",
                    "Weekends" = "(WE)",
                    "Young/Collegiate Types" = "(YC)",
                    "Cruisy Areas" = "Cruisy Area"
                  ), 
                  selected = "Show all", multiple = FALSE, selectize = TRUE, width = NULL, size = NULL),
        selectInput("map.type", "Choose a Type: ", c(
              "Show all" = "Show all",
              "Bars or Clubs" = "Bars/Clubs",
              "Bath Houses" = "Bath Houses",
              "Hotels" = "Hotels",
              "Hotel Bars" = "Bars/Clubs,Hotels",
              "Cruising Areas", "Cruising Areas",
              "Restaurants" = "Restaurants",
              "Book Store" = "Book Store",
              "Theatre" = "Theatre",
              "Business" = "Business",
              "Other" = "Other",
              "Religious Instituion" = "Church"
        )), 
      includeHTML("authors.html")
    )),
    
    column(9,
           leafletOutput("spaces_map"),
           sliderTextInput("map.year", "Year",
                           choices = rng,
                           selected = rng[1],
                           grid = T,
                           width = "100%"),
           conditionalPanel(
             condition = "input['map.year'] == 1967",
             includeHTML("nodatanotice.html")
           )),
    dataTableOutput("spaces.table", width="100%", height="auto")
  ),
  HTML('<div data-iframe-height></div>')
  
)

