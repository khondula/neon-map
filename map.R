# Mapping Neon sites with human impacts

library(leaflet)
library(sf)
library(readr)
library(leaflet.extras)
# Read in neon sites
neon_sites <- readr::read_csv("data/field-sitesNEON.csv")

neon_sites_sf <- sf::st_as_sf(neon_sites, 
                              coords = c('Longitude', 'Latitude'),
                              crs = 4326)

neon_domains <- st_read("data/field-sites") %>% 
  sf::st_transform(4326)

# SHAPEFILES
# aop_path_aq <- "data/NEON_Aquatic_Site_Flight_Box_Shape_Files"
# aop_files_aq <- fs::dir_ls(aop_path_aq, regexp = ".shp$")

# aop_aqbox_list <- purrr::map(aop_files_aq, ~st_read(.x)) %>% 
#   purrr::map(~dplyr::rename(.x, Name = 1)) %>%
#   purrr::map(~dplyr::select(.x, Name, geometry))

# KML FilES
# aquatic sites
aop_path_aq <- "data/NEON_Aquatic_Site_Flight_Box_KMLs/"
aop_files_aq <- fs::dir_ls(aop_path_aq, regexp = ".kml$")

aop_aqbox_list <- purrr::map(aop_files_aq, ~st_read(.x)) %>% 
  purrr::map(~dplyr::select(.x, Name, geometry))

kml_names_aq <- names(aop_aqbox_list) %>% 
  basename() %>% 
  tools::file_path_sans_ext()

aop_aqbox_list <- 1:10 %>%
  purrr::map(~dplyr::mutate(aop_aqbox_list[[.x]], 
                            sitename = kml_names_aq[[.x]]))

aop_aqbox_sf <- st_as_sf(data.table::rbindlist(aop_aqbox_list)) %>% 
  st_zm() %>%
  # st_transform(32618) %>% 
  st_transform(4326)

# terrestrial sites
# aquatic sites
aop_path_terr <- "data/NEON_Terrestrial_Site_Flight_Box_KMLs/"
aop_files_terr <- fs::dir_ls(aop_path_terr, regexp = ".kml$")

aop_terrbox_list <- purrr::map(aop_files_terr, ~st_read(.x)) %>% 
  purrr::map(~dplyr::select(.x, Name, geometry)) 

kml_names <- names(aop_terrbox_list) %>% 
  basename() %>% 
  tools::file_path_sans_ext()

aop_terrbox_list <- 1:55 %>%
  purrr::map(~dplyr::mutate(aop_terrbox_list[[.x]], sitename = kml_names[[.x]]))

# aop_aqbox_list %>% purrr::map(~names(.x))

aop_terrbox_sf <- st_as_sf(data.table::rbindlist(aop_terrbox_list)) %>% 
  st_zm() %>%
  # st_transform(32618) %>% 
  st_transform(4326)

all_aops_sf <- rbind(aop_terrbox_sf, aop_aqbox_sf)
all_aops_centroids_sf <- all_aops_sf %>% 
  st_centroid(all_aops_sf, of_largest_polygon = TRUE)

# save centroids table
all_aops_centroids_sf %>% 
  sf::st_coordinates() %>%
  as.data.frame() %>%
  dplyr::mutate(sitename = all_aops_centroids_sf$sitename) %>%
  readr::write_csv("data/site_centroids.csv")

# all_aops_sf %>%
#   leaflet() %>%
#   addTiles() %>%
#   addPolygons()

nlcd_url <- 'https://www.mrlc.gov/geoserver/mrlc_display/NLCD_2016_Land_Cover_L48/ows'
nlcd_legend_uri <- 'https://www.mrlc.gov/geoserver/mrlc_display/NLCD_2016_Land_Cover_L48/ows?service=WMS&request=GetLegendGraphic&format=image%2Fpng&width=20&height=20&layer=NLCD_2016_Land_Cover_L48'

wbd <- "https://hydro.nationalmap.gov/arcgis/services/wbd/MapServer/WMSServer"
# 
# # LEAFLET MAP
leaflet(neon_sites_sf) %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Esri World Imagery") %>%
  addMarkers(data = all_aops_centroids_sf, group = "AOP centroids") %>%
  addWMSTiles(nlcd_url, layers = "NLCD_2016_Land_Cover_L48",
              options = WMSTileOptions(format = "image/png", transparent = TRUE),
              group = "NLCD") %>%
  # addWMSLegend(nlcd_legend_uri, group = "NLCD legend") %>%
  addWMSTiles(wbd, layers = "7",
              options = WMSTileOptions(format = "image/png", transparent = TRUE),
              group = "WBD transparent") %>%
  addPolygons(data = neon_domains, fillOpacity = 0, opacity = 1, weight = 0.5,
              color = "white", group = "Domains") %>%
  addPolygons(data = aop_aqbox_sf, fillOpacity = 0, group = "Aquatic AOP",
              opacity = 1, color = "red") %>%
  addPolygons(data = aop_terrbox_sf, fillOpacity = 0,
              opacity = 1, color = "red", group = "Terrestrial AOP") %>%
  addCircleMarkers(data = neon_sites_sf,
                   label = ~as.character(`Site Name`),
                   radius = 1, color = "yellow",
                   opacity = 1, group = "Site Names") %>%
  addLayersControl(baseGroups = c("Esri World Imagery", "NLCD"),
                   overlayGroups = c("Site Names","WBD transparent",
                                     # "NLCD legend",
                                     "Aquatic AOP", "Terrestrial AOP",
                                     "Domains",  "AOP centroids"),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  hideGroup(group = c("WBD transparent", "AOP centroids"))
            