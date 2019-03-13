#********************* SERVER ***********************#
# Loading the libraries
library(dplyr)
library(tidyr)
library(DT)
library(ggplot2)
library(maps)
library(mapproj)
library(ggmap)
library(leaflet)
library(httr)
library(jsonlite)
library(stringr)
library(tidycensus)
library(htmltools)
library(shinyalert)
library(shinycustomloader)
library(shinycssloaders)

# Loading the city table
city_table <- read.csv("city_table.csv",header = TRUE)

# The Yelp API Key
source("key.R")

function(input,output){
  
  # Base yelp url for the Yelp fusion API
  base_yelp_url <- "https://api.yelp.com/v3/"
  
  # The getData function to requests business information from the YELP API
  # It takes the query parameters necessary for the GET request
  getData <- function(query.params) {
    path <- "businesses/search" 
    response <- GET(url = paste(base_yelp_url, path, sep = ""), 
                    query = query.params, 
                    add_headers('Authorization' = paste("bearer", yelp_api_key)), 
                    content_type_json())
    body <- content(response, "text")
    data <- fromJSON(body)
    return (data)
  }

  #_________________________________________________________________________________________________________________________________#
  
  #Reative Input Selection For the Region Select
  withProgress(message = "Acquiring data.Please Wait...",{
    
    # Giving the "location" selection option if the region is "United States"
    output$region_output <- renderUI({
      
      if (input$region_box == "United States") {
        selectInput("location_box_US", 
                    "Type into select your City here", 
                    choices = as.vector(city_table$city), 
                    selected = as.vector(city_table$city)[7960]) 
        
    # Giving the "location" selection option if the region is "Other"
      }else{
        textInput("location_box_Other", "Please type City")
      }
    })
    
    # Giving the "demographic" selection option if the region is "United States"
    output$region_output2 <- renderUI({
      
      if (input$region_box == "United States") {
        selectInput("demographic",
                    "Demographic of Interest",
                    choices = c("Total median age",
                                "Total Median age of Males",
                                "Gross Median Rent",
                                "Mortgage",
                                "NONE")) 
      }
    })
  })

  #_________________________________________________________________________________________________________________________________#
  
  ################################################### LOCATION SEARCH TAB ###########################################################
  #_________________________________________________________________________________________________________________________________#
  
  # Creates a default map at the beginning of the App, which is zoomed at USA
  map <- leaflet() %>% 
    addProviderTiles(provider = "Esri.WorldImagery") %>% 
    setView(-101.204687, 40.607628, zoom = 3)
  
  output$myMap <- renderLeaflet(map)
  
  #______________________________________________________Getting the Yelp Data______________________________________________________#
  
  # Preparing the variables that will be used later, for plotting the map
  business_frame <- data.frame()
  center <- vector("list")
  
  # Waits for the button to be pressed before getting data to be plotted
  observeEvent(input$location_button, {
    
    # Run the application as usual, with demographic layer if region = USA
    if (input$region_box == "United States") {
      
      query.params = list(term = input$search_box, location = input$location_box_US)
      
      #-------------------------------------------------------shiny alert----------------------------------------------------------#
      specific_data <- getData(query.params)
      
      if (is.data.frame(specific_data[[1]])==FALSE|length(specific_data)<3) {
        shinyalert(title = "Sorry. No Results Found!", type = "warning")
      }else{
        # Extracts the long, lat of the middle of the data set in question
        region <- specific_data[[3]]
        center <- region[[1]]
        
        # Flattens and extracts into one data frame
        business_frame <- jsonlite::flatten(specific_data[[1]])
        
        # Adding "Top_Category" column to business_frame to facilitate tooltip information
        business_frame <- business_frame %>%
          mutate(Top_Category = as.character(purrr::transpose(categories)[['title']][[1]][[1]]))
      }
      #----------------------------------------------------------------------------------------------------------------------------#
      
      #_______________________________________________Getting the Tidy Census Data___________________________________________________#
      
      # Loading the city table to refer among 'City' and 'State'
      city_table <- read.csv("city_table.csv",header = TRUE)
      
      # Converting the city column in city_table to lower case for consistency in searching
      city_table$city <- tolower(trimws(city_table$city)) #str_replace_all(string=a, pattern=" ", repl="")
      
      # Matching the state to the city typed in by the user within the Yelp application
      state_name <- as.character(city_table[which(city_table$city == tolower(trimws(input$location_box_US))), 
                                            c("state_name")])
      
      # Getting the data from the tidycensus API
      # Assigning the IDs repective to the demographic features into a dataframe
      demographic_tbl <- data.frame(demo_name=c("Total median age",
                                                "Total Median age of Males",
                                                "Gross Median Rent",
                                                "Mortgage",
                                                "NONE"), 
                                    id=c("B01002_001",
                                         "B01002_002",
                                         "B25031_001",
                                         "B25097_002",
                                         "B25097_003"))
      
      # Getting the repective ID of the demographic to be assigned to the get_acs() function
      demo_id <- as.character(demographic_tbl[which(demographic_tbl$demo_name == input$demographic), 
                                              c("id")])
      
      # This "If-condition" runs the original Yelp App if demographic choice is "NONE"
      if (demo_id == "B25097_003") {
        
        #____________________________________________________________________________________________________________________________# 
        map <- leaflet() %>% addTiles() %>% setView(-101.204687, 40.607628, zoom = 3)
        
        # Ensures that the map does not error out if the data frame is empty
        # If it is empty, the map will default to the long, lat of the region from the search box
        if (nrow(business_frame) == 0) {
          view_city <- geocode(input$location_box_US)
          output$myMap <- renderLeaflet(map %>% setView(view_city[[1]], view_city[[2]], zoom = 13))
          
        } else {
          output$myMap <- renderLeaflet(map %>% 
                                          setView(center[[1]],center[[2]], zoom = 13) %>% 
                                          addAwesomeMarkers(lng = business_frame$coordinates.longitude, 
                                                            lat = business_frame$coordinates.latitude, 
                                                            icon=icons, 
                                                            label = business_frame$name,
                                                            popup = paste("<b>Name:</b>",business_frame$name,"<br>",
                                                                          "<b>Top Category:</b>",business_frame$Top_Category,"<br>",
                                                                          "<b>Price Range:</b>",business_frame$price,"<br>",
                                                                          "<b>Address :</b>",business_frame$location.address1), 
                                                            clusterOptions = markerClusterOptions(zoomToBoundsOnClick = TRUE,
                                                                                                  spiderfyOnMaxZoom = TRUE)))
        } 
       #____________________________________________________________________________________________________________________________# 
       
      # This is the "Else-Condition" to Visualizing the merged map if the user wants the demographics as well
      } else {
        
        withProgress(message = 'Fetching Data...Please Wait...',{
          # Getting the data from the tidycensus API
          df1 <- get_acs(geography = "county", 
                         state = state_name, 
                         variables = demo_id, 
                         geometry = TRUE, 
                         year = 2016)
          
          # Getting a dataframe with "State" and "County" as seperate columns, without the "moe" column
          df2 <- tidyr::separate(df1, 
                                 col = "NAME", 
                                 into = c("County","State"), 
                                 sep = ",", 
                                 remove = TRUE) %>% 
            dplyr::select(-moe)
        })
        
        
        # Now Visualizing the map where the demographic values are included as well
        #____________________________________________________________________________________________________________________________# 
        map <- leaflet() %>% addTiles() %>% setView(-101.204687, 40.607628, zoom = 3)
        
        # Ensures that the map does not error out if the data frame is empty
        # If it is empty, the map will default to the long, lat of the region from the search box
        if (nrow(business_frame) == 0) {
          view_city <- geocode(input$location_box_US)
          output$myMap <- renderLeaflet(map %>% setView(view_city[[1]], view_city[[2]], zoom = 13))
          
        } else {
          
          #--------------------------- Adding "bins" and "pal" depending on the demographic selection -------------------------------#
          if (input$demographic == "Total median age") {
            bins <- c(0, 10, 20, 50, 100)
            pal <- colorBin("Blues", domain = df2$estimate, bins = bins)
          }else if(input$demographic == "Total Median age of Males"){
            bins <- c(0, 10, 20, 50, 100)
            pal <- colorBin("Dark2", domain = df2$estimate, bins = bins)
          }else if(input$demographic == "Gross Median Rent"){
            bins <- c(0, 10, 20, 50, 100, 500, 1000, Inf)
            pal <- colorBin("Greens", domain = df2$estimate, bins = bins)
          }else if(input$demographic == "Mortgage"){
            bins <- c(0, 10, 20, 50, 100, 500, 1000, Inf)
            pal <- colorBin("RdYlBu", domain = df2$estimate, bins = bins)
          }
          
          # The "label" which will be displayed when the cursor is hover over
          labels <- sprintf(  
            "<strong>%s</strong><br/>%g <i>units</i>",
            df2$State, df2$estimate) %>% 
            lapply(htmltools::HTML)
          #------------------------------------------------------------------------------------------------------------------------# 
          
          output$myMap <- renderLeaflet({
            
            leaflet(df2) %>%
              #Add the same 'lat' and 'long' values from the Yelp business frame to overcome the zoom issue
              setView(center[[1]],center[[2]], zoom = 13) %>% 
              # We can also use ProviderTiles as => addProviderTile("Stamen.TonerHybrid")
              addTiles() %>% 
              
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
              
              addLegend(pal = pal, 
                        values = ~estimate, 
                        title = input$demographic,
                        opacity = 0.7,
                        position = "topright") %>%
              
              addAwesomeMarkers(lng = business_frame$coordinates.longitude, 
                                lat = business_frame$coordinates.latitude, 
                                icon=icons, 
                                label = business_frame$name,
                                popup = paste("<b>Name:</b>",business_frame$name,"<br>",
                                              "<b>Top Category:</b>",business_frame$Top_Category,"<br>", 
                                              "<b>Price Range:</b>",business_frame$price,"<br>",
                                              "<b>Address:</b>",business_frame$location.address1), 
                                clusterOptions = markerClusterOptions(zoomToBoundsOnClick = TRUE,
                                                                      spiderfyOnMaxZoom = TRUE))
            
          })
          
          
        } 
      }
      #____________________________________________________________________________________________________________________________# 
      
      
    # The "Else-condition" to run the Original Yelp App if the region selected is "Other"  
    } else {
      
      query.params = list(term = input$search_box, location = input$location_box_Other)
      
      #-------------------------------------------------------shiny alert----------------------------------------------------------#
      specific_data <- getData(query.params)
      
      if (is.data.frame(specific_data[[1]])==FALSE|length(specific_data)<3) {
        shinyalert(title = "Sorry. No Results Found!", type = "warning")
      }else{
        # Extracts the long, lat of the middle of the data set in question
        region <- specific_data[[3]]
        center <- region[[1]]

        # Flattens and extracts into one data frame
        business_frame <- jsonlite::flatten(specific_data[[1]])
        
        # Adding "Top_Category" column to business_frame to facilitate tooltip information
        business_frame <- business_frame %>%
          mutate(Top_Category = as.character(purrr::transpose(categories)[['title']][[1]][[1]]))
      }
      #----------------------------------------------------------------------------------------------------------------------------#
      
      
      # Now Visualizing the map given with Original Yelp App
      #____________________________________________________________________________________________________________________________# 
      map <- leaflet() %>% addTiles() %>% setView(-101.204687, 40.607628, zoom = 3)
      
      # Ensures that the map does not error out if the data frame is empty
      # If it is empty, the map will default to the long, lat of the region from the search box
      if (nrow(business_frame) == 0) {
        view_city <- geocode(input$location_box_Other)
        output$myMap <- renderLeaflet(map %>% setView(view_city[[1]], view_city[[2]], zoom = 13))
      } else {
        output$myMap <- renderLeaflet(map %>% 
                                        setView(center[[1]],center[[2]], zoom = 13) %>% 
                                        addAwesomeMarkers(lng = business_frame$coordinates.longitude, 
                                                          lat = business_frame$coordinates.latitude, 
                                                          icon=icons, 
                                                          label = business_frame$name,
                                                          popup = paste("<b>Name:</b>",business_frame$name,"<br>",
                                                                        "<b>Top Category:</b>",business_frame$Top_Category,"<br>",
                                                                        "<b>Price Range:</b>", business_frame$price,"<br>",
                                                                        "<b>Address:</b>",business_frame$location.address1), 
                                                          clusterOptions = markerClusterOptions(zoomToBoundsOnClick = TRUE,
                                                                                                spiderfyOnMaxZoom = TRUE))) 
      }
      #____________________________________________________________________________________________________________________________# 
    }
    
    #----------------------------------- Sets the icon type and the colours of the icons to be used -------------------------------#
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
    #-----------------------------------------------------------------------------------------------------------------------------# 
    
})
  
  ################################################### BUSINESS SEARCH TAB ###########################################################
  
  # Waits for the button to be pressed before getting data to be plotted
  observeEvent(input$search_button, {

    withProgress(message = 'Fetching Data.Please Wait ...',{
      
      query.params <- list(term = input$search_input, location = input$location_input, limit = 50)

      #-------------------------------------------------------shiny alert-------------------------------------------------------------#
      
      business_data <- getData(query.params)
      
      if (is.data.frame(business_data[[1]])==FALSE|length(business_data)<3) {
        shinyalert(title = "Sorry. No Results Found!", type = "warning")
      }else{


      # This line makes it so the data table can be printed without altering the values in these columns
      compress <- jsonlite::flatten(business_data[[1]]) %>%
          select(-id, -is_closed, -location.display_address,
                 -transactions, -coordinates.latitude, -coordinates.longitude,
                 -distance, -phone)


      compress$image_url <- paste("<img src='", compress$image_url, "' height = '60'</img>", sep = "")
      compress$url <- paste0("<a href='", compress$url, "' class = 'button'>Website</a>")

      # Combine addresses to make clean looking address column
      compress$address <- paste0(compress$location.address1, "," , compress$location.city, ", ",
                                 compress$location.state, ", ", compress$location.zip_code, ", ",
                                 compress$location.country)

      # Finally, deletes the extra address columns
      compress <- select(compress,-location.address1, -location.address2, -location.city,
                         -location.state, -location.zip_code, -location.address3, -location.country)

      # adding the 'Categories' and 'Top_category' column for the compress data frame and removing the original "categories" column
      compress <- compress %>%
        mutate(Categories = as.character(lapply(purrr::transpose(categories)[['title']], paste, collapse = ", "))) %>%
        mutate(Top_Category = as.character(purrr::transpose(categories)[['title']][[1]][[1]])) %>%
        select(-categories)


      # Cleaning up the column titles
      colnames(compress) <- c("Name","Alias","Image", "Yelp Link", "Review Count", "Rating", "Phone",
                              "Price Category", "Address", "Categories", "Top Category")


      }
      #------------------------------------------------------------------------------------------------------------------------------#
  })

    # sends the data table to the output UI, also allows for HTML tags to apply (i.e. <a href>)
    withProgress(message = 'Creating Table...Please Wait...',{
      output$businesses <- renderDataTable(DT::datatable(compress,
                                                         escape = FALSE,
                                                         selection = "none",
                                                         options = list(searchHighlight = TRUE),
                                                         filter = "top"))
    })
  })

}


