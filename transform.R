
#generatelocation list
data <- read.csv("NGSData/CodedData/CompleteDataset.csv", stringsAsFactors = TRUE)
location.list <- subset(data, select=c("city", "state"))
location.list$city.state <- paste(location.list$city, ", ", location.list$state, sep="")
location.list <- distinct(location.list)
location.list <- arrange(location.list, state, city)
write.csv(location.list, "locations.csv", row.names=FALSE)
