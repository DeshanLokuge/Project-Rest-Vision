#******************* UI *******************#
#Loading the libraries
library(leaflet)
library(shiny)
library(DT)
library(shinythemes)


# Loading the city_table from directory
city_table <- read.csv("city_table.csv",header = TRUE)

# The Shiny User Interface
shinyUI(
  fluidPage(
    theme = shinytheme("united"),
    titlePanel("PROJECT REST-VISION"),
    #themeSelector(),
    navbarPage("REST-VISION", inverse = TRUE,
               
               # Creating a tab panel for Location Search 
               tabPanel("Restaurant Search",
                        sidebarLayout(
                          sidebarPanel(
                            p("Shows locations of businesses on a map based on your search term."),
                            hr(),
                            
                            textInput("search_box", "Type your business here"),
                            
                            #_______________________________________________________________________________#
                            selectizeInput("region_box", "Please select region",
                                           choices=c("United States","Other")),
                            
                            uiOutput("region_output"), #For city selection based on region
                            uiOutput("region_output2"), #For demographic selection if region = United States
                            #_______________________________________________________________________________#
                            
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
                          
                          # Outputs the data table of businesses
                          mainPanel(
                            dataTableOutput("businesses")
                          )
                        )
               )
    )
  )
)
