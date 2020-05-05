data <- readRDS("NGSData/data.rds")
states <- sort(unique(paste(data$state)))
states <- c("All locations", state)

