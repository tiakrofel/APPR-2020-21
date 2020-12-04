library(dplyr)
library(tidyr)
library(readr)
library(rvest)
library(gsubfn)
library(openxlsx)
library(readxl)

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
st.pop <- c("Zvezna_drzava", "St_prebivalcev",
            "Mediana_starosti",
            "St_moski_na_100_zensk")
st.doh <- c("Zvezna_drzava", "Letni_dohodki",
            "Mediana_letnih_dohodkov",
            "Povprecje_letnih_dohodkov")
st.rase <- c("Zvezna_drzava", "St_prebivalcev", "St_belcev")
st.revni <- c("Zvezna_drzava", "Delez_revnih")
st.sol <- c("Zvezna_drzava", "St_otrok_3-17", 
            "St_solanih_otrok", 
            "Delez_javno_solstvo",
            "Delez_v_privat_solstvu")
max.pop <- 4
max.doh <- 4
max.rase <- 2
max.revni <- 4
max.sol <- 4


ljudje <- uvozi.csv(tabela.pop, st.pop, max.pop) 
denar <- uvozi.csv(tabela.doh, st.doh, max.doh)[-c(2,4)] 
belci <- uvozi.csv(tabela.rase, st.rase, max.rase)
revni <- uvozi.csv(tabela.revni, st.revni, max.revni)
sola <- uvozi.csv(tabela.sol, st.sol, max.sol)[-4]

# Prva tabela
delez.belcev <- function() {
  belci %>%
    mutate("Delez_belcev"=round(`St_belcev`/`St_prebivalcev`, 3)) %>%
    select(-c(2:3))
}
delez.moskih <- function() {
  ljudje %>%
    mutate("Delez_moskih"=round(`St_moski_na_100_zensk`/
                                  (`St_moski_na_100_zensk` + 100), 3)) %>%
    select(-4) %>%
    inner_join(delez.belcev(), `Zvezna_drzava`=`Zvezna_drzava`) %>%
    pivot_longer(c(-Zvezna_drzava), names_to="Lastnost_prebivalstva",
      values_to="Vrednost")  
}
prva_tabela <- delez.moskih()

# Druga tabela
delez.revnih <- function() {
  revni %>%
    mutate("Delez_revnih"=
             1e-2 * parse_number(`Delez_revnih`)) %>%
    inner_join(denar, `Zvezna_drzava`=`Zvezna_drzava`) %>%
    select(1,3,2)
}
delez.solanih <- function() {
  sola %>%
    mutate("St_otrok_3-17"=
             sapply(gsub
                    (",", "", `St_otrok_3-17`), as.numeric)) %>%
    mutate("St_solanih_otrok"=
             sapply(gsub
                    (",", "", `St_solanih_otrok`), as.numeric)) %>%
    mutate("Delez_solanih_otrok"=
             round(`St_solanih_otrok`/
                     `St_otrok_3-17`, 3)) %>%
    mutate("Delez_v_privat_solstvu"=
             1e-2 * sapply(gsub(
               "%", "", `Delez_v_privat_solstvu`), 
               as.numeric)) %>%
    select(c(1,-2,-3,5,4))
}
uvoz0 <- delez.revnih()
uvoz1 <- delez.solanih()
druga_tabela <- uvoz0 %>%
  inner_join(uvoz1, Zvezna_drzava=Zvezna_drzava) %>%
  pivot_longer(
    c(-Zvezna_drzava),
    names_to="Socialni_kazalnik",
    values_to="Vrednost"
  )

# Tretja tabela
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
tretja_tabela <- uvozi.html() %>%
  mutate(PVI = replace(PVI, PVI == "EVEN", "E+0")) %>%
  separate(PVI, into = c("Stranka", "Nagib"), sep = "\\+") %>%
  mutate(`Nagib` = sapply(`Nagib`, as.numeric))

# Četrta tabela
najprej.uvozi <- function() {
  uvoz <- read_csv("podatki/bdp_10-19.csv", locale=locale(encoding="utf-8"), 
                   skip=4, n_max=50)[-1]
  uvoz %>% rename("Zvezna_drzava"=1)
}
bdp_skozi_leta <- najprej.uvozi()

nato.uvozi <- function() {
  podatki <- read_xlsx("podatki/velikosti_populacij.xlsx", skip = 3, n_max = 59)
  podatki <- podatki[-c(1:5, 14, 57:59),-c(2:3)] 
  colnames(podatki)[1] <- "Zvezna_drzava"
  podatki %>%
    mutate("Zvezna_drzava"=gsub("^\\.", "", `Zvezna_drzava`))
}
uvoz2 <- nato.uvozi()

spremeni <- function() {
  for (i in 2:11) {
    uvoz2[i] <- round(10^6 * bdp_skozi_leta[i]/uvoz2[i], 0)
  }
  uvoz2 %>%
    pivot_longer(c(-1), names_to="Leto", values_to="BDPpp") %>%
    mutate(`Leto`=sapply(`Leto`, as.numeric))
} 
cetrta_tabela <- spremeni()

