# 4. faza: Analiza podatkov

source("lib/libraries.r", encoding="UTF-8")

## Metoda voditeljev

podatki.vod <- osnova_2019 %>% ungroup %>% select(2) 
koncni <- podatki.vod %>% as.matrix() %>% scale()
vdtl <- kmeans(koncni, 3, nstart = 1e3)
razdelitev <- data.frame(Zvezna_drzava=osnova_2019$Zvezna_drzava, Skupina=factor(vdtl$cluster))

map3 <- tm_shape(merge(zemljevid, razdelitev, by.x="STATE_NAME", by.y="Zvezna_drzava"), simplify = 0.2) +
  tm_polygons("Skupina", palette = "Greys") + 
  tm_layout(legend.outside=TRUE) + tm_text("STATE_ABBR", size=0.3) 















