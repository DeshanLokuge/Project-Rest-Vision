library(leaflet)
library(shiny)
library(DT)
library(shinythemes)

shinyUI(
  fluidPage(
    theme = shinytheme("superhero"),
    titlePanel("PROJECT REST VISION"),
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
                                                    "Mortgage")),
                            
                            actionButton("location_button", label = "", icon = shiny::icon("search"))
                          ),
                          
                          # Outputs the map
                          mainPanel(
                            leafletOutput('myMap', height = "800")
     )
    )
   ),
               # Creates tab panel for Categories
               tabPanel("Categories",
                        sidebarLayout(
                          sidebarPanel(
                            p("This shows the most popular restaurant categories for the location searched."),
                            hr(),
                            textInput("search_location_categories", "Enter a location:"),
                            actionButton("analysis_button", label = "", icon = shiny::icon("search")),
                            hr(),
                            p("This computation may take a while.")
                          ),
                          mainPanel(
                            plotOutput("analytics")
                          )
                        )         
               )
   
  )
 )
)
