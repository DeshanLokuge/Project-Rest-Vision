library(leaflet)
library(shiny)
library(DT)
library(shinythemes)

shinyUI(
  fluidPage(
    theme = shinytheme("superhero"),
    titlePanel("PROJECT REST-VISION"),
    #themeSelector(),
    navbarPage("REST-VISION", inverse = TRUE,
               
               # Creates a tab panel for Location Search
               tabPanel("Restaurant Search",
                        sidebarLayout(
                          sidebarPanel(
                            p("Shows locations of businesses on a map based on your search term."),
                            hr(),
                            
                            textInput("search_box", "Type your business here"),
                            
                            textInput("location_box", "Type your city here"),
                            
                            selectInput("demographic","Demographic of Interest",
                                        choices = c("Total median age",
                                                    "Total Median age of Males",
                                                    "Gross Median Rent",
                                                    "Mortgage",
                                                    "Not interested")),
                            
                            actionButton("location_button", label = "", icon = shiny::icon("search"))
                          ),
                          
                          # Outputs the map
                          mainPanel(
                            leafletOutput('myMap', height = "800")
     )
    )
   ),

   # Creates a tab panel for Business Search
   tabPanel("Business Search",
            sidebarLayout(
              
              sidebarPanel(
                p("Shows a table of businesses based on your search terms."),
                hr(),
                textInput("search_input", "Type your search here"),
                textInput("location_input", "Type your location here"),
                actionButton("search_button", label = "", icon = shiny::icon("search"))
                
              ),
              
              # outputs the data table of businesses
              mainPanel(
                dataTableOutput("businesses")
              )
            )
   )
   
     )
 )
)
