library(dplyr)
library(DT)
library(ggplot2)
library(maps)
library(mapproj)
library(ggmap)
library(leaflet)
library(httr)
library(jsonlite)

source("key.R")

function(input, output){
  
  # Base yelp url for the yelp fusion API
  base_yelp_url <- "https://api.yelp.com/v3/"
  
  # This function requests business information from the YELP API and it takes the query parameters necessary for the GET request
  getData <- function(query.params) {
    path = "businesses/search" 
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    data <- fromJSON(body)
    return (data)
  }
  
  
##################################### LOCATION SEARCH TAB #####################################
  
  # creates a default map zoomed out to view the US 
  map <- leaflet() %>% addProviderTiles(provider = "Esri.WorldImagery") %>% setView(-101.204687, 40.607628, zoom = 3)
  output$myMap <- renderLeaflet(map)
  
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Getting the Yelp data $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#
  
  # preps variables that will be used later for plotting
  business_frame <- data.frame()
  center <- vector("list")
  
  # waits for the button to be pressed before getting data to be plotted
  observeEvent(input$location_button, {
    query.params = list(term = input$search_box, location = input$location_box)
    specific_data <- getData(query.params)
    
    # extracts the long, lat of the middle of the data set in question
    region <- specific_data[[3]]
    center <- region[[1]]
    
    # flattens and extracts into one data frame
    library(purrr)
    business_frame <- jsonlite::flatten(specific_data[[1]])
    
    # Converting the business_frame into a 'shapefile' from 'dataframe' format
    # library(sf)
    # business_frame <- st_as_sf(business_frame, coords = c('coordinates.longitude', 'coordinates.latitude'))
    

#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Getting the tidycensus data $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#
 
    # Loading the city table to refer among 'city' and the 'state'
    city_table <- read.csv("city_table.csv",header = TRUE)
    
    # Matching the state to the city typed in by the user within the Yelp application
    library(stringr)
    state_name <- as.character(city_table[which(city_table$city == input$location_box), c("state_name")])
    
    ## Getting the data from the tidycensus API
    # Assigning the IDs repective to the demographic features into a dataframe
    demographic_tbl <- data.frame(demo_name=c("Total median age","Total Median age of Males","Gross Median Rent","Mortgage"), id=c("B01002_001","B01002_002","B25031_001","B25097_002"))
    
    # Getting the repective ID of the demographic to be assigned to the get_acs() function
    demo_id <- as.character(demographic_tbl[which(demographic_tbl$demo_name == input$demographic), c("id")])
    
    # Getting the data from the tidycensus API
    library(tidycensus)
    df1 <- get_acs(geography = "county", state = state_name, variables = demo_id, geometry = TRUE, year = 2016)
    
    # Getting a dataframe with "State" and "County" as seperate columns, without the "moe" column
    library(tidyr)
    df2 <- separate(df1, col = "NAME", into = c("County","State"), sep = ",", remove = TRUE) %>% dplyr::select(-moe)

    
#$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Visualizing the two maps $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#
    
    # Ensures that the map does not error out if the data frame is empty
    # If it is empty, the map will default to the long, lat of the region from the search box
    if (nrow(business_frame) == 0) {
      
      view_city <- geocode(input$location_box)
      
      output$myMap <- renderLeaflet(map %>% setView(view_city[[1]], view_city[[2]], zoom = 13))
      
    } else {
      
      bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
      pal <- colorBin("YlOrRd", domain = df2$estimate, bins = bins)
      
      labels <- sprintf(
        "<strong>%s</strong><br/>%g <i>units</i>",
        df2$State, df2$estimate) %>% 
        lapply(htmltools::HTML)
      
      
      output$myMap <- renderLeaflet({
        
        leaflet(df2) %>%
          setView(center[[1]],center[[2]], zoom = 13) %>% #Add the same 'lat' and 'long' values from the Yelp business frame to overcome the zoom issue
          
          addTiles() %>% # We can also use ProviderTiles as => addProviderTile("Stamen.TonerHybrid")
          
          addPolygons(
            fillColor = ~pal(estimate),
            weight = 2,
            opacity = 1,
            color = "white",
            dashArray = "3",
            fillOpacity = 0.7,
            highlight = highlightOptions(
              weight = 5,
              color = "#222",
              dashArray = "",
              fillOpacity = 0.7,
              bringToFront = TRUE),
            label = labels,
            labelOptions = labelOptions(
              style = list("font-weight" = "normal", padding = "3px 8px"),
              textsize = "15px",
              direction = "auto")) %>%
          
          addLegend(pal = pal, values = ~estimate, title = input$demographic,opacity = 0.7,
                    position = "topright") %>%
          
          addAwesomeMarkers(lng = business_frame$coordinates.longitude, 
                            lat = business_frame$coordinates.latitude, icon=icons, label = business_frame$name)
        
      })
    }  
    # sets the color of the icons to be used  
    getColor <- function(business_frame) {
      sapply(business_frame$rating, function(rating) {
        if(rating >= 4.5) {
          "green"
        } else if(rating >= 3.5) {
          "orange"
        } else {
          "red"
        } })
    }
    
    # creates a list of icons to be used by the map
    icons <- awesomeIcons(
      icon = 'ios-close',
      iconColor = 'black',
      library = 'ion',
      markerColor = getColor(business_frame)
    )
    
  })

}  
 
  

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

