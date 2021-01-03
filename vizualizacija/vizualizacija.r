# 3. faza: Vizualizacija podatkov

source("lib/libraries.r", encoding="UTF-8")

zdruzitev <- cetrta_tabela %>%
  inner_join(tretja_tabela, Zvezna_drzava=Zvezna_drzava)

osnova <- zdruzitev %>%
  group_by(Zvezna_drzava) %>%
  summarise(BDPpp = round(10^6 * BDP/Populacija, 0),
            Leto = Leto, Stranka = Stranka, Nagib = Nagib)

osnova_2019 <- osnova %>%
  filter(Leto == 2019) %>%
  select(-Leto)

raz_prva <- prva_tabela %>%
  pivot_wider(names_from=Lastnost_prebivalstva, values_from=Vrednost) %>%
  group_by(Zvezna_drzava) %>%
  summarise(Delez_belci = round(Belci/Prebivalstvo, 3), 
            Delez_moski=round(`Razmerje_spolov`/(`Razmerje_spolov` + 100), 3),
            Mediana_starosti=Mediana_starosti)

raz_druga <- druga_tabela %>%
  pivot_wider(names_from=Socialni_kazalnik, values_from=Vrednost)

sk1 <- druga_tabela %>%
  inner_join(tretja_tabela, Zvezna_drzava=Zvezna_drzava) %>%
  group_by(Zvezna_drzava) %>%
  filter(Socialni_kazalnik %in% c("Mediana_dohodkov", "Delez_revnih")) %>%
  pivot_wider(names_from=Socialni_kazalnik, values_from=Vrednost) 

graf.eks <- ggplot(osnova_2019 %>%
                     filter(Stranka %in% c("R", "D")) %>%
                     group_by(Stranka) %>%
                     summarise(bdp=BDPpp, Stranka=Stranka),
                   aes(x=Stranka, y=bdp, group=Stranka)) + 
  geom_violin(aes(fill=Stranka)) + scale_fill_manual(values = c("Lightblue", "Indianred")) +
  ylab("BDP na prebivalca ($)") +
  ggtitle("BDP na prebivalca v letu 2019 glede na politično usmerjenost")
  

# Graf, ki prikazuje gibanje BDP per capita in politično usmerjenost
# v letih 2010 - 2019 za vsako zvezno državo posebej

graf.posamezne.bdp.stranka <- ggplot(osnova,
       aes(x=Leto, y=BDPpp, group=Zvezna_drzava, colour=Stranka)) + 
  scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  geom_line() + facet_wrap(~Zvezna_drzava, ncol=7) +
  scale_x_continuous(breaks = c(2012, 2017))  +
  scale_y_continuous(breaks = c(40000, 80000)) +
  xlab("Leto") + ylab("BDP na prebivalca ($)") +
  ggtitle("Spreminjanje BDP na prebivalca skozi zadnje desetletje")


# Povezava med BDPpp v letu 2019 in ostalimi dejavniki ter strankami

graf.bdp19.stranka <- ggplot(osnova_2019,
      aes(x=Stranka, y=BDPpp, colour=Stranka)) +
  scale_colour_manual(values = c("Blue", "Gray", "Red")) +
  geom_point(aes(size=Nagib))

graf.bdp19.dohodki <- ggplot(osnova_2019 %>%
                               inner_join(raz_druga, Zvezna_drzava=Zvezna_drzava),
                             aes(x=Mediana_dohodkov, y=BDPpp, colour=Stranka)) + 
  geom_point(aes(size=Nagib)) + scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  xlab("Mediana dohodkov") + ylab("BDP na prebivalca ($)") +
  ggtitle("Mediana letnih dohodkov in BDP per capita leta 2019")

# Medsebojne odvisnosti posameznih lastosti prebivalstva

graf.belci.spoli <- ggplot(raz_prva %>% 
                             inner_join(tretja_tabela, Zvezna_drzava=Zvezna_drzava),
                           aes(x=Delez_belci, y=Delez_moski, colour=Stranka)) +
  geom_point(aes(size=Nagib)) + scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  xlab("Delež belega prebivalstva") + ylab("Delež moškega prebivalstva") +
  ggtitle("Deležem moškega in belega prebivalstva leta 2019")

graf.starosti.spoli <- ggplot(raz_prva %>% 
                             inner_join(tretja_tabela, Zvezna_drzava=Zvezna_drzava),
                           aes(x=Mediana_starosti, y=Delez_moski, colour=Stranka)) +
  geom_point(aes(size=Nagib)) + scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) +
  xlab("Mediana starosti") + ylab("Delež moškega prebivalstva") +
  ggtitle("Mediana starosti in delež moškega prebivalstva leta 2019")


# Medsebojne odvisnosti posameznih socialnih kazalnikov

graf.dohodek.revni <- ggplot(sk1, aes(x=Delez_revnih, y=Mediana_dohodkov, colour=Stranka)) +
  geom_point(aes(size=Nagib)) +
  scale_colour_manual(values = c("Lightblue", "Gray", "Indianred")) + 
  xlab("Delež revnega prebivalstva") + 
  ylab("Mediana letnih dohodkov ($)") +
  ggtitle("Delež revnega prebivalstva in mediana letnih dohodkov")


# Tabela za zemljevida

tab.z <- osnova_2019 %>%
  group_by(Zvezna_drzava) %>%
  summarise(barva=Stranka, st=Nagib, bdp=BDPpp)

# Uvozimo zemljevid.

zemljevid <- uvozi.zemljevid("https://alicia.data.socrata.com/api/geospatial/jhnu-yfrj?method=export&format=Original", 
                             "states", encoding="UTF-8")

map1 <- tm_shape(merge(zemljevid, tab.z, by.x="STATE_NAME", by.y="Zvezna_drzava"), simplify = 0.2) +
  tm_polygons("barva", legend.hist=TRUE, title="Politična usmerjenost", 
              palette = c("lightblue","gray","indianred")) + 
  tm_layout(legend.outside=TRUE) + 
  tm_text("STATE_ABBR", size=0.3)

map2 <- tm_shape(merge(zemljevid, tab.z, by.x="STATE_NAME", by.y="Zvezna_drzava"), simplify = 0.2) +
  tm_polygons("bdp", legend.hist=TRUE, title="BDP per capita leta 2019", palette = "Greys") + 
  tm_layout(legend.outside=TRUE) + tm_text("STATE_ABBR", size=0.3) 








