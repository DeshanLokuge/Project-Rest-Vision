#******************* UI *******************#
#Loading the libraries
library(leaflet)
library(shiny)
library(DT)
library(shinythemes)
library(shinyalert)
library(shinycustomloader)
library(shinycssloaders)


# Loading the city_table from directory
city_table <- read.csv("city_table.csv",header = TRUE)

# The Shiny User Interface
shinyUI(
  fluidPage(
    theme = shinytheme("superhero"),
    titlePanel("PROJECT REST-VISION"),
    #themeSelector(),
    navbarPage("REST-VISION", inverse = TRUE,
               
               # Creating a tab panel for Location Search 
               tabPanel("Restaurant Search",
                        sidebarLayout(
                          sidebarPanel(
                            p("Shows locations of businesses on a map based on your search term."),
                            hr(),
                            
                            textInput("search_box", "Enter Your Keywords Here"),
                            
                            #_______________________________________________________________________________#
                            selectizeInput("region_box", "Please select Region Here",
                                           choices=c("United States","Other")),
                            withSpinner(
                            uiOutput("region_output"), type = 8, color = "#d83301"), #For city selection based on region
                          
                            uiOutput("region_output2"), #For demographic selection if region = United States
                            #_______________________________________________________________________________#
                            shinyalert::useShinyalert(),
                            actionButton("location_button", label = "", icon = shiny::icon("search"))
                            
                          ),
                          
                          
                          # Outputs the map
                          mainPanel(
                            withSpinner(
                              leafletOutput('myMap', height = "800"), type = 8, color = "#d83301")
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
                            
                            shinyalert::useShinyalert(),
                            actionButton("search_button", label = "", icon = shiny::icon("search"))
                            
                          ),
                          
                          # Outputs the data table of businesses
                          mainPanel(
                            dataTableOutput("businesses"), type = "html", loader = "dnaspin"
                          )
                        )
               )
    )
  )
)
