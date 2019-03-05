**API and Data**

The two main data sources used within this application are:
- Restaurant related data from the Yelp Fusion database
(This does not have direct public access) 
- Demographic data derived from the tidycensus data
(This does not have restrictions to the data access)
Our app pulls data from the Yelp Fusion API, https://www.yelp.com/fusion. 
We used the "Business Search" and "Restaurant Search" endpoints mainly for this application.

On top of the data for each restaurant derived from the Yelp databas, 

**Packages Used**

The main set of packages used in this application are as follows:
- ggmap
- leaflet
- dplyr
- DT
- Shiny

Apart from these packages other general packages are also use in terms of data cleaning and optimizing the code.

**API Key**

Due to security and confidentiality concerns, the API key for the Yelp Fusion database is not disclosed within this github repository.
But the Yelp key can be dervived upon request from the Yelp Fusion website given below:
 https://www.yelp.com/fusion
 
Once the API key is with you, it can be save as a seperate R file as:
Key <- "Enter the key you have been given by the Yelp Fusion"

Name this as key.R and call this file within the server using:
source("key.R") 
This will get the application code provided here up and running.


