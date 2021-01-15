# 4. faza: Analiza podatkov

source("lib/libraries.r", encoding="UTF-8")

## Predikcija

podatki.napoved <- osnova %>% group_by(Leto) %>% summarise(bdp = mean(BDPpp), Leto=Leto)
odst <- lm(data=podatki.napoved, formula = bdp ~ I(Leto) + I(Leto^2))
vm <- data.frame(Leto=seq(2020, 2022, 1))
napoved <- mutate(vm, "bdp"=predict(odst, vm))
podatki.napoved <- podatki.napoved %>% unique() %>% rbind(napoved) 

graf.odstopanje <- ggplot(podatki.napoved, aes(x=Leto, y=bdp)) + 
  geom_point() + 
  geom_smooth(method=lm, color="black", size=0.1, formula = y ~ I(x) + I(x^2)) +
  scale_x_continuous(breaks = c(2010, 2013, 2016, 2019, 2022))  +
  ylab("BDP na prebivalca ($)") + 
  ggtitle("Napoved gibanja povprečnega BDP per capita v ZDA")


## Metoda voditeljev

podatki.vod <- osnova_2019 %>% ungroup %>% select(2) %>% scale()
vdtl <- kmeans(podatki.vod, 3, nstart = 1e3)
razdelitev <- data.frame(Zvezna_drzava=osnova_2019$Zvezna_drzava, Skupina=factor(vdtl$cluster))

map3 <- tm_shape(merge(zemljevid, razdelitev, by.x="STATE_NAME", by.y="Zvezna_drzava"), simplify = 0.2) +
  tm_polygons("Skupina", palette = "Pastel1") + 
  tm_layout(legend.outside=TRUE) + tm_text("STATE_ABBR", size=0.3) 















