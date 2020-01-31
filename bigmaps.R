library(mapview)

site_centroids <- all_aops_centroids_sf %>% sf::st_coordinates() %>% as.data.frame()

mp <- leaflet(neon_sites_sf) %>%
  setView(lng = site_centroids$X[7], lat = site_centroids$Y[7], zoom = 16) %>%
  addProviderTiles(providers$Esri.WorldImagery, group = "Esri World Imagery") %>%
  # addMarkers(data = all_aops_centroids_sf, group = "AOP centroids") %>%
  addPolygons(data = aop_aqbox_sf, fillOpacity = 0, group = "Aquatic AOP",
              opacity = 1, color = "red") %>%
  addPolygons(data = aop_terrbox_sf, fillOpacity = 0,
              opacity = 1, color = "red", group = "Terrestrial AOP")

data_dir <- "/nfs/public-data/NEON_workshop_data/bigmaps"
mapshot(mp, file = paste0(data_dir, "/2map8000.pdf"), vwidth = 8000, vheight = 8000)

mapshot(mp, file = paste0(data_dir, "/map10000.pdf"), vwidth = 10000, vheight = 10000)


# mapshot(mp, file = paste0(getwd(), "/map.png"), vwidth = 1000, vheight = 1000)
# mapshot(mp, file = paste0(getwd(), "/map5000.png"), vwidth = 5000, vheight = 5000)
# 
# mapshot(mp, file = paste0(getwd(), "/map5000.pdf"), vwidth = 5000, vheight = 5000)
# mapshot(mp, file = paste0(getwd(), "/map50000.pdf"), vwidth = 50000, vheight = 50000)
# 
# mapshot(mp, file = paste0(getwd(), "/map.jpeg"))
