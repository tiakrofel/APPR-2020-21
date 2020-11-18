# Analiza podatkov s programom R, 2020/21

Repozitorij z gradivi pri predmetu APPR v študijskem letu 2020/21

* [![Shiny](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/tiakrofel/APPR-2020-21/master?urlpath=shiny/APPR-2020-21/projekt.Rmd) Shiny
* [![RStudio](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/tiakrofel/APPR-2020-21/master?urlpath=rstudio) RStudio

## Analiza socialno-gospodarskih razlik med zveznimi državami ZDA

Analizirala bom socialne in gospodarske razmere v posameznih zveznih državah ZDA v letu 2019, 
in sicer njihovo starostno in spolno sestavo,
povprečni mesečni dohodek gospodinjstev, 
delež otrok (od 3 do 17 let), ki se trenutno šolajo, 
kolikšen delež le-teh obiskuje privatne šole,
delež prebivalstva, ki živi v revščini,
rasno raznolikost,
BDP per capita in
ali so politična nagnjenja v posamezni zvezni državi republikanska ali demokratična (PVI).

Zvezne države bom med sabo primerjala glede na BDP na prebivalca in si ogledala, kako je bila višina BDPpc leta 2019 povezana z ostalimi zgorja omenjenimi dejavniki.

Na koncu si bom ogledala še, kateri socialni oz. gospodarski kazalniki so skupni zveznim državam, ki se s PVI (Partisan Voting Index) nagibajo bolj na republikansko oz. na demokratsko stran.

Podatke bom jemala iz leta 2019, PVI pa si bom ogledala na podlagi vseh volitev v zadnjem desetletju.

Viri: 
*https://data.census.gov/cedsci/ - CSV,
*https://www.bea.gov/tools/ - CSV,
*https://en.wikipedia.org/ - HTML

Vrstice bodo v vseh tabelah predstavljale posamezne zvezne države, ki bodo specificirane v prvem stolpcu,
v ostalih stolpcih pa si bomo ogledali navedene spremenljivke

*1. tabela - `lastnosti prebivalstva`: 
        št. prebivalcev || mediana starosti prebivalcev || delež moškega prebivalstva || delež belega prebivalstva 
*2. tabela - `dohodek in revščina`:
        povprečen dohodek gospodinjstva || mediana dohodka gospodinjstev || delež revnega prebivalstva
*3. tabela - `otroci (od 3 do 17 let) v šolanju`:
        delež trenutno šolanih otrok od 3 do 17 let || delež od teh otrok v privatnih šolskih ustanovah
*4. tabela - `BDP na prebivalca in politična usmerjenost`:
        BDP per capita || PVI


## Program

Glavni program in poročilo se nahajata v datoteki `projekt.Rmd`.
Ko ga prevedemo, se izvedejo programi, ki ustrezajo drugi, tretji in četrti fazi projekta:

* obdelava, uvoz in čiščenje podatkov: `uvoz/uvoz.r`
* analiza in vizualizacija podatkov: `vizualizacija/vizualizacija.r`
* napredna analiza podatkov: `analiza/analiza.r`

Vnaprej pripravljene funkcije se nahajajo v datotekah v mapi `lib/`.
Podatkovni viri so v mapi `podatki/`.
Zemljevidi v obliki SHP, ki jih program pobere,
se shranijo v mapo `../zemljevidi/` (torej izven mape projekta).

## Potrebni paketi za R

Za zagon tega vzorca je potrebno namestiti sledeče pakete za R:

* `knitr` - za izdelovanje poročila
* `rmarkdown` - za prevajanje poročila v obliki RMarkdown
* `shiny` - za prikaz spletnega vmesnika
* `DT` - za prikaz interaktivne tabele
* `rgdal` - za uvoz zemljevidov
* `rgeos` - za podporo zemljevidom
* `digest` - za zgoščevalne funkcije (uporabljajo se za shranjevanje zemljevidov)
* `readr` - za branje podatkov
* `rvest` - za pobiranje spletnih strani
* `tidyr` - za preoblikovanje podatkov v obliko *tidy data*
* `dplyr` - za delo s podatki
* `gsubfn` - za delo z nizi (čiščenje podatkov)
* `ggplot2` - za izrisovanje grafov
* `mosaic` - za pretvorbo zemljevidov v obliko za risanje z `ggplot2`
* `maptools` - za delo z zemljevidi
* `tmap` - za izrisovanje zemljevidov
* `extrafont` - za pravilen prikaz šumnikov (neobvezno)

## Binder

Zgornje [povezave](#analiza-podatkov-s-programom-r-202021)
omogočajo poganjanje projekta na spletu z orodjem [Binder](https://mybinder.org/).
V ta namen je bila pripravljena slika za [Docker](https://www.docker.com/),
ki vsebuje večino paketov, ki jih boste potrebovali za svoj projekt.

Če se izkaže, da katerega od paketov, ki ji potrebujete, ni v sliki,
lahko za sprotno namestitev poskrbite tako,
da jih v datoteki [`install.R`](install.R) namestite z ukazom `install.packages`.
Te datoteke (ali ukaza `install.packages`) **ne vključujte** v svoj program -
gre samo za navodilo za Binder, katere pakete naj namesti pred poganjanjem vašega projekta.

Tako nameščanje paketov se bo izvedlo pred vsakim poganjanjem v Binderju.
Če se izkaže, da je to preveč zamudno,
lahko pripravite [lastno sliko](https://github.com/jaanos/APPR-docker) z želenimi paketi.

Če želite v Binderju delati z git,
v datoteki `gitconfig` nastavite svoje ime in priimek ter e-poštni naslov
(odkomentirajte vzorec in zamenjajte s svojimi podatki) -
ob naslednjem zagonu bo mogoče delati commite.
Te podatke lahko nastavite tudi z `git config --global` v konzoli
(vendar bodo veljale le v trenutni seji).
