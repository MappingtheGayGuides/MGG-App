data <- readRDS("NGSData/Data.rds")
cities <- sort(unique(paste(data$city, data$state, sep = ", ")))
cities <- c("All cities", cities)

