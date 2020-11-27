# Analiza podatkov s programom R, 2020/21

Repozitorij z gradivi pri predmetu APPR v študijskem letu 2020/21

* [![Shiny](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/tiakrofel/APPR-2020-21/master?urlpath=shiny/APPR-2020-21/projekt.Rmd) Shiny
* [![RStudio](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/tiakrofel/APPR-2020-21/master?urlpath=rstudio) RStudio

## Analiza socialno-gospodarskih razlik med zveznimi državami ZDA

Analizirala bom socialne in gospodarske razmere v posameznih zveznih državah ZDA 
v letu 2019, in sicer njihovo starostno, spolno in rasno sestavo,
mediano letnih dohodkov gospodinjstev, 
delež prebivalstva, ki živi v revščini,
delež otrok (od 3 do 17 let), ki se trenutno šolajo, in
kolikšen delež le-teh obiskuje privatne šole.
Ogledala si bom še realni BDP na prebivalca v zadnjih desetih letih (2010-2019) 
ter kam in kako močno se je posamezna zvezna država politično nagibala na volitvah 
zadnjega desetletja (uporabila bom Cook Partisan Votig Index, krajše PVI).

Nato bom analizirala, kako se je gibanje BDP na prebivalca v zadnjih desetih letih
odražalo na politični usmerjenosti posamezne zvezne države in
na trenutnih socialnih in gospodarskih razmerah.

Na koncu si bom ogledala še, kateri socialni oz. gospodarski kazalniki so 
trenutno skupni zveznim državam, ki se s PVI (Partisan Voting Index) nagibajo 
bolj na republikansko oz. na demokratsko stran.

Prav tako bom iskala medsebojne odvisnosti med analiziranimi trenutnimi 
razmerami v vseh zveznih državah.

Viri: 
* https://data.census.gov/cedsci/ - CSV, XLSX
* https://www.bea.gov/tools/ - CSV,
* https://en.wikipedia.org/ - HTML

Vrstice bodo v vseh tabelah predstavljale posamezne zvezne države, 
ki bodo specificirane v prvem stolpcu,
v ostalih stolpcih pa si bom ogledala naslednje spremenljivke:

1. tabela - `lastnosti prebivalstva`: 
* št. prebivalcev, mediana starosti prebivalcev, delež moškega prebivalstva, delež belega prebivalstva 
2. tabela - `dohodki, revščina in otroci v šolanju`: 
* mediana letnih dohodkov gospodinjstev, delež revnega prebivalstva,
delež trenutno šolanih otrok od 3 do 17 let, delež od teh otrok v privatnih šolskih ustanovah
3. tabela - `politična usmerjenost`: 
* PVI (na podlagi volitev v zadnjem desetletju)
4. tabela - `BDP na prebivalca v zadnjih desetih letih`: 
* Leto, BDP per capita


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
