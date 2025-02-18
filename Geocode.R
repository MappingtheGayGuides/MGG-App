# This script formats the downloaded csv from Airtable and formats it for geocoding. Steps are commented out below.


#load ggmap
library(ggmap)
library(dplyr)
library(stringr)
library(plyr)
library(tidyr)

# Read in CSV
#origAddress <- read.csv("MGG-App/NGSData/1965.csv", header = TRUE, sep =",", stringsAsFactors = FALSE)


########FUNCTION FOR READING IN ALL DATA FILES########

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

########READ IN DATA AND PREP FOR GEOCODING########

origAddress <- ldply( .data = list.files(path="NGSData/", pattern="*.csv", include.dirs = TRUE),
                  .fun = readData,
                  .parallel = TRUE )
origAddress <- origAddress %>%
  mutate_if(is.character, trimws)

# paste together the street address, city and state in order to ensure we use full addresses for geocoding. Will minimize mistakes caused by common streetnames. 
origAddress$full.address <- paste(origAddress$streetaddress, ", ", origAddress$city, ", ", origAddress$state, sep="") 

#drop unclear addresses. We may want to subset them into another data frame that we investigate further later in this process. 
#unclearaddresses <- origAddress %>% filter(str_detect(unclearaddress, "checked"))
#origAddress <- subset(origAddress, unclearaddress!="checked")


##########GEOCODE DATA############################


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


##########MANIPULATE UNCLEAR DATA#################

#Make unclear address match the geocoded dataset 
uncleardata <- read.csv(file = "NGSData/CodedData/unclearaddresses.csv", sep = ",", header = TRUE, stringsAsFactors = FALSE)

#trim white space
ucleardata <- uncleardata %>%
  mutate_if(is.character, trimws)

#create full address column
uncleardata$full.address <- paste(uncleardata$streetaddress, ", ", uncleardata$city, ", ", uncleardata$state, sep="") 

#split Lat/Long out into two columns
#separate(uncleardata$Lat.Lon, c("lat", "lon"), ",")
uncleardata <- separate(uncleardata, col = Lat.Lon, into = c("lat","lon"), sep = ",")

#make sure both dfs have same columns
origAddress['Status'] = 'Geocoded'
uncleardata['geoAddress'] = 'unclear_coded_by_hand'
uncleardata <- uncleardata %>% select(-"Postal.Code", -"isreferencedby", -"unclearaddress")
alldata <- rbind(origAddress, uncleardata)


########MERGE THE TWO DATASETS########


#remove empty rows or NAs if there are any
#origAddress <- origAddress[!apply(is.na(origAddress) | origAddress == "", 1, all),]

#Convert all lon/lat columns to numeric
alldata$lat <- as.numeric(alldata$lat)
alldata$lon <- as.numeric(alldata$lon)
# Write a CSV file containing origAddress to the working directory
write.csv(alldata, "NGSData/CodedData/CompleteDataset.csv", row.names=FALSE)
saveRDS(alldata, "NGSData/data.rds")

#Generate city, state lables for drop down. 

location.list <- subset(origAddress, select=c("city", "state"))
location.list$city.state <- paste(location.list$city, ", ", location.list$state, sep="")
location.list <- distinct(location.list)
location.list <- arrange(location.list, state, city)
write.csv(location.list, "locations.csv", row.names=FALSE)
#create a list of amenities
amenities <- origAddress %>% select(amenityfeatures)
