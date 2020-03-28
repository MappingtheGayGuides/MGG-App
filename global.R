data <- readRDS("NGSData/Data.rds")
states <- sort(unique(paste(data$state)))
states <- c("All locations", state)

