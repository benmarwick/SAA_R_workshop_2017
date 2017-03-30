
#  ---------------------------------------------------
#  ---------------------------------------------------

## Importing & visualising GIS data

# import points as spreadsheet, this is just a simple spreadsheet with one point (site) per row, and UTM coordinates in two columns 
library(readr)
pottery <- read_csv("data/pottery.csv")
# data from https://doi.org/10.5284/1024569
# UTM WGS84 Zone 34N coordinate system

# plot with ggplot, like a simple scatter plot
library(ggplot2)
ggplot(pottery,
       aes(Xsugg, 
           Ysugg)) +
  geom_point() +
  coord_fixed() # this is important for maps

# add polygons, import shapefile as simple features object
library(rgeos)
library(maptools)

library(sf)
geology <- read_sf("data/geology/geology.shp")


# let's look at the polygon by itself

# to plot with ggplot, we convert to "Spatial" type, and then 'fortify'
# to make the coords available to ggplot:
geology_f <- fortify(as(geology, "Spatial"), 
                     region = "Type")

ggplot() +  
  geom_polygon(data = geology_f, 
               aes(x = long, 
                   y = lat, 
                   group = group,
                   fill = id),
               colour = "black") +
  coord_fixed()

# and now the points and the polygons together
ggplot() +  
  geom_polygon(data = geology_f, 
               aes(x = long, 
                   y = lat, 
                   group = group,
                   fill = id),
               colour = "black") +
  geom_point(data = pottery, 
             aes(x = Xsugg,
                 y = Ysugg),
             alpha = 0.3) +
  coord_fixed() +
  theme_bw()

#- points in polygons

# convert pottery data frame to "simple features" object so we can do geographic operations

pottery_sf <- 
  st_as_sf(pottery, 
           coords = c("Xsugg", "Ysugg"), 
           crs = st_crs(geology))

# a typical question is how many points are in each polygon? 

# do a spatial join, take the pottery data, and for each point, add cols
# from the geology polygon that contains it
pottery_joined_to_geology <- st_join(pottery_sf, geology)

# We can tally up how many points in each polygon...

library(dplyr)
pottery_in_geology_tally <- 
  pottery_joined_to_geology %>% 
  group_by(Type) %>% 
  summarise(n = n()) %>% # count the points
  arrange(desc(n))

# but more useful is number of points per unit area, so let's compute that:

# first get the polygon areas....
geology_area_by_Type <- 
  geology %>% 
  mutate(area = st_area(.)) %>% # compute polygon area
  group_by(Type) %>% 
  summarise(total_area_for_Type = sum(area))

# lets join the counts and areas together, then compute point density:
pottery_in_geology_density <- 
  geology_area_by_Type %>% 
  st_join(pottery_in_geology_tally) %>% 
  mutate(point_density_m2 = n / total_area_for_Type ) %>% 
  arrange(desc(point_density_m2))

# we can plot this
ggplot(pottery_in_geology_density,
       aes(reorder(Type.x, 
                   as.numeric(point_density_m2)),
           as.numeric(point_density_m2))) +
  geom_col() +
  coord_flip() +
  xlab("Geology") +
  ylab("Points per m2") +
  theme_minimal()


#- point pattern analysis

library(spatstat) # see http://spatstat.github.io/

# compare point patterns in two geological units

pottery_in_Flysch <- 
  pottery_joined_to_geology %>% 
  filter(Type == "Flysch")

pottery_in_Rudist <- 
  pottery_joined_to_geology %>% 
  filter(Type == "Rudist bearing limestones")

# we need to create a new type of object, 'Planar point pattern'
pottery_in_Flysch_coords <- st_coordinates(pottery_in_Flysch)
pottery_in_Flysch_ppp <- 
  as.ppp(pottery_in_Flysch_coords,
         owin(range(pottery_in_Flysch_coords[ , "X"]),
              range(pottery_in_Flysch_coords[ , "Y"])))

pottery_in_Rudist_coords <- st_coordinates(pottery_in_Rudist)
pottery_in_Rudist_ppp <- 
  as.ppp(pottery_in_Rudist_coords,
         owin(range(pottery_in_Rudist_coords[ , "X"]),
              range(pottery_in_Rudist_coords[ , "Y"])))

# compute Ripley's K for randomness of point distribution
pottery_in_Flysch_ppp_K <- envelope(pottery_in_Flysch_ppp, Kest, global=TRUE)
pottery_in_Rudist_ppp_K <- envelope(pottery_in_Rudist_ppp, Kest, global=TRUE)

# visualise results
par(mfrow=c(2,2))
plot(pottery_in_Flysch_ppp)
plot(pottery_in_Rudist_ppp)
plot(pottery_in_Flysch_ppp_K)
plot(pottery_in_Rudist_ppp_K)


## Bonus: plot on google/osm/etc map layer

# convert UTM to long/lat 
library(rgdal)
pottery_coords <- pottery[ , 2:3]
sp_utm <- SpatialPoints(pottery_coords, 
                        proj4string=CRS("+proj=utm +zone=34N +datum=WGS84") ) 
sp_geo <- spTransform(sp_utm, 
                      CRS("+proj=longlat +datum=WGS84"))
pottery_sp <- SpatialPointsDataFrame(sp_geo, pottery)
pottery$lon <- coordinates(pottery_sp)[, 1]
pottery$lat <- coordinates(pottery_sp)[, 2]

# get the map layer
library(ggmap) # More: https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/ggmap/ggmapCheatsheet.pdf
map_center <- c(lon = mean(pottery$lon), 
                lat = mean(pottery$lat))

my_map <- get_map(location = map_center,
                  maptype =  "satellite", # or "terrain"
                  zoom = 13) # experiment with this number

# view base map
ggmap(my_map)

# add points
ggmap(my_map) +
  geom_point(data = pottery, 
             aes(x = lon,
                 y = lat),
             colour = "red")  

