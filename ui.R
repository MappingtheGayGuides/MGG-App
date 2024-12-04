library("shiny")
library("shinythemes")
library("leaflet")
library("DT")
library("shinyWidgets")

rng <- 1965:2003
ui <- fluidPage(
  theme = shinytheme("united"),
  tags$head(
    tags$script(
      src = "https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
      type = "text/javascript"
    )
    # tags$script(src="https://kit.fontawesome.com/e7de980416.js", type="text/javascript")
  ),
  fluidRow(
    column(3, wellPanel(
      selectInput("map.city", "Choose a location:",
        c(
          "All locations" = "All locations",
          "Alaska" = "AK",
          "Alabama" = "AL",
          "Arkansas" = "AR",
          "Arizona" = "AZ",
          "California" = "CA",
          "Colorado" = "CO",
          "Conneticut" = "CT",
          "Delaware" = "DE",
          "Florida" = "FL",
          "Georgia" = "GA",
          "Hawaii" = "HI",
          "Iowa" = "IA",
          "Idaho" = "ID",
          "Illinois" = "IL",
          "Indiana" = "IN",
          "Kansas" = "KS",
          "Kentucky" = "KY",
          "Louisiana" = "LA",
          "Massachusetts" = "MA",
          "Maryland" = "MD",
          "Maine" = "ME",
          "Mexico" = "Mexcio",
          "Michigan" = "MI",
          "Mississippi" = "MS",
          "Minnesota" = "MN",
          "Missouri" = "MO",
          "Montana" = "MT",
          "Nebraska" = "NE",
          "New Hampshire" = "NH",
          "New Jersey" = "NJ",
          "North Carolina" = "NC",
          "Nevada" = "NV",
          "New Mexico" = "NM",
          "New York" = "NY",
          "North Dakota" = "ND",
          "Ohio" = "OH",
          "Oklahoma" = "OK",
          "Oregon" = "OR",
          "Pennsylvania" = "PA",
          "Rhode Island" = "RI",
          "South Carolina" = "SC",
          "South Dakota" = "SD",
          "Tennessee" = "TN",
          "Texas" = "TX",
          "Utah" = "UT",
          "Virginia" = "VA",
          "Vermont" = "VT",
          "Washington" = "WA",
          "Washington, D.C." = "District of Columbia",
          "West Virginia" = "WV",
          "Wisconsin" = "WI",
          "Wyoming" = "WY"
        ),
        selectize = TRUE
      ),
      selectInput("map.am.feature", "Choose an establishment feature:",
        choices = list(
          "Show all" = "Show all",
          "(*) - Very Popular" = "(*)",
          "(AH) - After Hours" = "(AH)",
          "(AYOR) - At Your Own Risk - Dangerous - Usually Fuzz" = "(AYOR)",
          "(B-1970-1989) - Blacks Frequent" = "(B-1970-1989)",
          "(B-1990-1993) - Black Clientele or Multi-Racial Clientele" = "(B-1990-1993)",
          "(B-1999-2005) - Bears" = "(B-1999-2005)",
          "(BA) - Bare-Ass (Usually nude beach)" = "(BA)",
          "(BYOB) - Bring Your Own Bottle" = "(BYOB)",
          "(C-1965-1989) - Coffee, Soft Drinks, and Sometimes Snacks" = "(C-1965-1989)",
          "(C-2003-2005) - Cabaret" = "(C-2003-2005)",
          "(CW) - Cowboys and Westerns" = "(CW)",
          "(D) - Dancing" = "(D)",
          "(HOT) - Dangerous - Usually Fuzz" = "(HOT)",
          "(E) - Entertainment" = "(E)",
          "(FS) - Fun & Such" = "(F&S)",
          "(FFA) - Final Faith of America, or ask your friendly SM Serviceman" = "(FFA)",
          "(H) - Hotel, Motel, Resort, or other Overnight Accommodation" = "(H-1965-1989)",
          "(H) - Hustlers" = "(H-1990-1995)",
          "(HIP) - Heads Frequent" = "(HIP)",
          "(L - 1980-1989) - Ladies" = "(L-1980-1989)",
          "(L - 1990-2005) - Leather" = "(L-1990-2005)",
          "(M - 1965-1989) - Mixed - Some Straights" = "(M-1965-1989)",
          "(M - 1996-2005) - Mostly Men" = "(M-1996-2005)",
          "(MCC) - Metropolitan Community Church" = "(MCC)",
          "(N-1988-1989) - Neighborhood" = "(N-1988-1989)",
          "(N-1990-2005) - Nudity" = "(N-1990-2005)",
          "(OC) - Older/More Mature Crowd" = "(OC)",
          "(P-1965-1989) - Private - Inquire Locally as to Admission" = "(P-1965-1989)",
          "(P-1990-2002) - Professional Clientele" = "(P-1990-2002)",
          "(P-2003-2005) - Piano Bar" = "(P-2003-2005)",
          "(PE) - Pretty Elegant - Often Coat or Tie" = "(PE)",
          "(PT) - Pool Table" = "(PT)",
          "(R-1965-1989) - Restaurant" = "(R-1965-1989)",
          "(R-2003-2005) - Reservations Required" = "(R-2003-2005)",
          "(RT) - Raunchy Types - Hustlers, Drags, and other 'Downtown Types'" = "(RT)",
          "(S-1965-2002) - Shows - Impersonators or Pantomime Acts - Often Touristy" = "(S-1965-2002)",
          "(S-2003-2005) - Strippers and Go Go Dancers" = "(S-2003-2005)",
          "(SM) - Some Motorcycle & Leather" = "(SM)",
          "(W-1972-1989) - Western or Cowboy Types" = "(W-1972-1989)",
          "(W-1990-2005) - Women" = "(W-1990-2005)",
          "(WE) - Weekends" = "(WE)",
          "(YC) - Young/Collegiate Types" = "(YC)",
          "Cruisy Areas" = "Cruisy Area"
        ),
        selected = "Show all", multiple = FALSE, selectize = TRUE, width = NULL, size = NULL
      ),
      selectInput("map.type", "Choose a Type: ", c(
        "Show all" = "Show all",
        "Bars or Clubs" = "Bars/Clubs",
        "Bathhouses" = "Baths",
        "Hotels" = "Hotel",
        "Hotel Bars" = "Hotel Bar",
        "Cruising Areas", "Cruising Areas",
        "Restaurants" = "Restaurant",
        "Book Store" = "Book Store",
        "Theatre" = "Theatre",
        "Business" = "Business",
        "Religious Instituion" = "Church"
      )),
      checkboxInput("filter.verified", "Show only verified locations?", value = FALSE),
      actionButton("reset_button", "Reset Filters",
        icon = icon("repeat"), class = "btn-warning btn-sm"
      ),
      includeHTML("about.html")
    )),
    column(
      9,
      leafletOutput("spaces_map"),
      sliderTextInput("map.year", "Year",
        choices = rng,
        selected = rng[1],
        grid = T,
        width = "100%"
      ),
      conditionalPanel(
        condition = "input['map.year'] == 1967",
        includeHTML("nodatanotice.html")
      )
    ),
    h5(textOutput("num.locations")),
    dataTableOutput("spaces.table", width = "100%", height = "auto")
  ),
  HTML("<div data-iframe-height></div>")
)
