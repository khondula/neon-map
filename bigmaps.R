library(mapview)
library(leaflet)
library(sf)
library(readr)

data_dir <- "/nfs/public-data/NEON_workshop_data/bigmaps"

site_centroids <- read_csv("data/site_centroids.csv")

neon_sites <- readr::read_csv("data/field-sitesNEON.csv")

neon_sites_sf <- sf::st_as_sf(neon_sites, 
                              coords = c('Longitude', 'Latitude'),
                              crs = 4326)

save_bigmap <- function(site_no, my_vwidth = 12000, my_vheight = 8000){
  
  mp <- leaflet(neon_sites_sf) %>%
    setView(lng = site_centroids$X[site_no], 
            lat = site_centroids$Y[site_no], 
            zoom = 16) %>%
    addProviderTiles(providers$Esri.WorldImagery, group = "Esri World Imagery") %>%
    addPolygons(data = all_aops_sf, weight = 10, 
                fillOpacity = 0, opacity = 1, color = "yellow") 
  
  
  mapshot(mp, 
          file = glue::glue("{data_dir}/map_site-{site_no}.pdf"), 
          vwidth = my_vwidth, vheight = my_vheight)
}

save_bigmap(site_no = 17, my_vwidth = 16000)
save_bigmap(site_no = 19, my_vheight = 9000)
save_bigmap(site_no = 20, my_vheight = 9000)

# purrr::walk(11:70, ~save_bigmap(.x))
