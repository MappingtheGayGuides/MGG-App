data <- read.csv("data.csv")
states <- sort(unique(paste(data$state)))
states <- c("All locations", states)
