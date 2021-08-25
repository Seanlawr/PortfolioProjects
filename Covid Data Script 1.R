library(tidyverse) # import
library(dplyr) # import
data <- read.csv("C:/Users/seanl/Desktop/Portfolio projects/deaths_covid_data.csv", header=TRUE)

# Here we are going to investigate covid data taken on August 24th. The purpose of this
# is to demonstrate some abilities of R programming language and show off that I
# actualy know how to do some of this stuff propery.

str(data) #checking the data type of each column in our data
# Data in a Numerical column that is empty defaults to NA, which is frustrating
# When I'm trying to find max values and sums and such. Let's clean that up a little...
data$total_deaths[is.na(data$total_deaths)] <- 0
head(data)

# Make a new DF that finds the maximum number of deaths for each country. Throw in a na.rm = TRUE
# Just in case I'm dumb and messed up somewhere.

total_deaths_by_country <- data %>% group_by(location) %>% summarise(total_deaths = max(total_deaths, na.rm = TRUE))


View(total_deaths_by_country) #and yes, we're good.

# The world count is included in this table, at 4,441,418
# We can find the ratio of world deaths each country contributed.

total_deaths_by_country$death_ratio <- ((total_deaths_by_country$total_deaths/4441418)*100) 
head(total_deaths_by_country)

# And now we have a percentage for how each countries death total contributed to the
# global death toll
# Lets do a visualization of this



