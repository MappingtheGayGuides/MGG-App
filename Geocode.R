# This script formats the downloaded csv from Airtable and formats it for geocoding. Steps are commented out below.


#load ggmap
library(ggmap)
library(dplyr)
library(stringr)

# Read in CSV
#origAddress <- read.csv("MGG-App/NGSData/1965.csv", header = TRUE, sep =",", stringsAsFactors = FALSE)

readData <- function( filename ) {
  
  # read in the data
  data <- read.csv( paste("NGSData/", filename, sep=""),
                    header = TRUE, 
                    sep =",", 
                    stringsAsFactors = FALSE )
  
  # add a "Year" column by removing both "yob" and ".txt" from file name
  data$Year <- gsub( ".csv", "", filename )
  
  return( data )
}
origAddress <- ldply( .data = list.files(path="NGSData/", pattern="*.csv", include.dirs = TRUE),
                  .fun = readData,
                  .parallel = TRUE )
origAddress <- origAddress %>%
  mutate_if(is.character, trimws)

# paste together the street address, city and state in order to ensure we use full addresses for geocoding. Will minimize mistakes caused by common streetnames. 
origAddress$full.address <- paste(origAddress$streetaddress, ", ", origAddress$city, ", ", origAddress$state, sep="") 

#drop unclear addresses. We may want to subset them into another data frame that we investigate further later in this process. 
origAddress <- subset(origAddress, unclearaddress!="checked")



# Register the google api code for the georeferencing service.
register_google(key = "AIzaSyA-x--1E6bbemYGA4m0BLrQfKw6Kr-gsNI")

# Loop through the addresses to get the latitude and longitude of each address and add it to the origAddress data frame in new columns lat and lon
for(i in 1:nrow(origAddress)) {
  # Print("Working...")
  result <- tryCatch(geocode(origAddress$full.address[i], output = "latlona", source = "google"), warning = function(w) data.frame(lon = NA, lat = NA, address = NA))
  origAddress$lon[i] <- as.numeric(result[1])
  origAddress$lat[i] <- as.numeric(result[2])
  origAddress$geoAddress[i] <- as.character(result[3])
}





#remove empty rows or NAs if there are any
origAddress <- origAddress[!apply(is.na(origAddress) | origAddress == "", 1, all),]

# Write a CSV file containing origAddress to the working directory
write.csv(origAddress, "NGSData/CompleteDataset.csv", row.names=FALSE)
saveRDS(origAddress, "NGSData/Data.rds")

#test the map -- good for identifying errors right off the bat. 
library(leaflet)

leaflet(data = origAddress) %>% addTiles() %>%
  addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions())

#Generate city, state lables for drop down. 

location.list <- subset(origAddress, select=c("city", "state"))
location.list$city.state <- paste(location.list$city, ", ", location.list$state, sep="")
location.list <- distinct(location.list)
location.list <- arrange(location.list, state, city)
write.csv(location.list, "locations.csv", row.names=FALSE)

