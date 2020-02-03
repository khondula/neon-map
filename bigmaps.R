library(mapview)
library(leaflet)
library(sf)
library(readr)

data_dir <- "/nfs/public-data/NEON_workshop_data/bigmaps"

site_centroids <- read_csv("data/site_centroids.csv")

neon_sites_sf <- readr::read_csv("data/field-sitesNEON.csv") %>%
  sf::st_as_sf(neon_sites, 
               coords = c('Longitude', 'Latitude'),
               crs = 4326)

save_bigmap <- function(site_no){
  
  mp <- leaflet(neon_sites_sf) %>%
    setView(lng = site_centroids$X[site_no], 
            lat = site_centroids$Y[site_no], 
            zoom = 16) %>%
    addProviderTiles(providers$Esri.WorldImagery, group = "Esri World Imagery") %>%
    addPolygons(data = all_aops_sf, fillOpacity = 0, opacity = 1, color = "red") 
  
  
  mapshot(mp, 
          file = glue::glue("{data_dir}/map_site-{site_no}.pdf"), 
          vwidth = 12000, vheight = 8000)
}

save_bigmap(site_no = 1)
purrr::walk(11:70, ~save_bigmap(.x))
