#COVID-19 Deaths in Toronto, Ontario
#Created: December 22nd, 2021
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

setwd("/Users/annkothe/Documents/GitHub/covid deaths")

#data
to <- readOGR("Neighbourhoods.shp")
to <- fortify(to)

covid <- read_dta("cleanedCOVID19fatalities.dta")
id <- read_csv(file = "neighborhoods.csv")

id$id <- as.character(id$id)
to$id <- as.character(to$id)

id <- inner_join(to, id, by = "id")

cases <-left_join(id, covid, by = "neighbourhood")

#
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

c <- b + transition_manual(frames = date) +
  labs(title = "COVID-19 fatalities on {current_frame}"); c

d <- c + labs(subtitle = '{cases$grosstotal[as.integer(closest_state)]}') +
            transition_states(date,
                              transition_length = 0.1,
                              state_length = 0.1); d


animate(c, height = 800, width = 800, fps = 1)
anim_save("covid.gif")
anim_save("covid.mp4")
