source("lib/libraries.r", encoding="UTF-8")

# Funkcija, ki uvozi podatke iz csv datotek  
uvozi.csv <- function(tabela, stolpci, max) {
  uvoz <- read_csv(tabela, locale=locale(encoding="utf-8"), n_max = max)
  uvoz <- uvoz %>%
    select(-c(10,53)) %>% 
    pivot_longer(c(-Label), names_to="STATE", values_to="POPULACIJA") %>%
    pivot_wider(names_from = Label, values_from = POPULACIJA)
  colnames(uvoz) <- stolpci
  uvoz$`Zvezna_drzava` <- gsub("[\\!].*", "", uvoz$`Zvezna_drzava`)
  return(uvoz)
}

tabela.pop <- "podatki/prebivalstvo.csv"
tabela.doh <- "podatki/dohodki.csv"
tabela.rase <- "podatki/rase.csv"
tabela.revni <- "podatki/revscina.csv" 
tabela.sol <- "podatki/solanje.csv"
st.pop <- c("Zvezna_drzava", "Prebivalstvo",
            "Mediana_starosti",
            "Razmerje_spolov")
st.doh <- c("Zvezna_drzava", "Letni_dohodki",
            "Mediana_dohodkov",
            "Povprecje_dohodkov")
st.rase <- c("Zvezna_drzava", "Prebivalstvo", "Belci")
st.revni <- c("Zvezna_drzava", "Delez_revnih")
st.sol <- c("Zvezna_drzava", "Otroci", 
            "Solani", 
            "Javno",
            "Delez_privat")
max.pop <- 4
max.doh <- 4
max.rase <- 2
max.revni <- 4
max.sol <- 4

# Funkcija, ki uvozi podatke iz Wikipedije
uvozi.html <- function(){
  link <- "https://en.wikipedia.org/wiki/Cook_Partisan_Voting_Index#By_state"
  stran <- html_session(link) %>% read_html()
  tabela <- stran %>% 
    html_nodes(xpath="//table[@class='wikitable sortable']") %>%
    .[[1]] %>% html_table()
  for (i in 1:ncol(tabela)) {
    if (is.character(tabela[[i]])) {
      Encoding(tabela[[i]]) <- "UTF-8"
    }
  }
  colnames(tabela) <- c("Zvezna_drzava", "PVI")
  return(tabela[1:2])
}

ljudje <- uvozi.csv(tabela.pop, st.pop, max.pop) 
denar <- uvozi.csv(tabela.doh, st.doh, max.doh)[-c(2,4)] 
belci <- uvozi.csv(tabela.rase, st.rase, max.rase)
revni <- uvozi.csv(tabela.revni, st.revni, max.revni)
sola <- uvozi.csv(tabela.sol, st.sol, max.sol)[-4]

# Prva tabela
prva <- function() {
  ljudje %>% inner_join(belci, Zvezna_drzava=Zvezna_drzava) %>%
  pivot_longer(
    c(-Zvezna_drzava),
    names_to="Lastnost_prebivalstva",
    values_to="Vrednost"
  )
}
prva_tabela <- prva()

# Druga tabela
delez.revnih <- function() {
  revni %>%
    mutate("Delez_revnih"=
             1e-2 * parse_number(`Delez_revnih`)) %>%
    inner_join(denar, `Zvezna_drzava`=`Zvezna_drzava`) %>%
    select(1,3,2)
}
solanje <- function() {
  sola %>%
    mutate("Otroci"=
             sapply(gsub
                    (",", "", `Otroci`), as.numeric)) %>%
    mutate("Solani"=
             sapply(gsub
                    (",", "", `Solani`), as.numeric)) %>%
    mutate("Delez_privat"=
             1e-2 * sapply(gsub(
               "%", "", `Delez_privat`), 
               as.numeric)) 
}
uvoz0 <- delez.revnih()
uvoz1 <- solanje()
druga <- function() {
  uvoz0 %>%
  inner_join(uvoz1, Zvezna_drzava=Zvezna_drzava) %>%
  pivot_longer(
    c(-Zvezna_drzava),
    names_to="Socialni_kazalnik",
    values_to="Vrednost")
  }
druga_tabela <- druga()

# Tretja tabela
tretja <- function() {
  uvozi.html() %>%
  mutate(PVI = replace(PVI, PVI == "EVEN", "N+0")) %>%
  separate(PVI, into = c("Stranka", "Nagib"), sep = "\\+") %>%
  mutate(`Nagib` = sapply(`Nagib`, as.numeric))
  }
tretja_tabela <- tretja()

# Četrta tabela
uvozi.bdp <- function() {
  uvoz <- read_csv("podatki/bdp_10-19.csv", locale=locale(encoding="utf-8"), 
                   skip=4, n_max=50)[-1]
  uvoz %>% rename("Zvezna_drzava"=1) %>% 
    pivot_longer(c(-Zvezna_drzava), names_to="Leto", values_to="BDP")
  }
bdp <- uvozi.bdp()

uvozi.populacijo <- function() {
  podatki <- read_xlsx("podatki/velikosti_populacij.xlsx", skip = 3, n_max = 59)
  podatki <- podatki[-c(1:5, 14, 57:59),-c(2:3)] 
  colnames(podatki)[1] <- "Zvezna_drzava"
  podatki %>%
    mutate("Zvezna_drzava"=gsub("^\\.", "", `Zvezna_drzava`)) %>% 
    pivot_longer(c(-Zvezna_drzava), names_to="Leto", values_to="Populacija") 
}
populacija <- uvozi.populacijo()
cetrta <- function() {
   bdp %>% inner_join(populacija, Zvezna_drzava=Zvezna_drzava) %>%
     mutate(`Leto`=sapply(`Leto`, as.numeric))
 }
cetrta_tabela <- cetrta()













