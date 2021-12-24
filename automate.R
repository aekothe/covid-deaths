#COVID-19 Deaths in Toronto, Ontario
#Created: December 23nd, 2021
#By Angela Kothe

library(devtools)
library(mapcan)
library(tidyverse)
library(socviz)
library(scales)
library(cowplot)
library(gganimate)
library(ggmap)
library(dplyr)
library(animation)
library(glue)
library(sf)
library(rgdal)
library(transformr)
library(haven)
library(viridis)
library(av)
library(flipTime)

setwd("/Users/annkothe/Documents/GitHub/covid deaths")

UpdateAt("12-29-2021 10:00:00", us.format = TRUE, 
         time.zone = "America/New_York", units = "days", 
         frequency = 7, options = "snapshot")

download.file("https://ckan0.cf.opendata.inter.prod-toronto.ca/download_resource/e5bf35bc-e681-43da-b2ce-0242d00922ad?format=csv", 
              "covid.csv")

#cleaning covid data, (convert stata code)
covid <- read_csv(file = "covid.csv")

#renaming variables
covid <- rename(covid, id = Assigned_ID, 
         neighbourhood = `Neighbourhood Name`,
         date = `Reported Date`)

#filter by fatalities
covid <- subset(covid, covid$Outcome == "FATAL")

covid <- covid %>%
  select(id, date, neighbourhood, FSA)

#calculating deaths
covid <- covid[sort(date, neighbourhood),]

#deaths per day

#total deaths in the dataset

#collapse by neighborhood and date


#other data
to <- readOGR("Neighbourhoods.shp")
to <- fortify(to)

id <- read_csv(file = "neighborhoods.csv")

id$id <- as.character(id$id)
to$id <- as.character(to$id)

id <- inner_join(to, id, by = "id")

cases <-left_join(id, covid, by = "neighbourhood")

#merge columns
cases$date <- paste0("COVID-19 fatalities on ", cases$date)
cases$gross <- paste0("Total Deaths: ", cases$gross)
cols <- c("date", "gross")

cases$data <- do.call(paste, c(cases[cols], sep=" \n"))

cases <- na.omit(cases)

#gif
a <- ggplot(to, mapping = aes(x = long, y = lat, 
                              group = group)) +
      geom_polygon(color = alpha("black", 1.5), 
                   size = 0.2, fill = "white") +
      coord_map(projection = "albers",  lat0 = 49, 
                lat1 = 75) +
      theme_map(); a

b <- a + geom_polygon(data = cases, 
                          aes(long, lat, group = group, 
                              fill = ndeaths)) +
      scale_fill_viridis_c(option = "magma", 
                           direction = -1) +
      theme(legend.title = element_blank()) +
      labs(caption = "@AnnKothe \nsource: Open TO"); b

c <- b + transition_manual(frames = data) +
      labs(title = "{current_frame}") +
      ease_aes("cubic-in-out"); c

animate(c, height = 800, width = 800, fps = 1)

#figure out how to change file name by latest episode data 
anim_save("covid122221.gif")
anim_save("covid122221.mp4")

