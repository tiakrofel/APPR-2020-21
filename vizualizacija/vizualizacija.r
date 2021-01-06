# 3. faza: Vizualizacija podatkov

source("lib/libraries.r", encoding="UTF-8")

# Združitev podatkov o BDP in politični usmerjenosti
zdruzitev <- cetrta_tabela %>%
  inner_join(tretja_tabela, Zvezna_drzava=Zvezna_drzava)

# Izračun BDP per capita za posamezno zvezno državo
osnova <- zdruzitev %>%
  group_by(Zvezna_drzava) %>%
  summarise(BDPpp = round(10^6 * BDP/Populacija, 0),
            Leto = Leto, Stranka = Stranka, Nagib = Nagib)

# Izolirano leto 2019, za katerega imamo tudi podatke o lastnoastih prebivalstva in socialnih kazalnikih
osnova_2019 <- osnova %>%
  filter(Leto == 2019) %>%
  select(-Leto)

# Preoblikovanje prve tabele, da bomo kasneje lažje delali s podatki o lastnostih prebivalstva
raz_prva <- prva_tabela %>%
  pivot_wider(names_from=Lastnost_prebivalstva, values_from=Vrednost) %>%
  group_by(Zvezna_drzava) %>%
  summarise(Delez_belci = round(Belci/Prebivalstvo, 3), 
            Delez_moski=round(`Razmerje_spolov`/(`Razmerje_spolov` + 100), 3),
            Mediana_starosti=Mediana_starosti)

# Preoblikovanje druge tabele, da bomo kasneje lažje delali s podatki o socialnih kazalnikih
raz_druga <- druga_tabela %>%
  pivot_wider(names_from=Socialni_kazalnik, values_from=Vrednost)

# Združitev podatkov o socialnih kazalnikih in BDP ter politične usmerjenosti za leto 2019
sk <- druga_tabela %>%
  inner_join(osnova_2019, Zvezna_drzava=Zvezna_drzava) %>%
  group_by(Zvezna_drzava) %>%
  pivot_wider(names_from=Socialni_kazalnik, values_from=Vrednost) 

# Graf s porazdelitvijo BDP-ja leta 2019
graf.eks <- ggplot(osnova_2019 %>%
                     filter(Stranka %in% c("R", "D")) %>%
                     group_by(Stranka) %>%
                     summarise(bdp=BDPpp, Stranka=Stranka),
                   aes(x=Stranka, y=bdp, group=Stranka)) + 
  geom_violin(aes(fill=Stranka), show.legend=FALSE) + scale_fill_manual(values = c("Lightblue", "Indianred")) +
  ylab("BDP na prebivalca ($)") + 
  ggtitle("Porazdelitev BDP na prebivalca leta 2019 glede na politično nagnjenost")
  

# Graf, ki prikazuje gibanje BDP per capita in politično usmerjenost v letih 2010 - 2019 za vsako zvezno državo posebej

graf.posamezne.bdp.stranka <- ggplot(osnova,
       aes(x=Leto, y=BDPpp, group=Zvezna_drzava, colour=Stranka)) + 
  scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  geom_line() + facet_wrap(~Zvezna_drzava, ncol=7) +
  scale_x_continuous(breaks = c(2012, 2017))  +
  scale_y_continuous(breaks = c(40000, 80000)) +
  xlab("Leto") + ylab("BDP na prebivalca ($)") +
  ggtitle("Spreminjanje BDP na prebivalca skozi zadnje desetletje")

graf.stranki.bdp <- ggplot(osnova %>%
                             group_by(Stranka, Leto) %>%
                             summarise(bdp = mean(BDPpp), Leto=Leto, Stranka=Stranka),
                           aes(x=Leto, y=bdp, colour=Stranka)) +
  scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  geom_line() + geom_point() + 
  scale_x_continuous(breaks = c(2010, 2013, 2016, 2019))  +
  xlab("Leto") + ylab("BDP na prebivalca ($)") +
  ggtitle("Povprečen BDP na prebivalca glede na politična nagnjenja")
  

# Povezava med BDPpp v letu 2019 in ostalimi dejavniki ter strankami

graf.bdp19.stranka <- ggplot(osnova_2019,
      aes(x=Stranka, y=BDPpp, colour=Stranka, size=Nagib)) +
  scale_colour_manual(values = c("Blue", "Gray", "Red")) +
  geom_point()

graf.bdp19.dohodki <- ggplot(osnova_2019 %>%
                               inner_join(raz_druga, Zvezna_drzava=Zvezna_drzava),
                             aes(x=Mediana_dohodkov, y=BDPpp, colour=Stranka, size=Nagib)) + 
  geom_point() + scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  xlab("Mediana letnih dohodkov") + ylab("BDP na prebivalca ($)") +
  ggtitle("Mediana letnih dohodkov in BDP per capita leta 2019 ($)") +
  labs(size="Intenziteta nagiba proti stranki")

# Medsebojne odvisnosti posameznih lastosti prebivalstva

graf.belci.spoli <- ggplot(raz_prva %>% 
                             inner_join(osnova_2019, Zvezna_drzava=Zvezna_drzava),
                           aes(x=Delez_belci, y=Delez_moski, colour=Stranka, size=BDPpp)) +
  geom_point() + scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  xlab("Delež belega prebivalstva") + ylab("Delež moškega prebivalstva") +
  ggtitle("Delež moškega in belega prebivalstva leta 2019") + 
  labs(size="BDP per capita")

graf.starosti.spoli <- ggplot(raz_prva %>% 
                             inner_join(osnova_2019, Zvezna_drzava=Zvezna_drzava),
                           aes(x=Mediana_starosti, y=Delez_moski, colour=Stranka, size=BDPpp)) +
  geom_point() + scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  xlab("Mediana starosti") + ylab("Delež moškega prebivalstva") +
  ggtitle("Mediana starosti in delež moškega prebivalstva leta 2019") + 
  labs(size="Višina BDP per capita")


# Medsebojne odvisnosti posameznih socialnih kazalnikov

graf.dohodek.revni <- ggplot(sk, aes(x=Delez_revnih, y=Mediana_dohodkov, colour=Stranka, size=BDPpp)) +
  geom_point() +
  scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) + 
  xlab("Delež revnega prebivalstva") + 
  ylab("Mediana letnih dohodkov ($)") +
  ggtitle("Delež revnega prebivalstva in mediana letnih dohodkov leta 2019") + 
  labs(size="BDP per capita")

graf.solani.privat <- ggplot(sk %>%
                               group_by(Zvezna_drzava) %>%
                               summarise(solanih=round(Solani/Otroci,3),Delez_privat=Delez_privat,Stranka=Stranka,BDPpp=BDPpp),
                             aes(x=solanih, y=Delez_privat, colour=Stranka, size=BDPpp)) +
  geom_point() +
  scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) + 
  xlab("Delež šolanih otrok") + 
  ylab("Delež otrok v privat šolah") +
  ggtitle("Delež šolanih otrok in delež otrok v privat šolskih ustanovah leta 2019") + 
  labs(size="BDP per capita")


# Zbrani podatki za delo z zemljevidom

tab.z <- osnova_2019 %>%
  group_by(Zvezna_drzava) %>%
  summarise(barva=Stranka, st=Nagib, bdp=BDPpp)

# Uvozimo zemljevid

zemljevid <- uvozi.zemljevid("https://alicia.data.socrata.com/api/geospatial/jhnu-yfrj?method=export&format=Original", 
                             "states", encoding="UTF-8")

# Prvi zemljevid z obarvanimi zveznimi državami glede na politična nagibanja

map1 <- tm_shape(merge(zemljevid, tab.z, by.x="STATE_NAME", by.y="Zvezna_drzava"), simplify = 0.2) +
  tm_polygons("barva", legend.hist=TRUE, title="Politična usmerjenost", 
              palette = c("lightblue","gray","indianred")) + 
  tm_layout(legend.outside=TRUE) + 
  tm_text("STATE_ABBR", size=0.3)

# Drugi zemljevid prikazuje višino BDP na prebivalca v letu 2019, in sicer s temnejše obarvanimi zveznimi državimi, kjer je bil BDP per capita višji

map2 <- tm_shape(merge(zemljevid, tab.z, by.x="STATE_NAME", by.y="Zvezna_drzava"), simplify = 0.2) +
  tm_polygons("bdp", legend.hist=TRUE, title="BDP per capita leta 2019", palette = "Greys") + 
  tm_layout(legend.outside=TRUE) + tm_text("STATE_ABBR", size=0.3) 








