#******************* UI *******************#
#Loading the libraries
library(leaflet)
library(shiny)
library(DT)
library(shinythemes)
library(shinyalert)
library(shinycustomloader)
library(shinycssloaders)
library(feather)

# Loading the city_table from directory
city_table <- read_feather("city_table.feather") %>% as.data.frame()

# The Shiny User Interface
shinyUI(
  fluidPage(
    theme = shinytheme("darkly"),
    titlePanel("PROJECT REST VISION"),
    navbarPage(title = "REST VISION", 
               inverse = TRUE,
               
               # Creating a tab panel for Location Search 
               tabPanel("Restaurant Search",
                        sidebarLayout(
                          sidebarPanel(
                            img(src="myLogo.png",height=200,width=200),br(),br(),
                            p("Shows locations of businesses on a map based on your search term."),
                            hr(),
                            
                            textInput("search_box", "Enter Your Keywords Here"),
                            
                            #_______________________________________________________________________________#
                            selectizeInput("region_box", "Please select Region Here",
                                           choices=c("United States","Other")),
                            withSpinner(
                            uiOutput("region_output"), type = 8, color = "#00FA9A"), #For city selection based on region
                          
                            uiOutput("region_output2"), #For demographic selection if region = United States
                            #_______________________________________________________________________________#
                            shinyalert::useShinyalert(),
                            actionButton("location_button", label = "", icon = shiny::icon("search"))
                            
                          ),
                           #_______________________________________________________________________________#

                          # Outputs the map
                          mainPanel(
                            withSpinner(
                              leafletOutput('myMap', height = "800"), type = 8, color = "#00FA9A")
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

