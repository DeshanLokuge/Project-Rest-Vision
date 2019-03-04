library(leaflet)
library(shiny)
library(DT)
library(shinythemes)



shinyUI(
  fluidPage(
    theme = shinytheme("superhero"),
    #themeSelector(),
    navbarPage("Trabeya", inverse = TRUE,
               
               # Creates a tab panel for Location Search
               tabPanel("Restaurant Search",
                        sidebarLayout(
                          sidebarPanel(
                            p("Shows locations of businesses on a map based on your search term."),
                            hr(),
                            
                            textInput("search_box", "Type your business here"),
                            
                            textInput("location_box", "Type your location here"),
                            
                            selectInput("demographic","Demographic of Interest",
                                        choices = c("Total median age" = "B01002_001",
                                                    "Total Median age of Males" = "B01002_002",
                                                    "Gross Median Rent" = "B25031_001",
                                                    "Mortgage" = "B25097_002")),
                            
                            actionButton("location_button", label = "", icon = shiny::icon("search"))
                          ),
                          
                          # Outputs the map
                          mainPanel(
                            leafletOutput('myMap', height = "800")
     )
    )
   )
  )
 )
)
