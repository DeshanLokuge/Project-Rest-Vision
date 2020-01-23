# PROJECT REST VISION

![Landing Page](/assets/img/rest-vision-1.png)

# API and Data

## The two main data sources used within this application are:

Restaurant related data from the Yelp Fusion database (This does not have direct public access)
Demographic data derived from the tidycensus data (This does not have restrictions to the data access)
Our app pulls data from the Yelp Fusion API, https://www.yelp.com/fusion. We used the "Business Search" and "Restaurant Search" endpoints mainly for this application.

# Packages Used

The main set of packages used in this application are as follows:

* ggmap
* leaflet
* dplyr
* DT
* Shiny
* Apart from these packages other general packages are also use in terms of data cleaning and optimizing the code.

# API Key

Due to security and confidentiality concerns, the API key for the Yelp Fusion database is not disclosed within this github repository. But the Yelp key can be dervived upon request from the Yelp Fusion website given below: https://www.yelp.com/fusion

Once the API key is with you, it can be save as a seperate R file as: Key <- "Enter the key you have been given by the Yelp Fusion"

Name this as key.R and call this file within the server using: source("key.R") This will get the application code provided here up and running.

# Basic functionality of the App

The application maninly provides the user with two tabs:

## 1.The Location Search Tab

This tab will provide the functionality of searching for the restaurants based on the respective key word (Eg: Beef, Chicken etc.) and the city of interest. The cities are currently available for a selected number of cities in USA and any other city around the world to which Yelp has data regarding.
The user will be given restaurants related to the respective search and some other information as a tooltip regarding each restaurant such as the average price range, food category etc.
On top of this the user will also be getting a layer which displays the demographic information of interest for the user such as the median age, median salary range etc.

![Location Search Tab](/assets/img/rest-vision-2.png)

## 2.The Business Search Tab

This tab has the functionality of displaying a data table including a range of information that Yelp is providing in terms of each restaurant such as the top food category, food category range, price level, image of the food in search, address of the restaurant location etc.
The functionality of filtering each search is also available for each column of the data table for the convenience of searching the item of interest.

![Location Search Tab](/assets/img/rest-vision-3.png)

# Accessing the hosted application

The application is hosted on https://deshanlokuge.shinyapps.io/project-rest-vision/ for reference and testing.

Enjoy... !!!
