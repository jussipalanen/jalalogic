# JalaLogic Lite – ohje suomeksi

JalaLogic Lite on pieni opetuskäyttöön tehty metsänosturin
ohjauksen simulaattori. Se on kirjoitettu IEC 61131-3
Structured Text -kielellä CODESYS V3:lle, ja se on osa
PLC-ohjelmoinnin portfoliota.

> **Vain simulaatio.** Projektia ei saa kytkeä oikeaan koneeseen.
> Simuloitu hätäseis ja liikerajat **eivät** ole sertifioituja
> turvatoimintoja, eikä projekti täytä mitään koneturvallisuus­standardia.

Tarkemmat englanninkieliset ohjeet ovat tiedostossa
[README.md](../README.md) ja kansiossa [docs/](.).

## Mitä simulaattori tekee

- Puomi ylös ja alas, kun painiketta pidetään pohjassa
- Puomin asento 0–100 %, laskettu PLC:n kiertoajasta
- Ylä- ja alaraja: puomi pysähtyy rajalle
- Hidastus 30 %:n nopeuteen viimeisellä 10 %:lla ennen rajaa
- Kahmari auki ja kiinni; kahmari pysyy ennallaan vian aikana
- Ristiriitaiset komennot (ylös + alas, auki + kiinni) eivät liikuta mitään
- Simuloitu hätäseis ja simuloitu hydrauliikkavika
- Viat jäävät päälle, kunnes ne kuitataan RESET-painikkeella

## Mitä tarvitset

- CODESYS Development System V3.5 (ilmainen, sisältää simulaation)
- Git
- Valinnainen: Git Bash, jos haluat käyttää `./dev`-skriptiä

## Asennus

1. Asenna CODESYS V3.5.
2. Kloonaa repositorio:

   ```
   git clone https://github.com/jussipalanen/jalalogic.git
   ```

3. Avaa CODESYSissa tiedosto `codesys/JalaLogicLite.project`.

## Simulaation käynnistys

1. CODESYSissa: **Online > Simulation**.
2. **Online > Login** (`Alt+F8`).
3. **Debug > Start** (`F5`).
4. Avaa visualisointi `VIS_Main`.

Selainkäyttö (WebVisu) vaatii CODESYS Control Win V3 -ohjelmallisen
PLC:n IDE:n simulaattorin sijaan. Ohje on tiedoston
[VISUALIZATION.md](VISUALIZATION.md) kohdassa 9.

## Käyttöliittymä

| Painike         | Toiminta                                                   |
|-----------------|------------------------------------------------------------|
| BOOM UP         | Pidä pohjassa: puomi nousee                                |
| BOOM DOWN       | Pidä pohjassa: puomi laskee                                |
| GRAPPLE OPEN    | Avaa kahmarin                                              |
| GRAPPLE CLOSE   | Sulkee kahmarin                                            |
| E-STOP          | Simuloitu hätäseis päälle / pois                           |
| SIMULATE FAULT  | Simuloitu hydrauliikkavika päälle / pois                   |
| RESET           | Kuittaa vian                                               |

Merkkivalot:

- **Ready** (vihreä): järjestelmä on valmis, ei vikaa
- **Upper limit / Lower limit** (keltainen): puomi on ylä- tai alarajalla
- **Moving up / Moving down** (sininen): puomi liikkuu
- **Grapple open** (vihreä): kahmari on auki
- **Fault** (punainen): vika on päällä

Tilarivi näyttää käyttäjälle tärkeimmän viestin.

## Vian kuittaus

Kun hätäseis tai simuloitu vika laukeaa, kaikki liike pysähtyy.
Vika kuitataan näin:

1. Poista vian syy (vapauta E-STOP tai SIMULATE FAULT).
2. Vapauta kaikki liikepainikkeet.
3. Paina **RESET**.

RESET ei koskaan käynnistä liikettä itsestään. Jos vian syy on vielä
päällä, RESET ei kuittaa vikaa.

## Koodin muokkaaminen

- Ohjauslogiikka on lohkossa `FB_CraneControl`
  ([src/POUs/FB_CraneControl.st](../src/POUs/FB_CraneControl.st)).
- `PLC_PRG` kutsuu lohkoa ja kytkee sen käyttöliittymän muuttujiin.
- Visualisoinnissa ei ole logiikkaa.

Muokkaa koodia `src/*.st`-tiedostoissa ja siirrä muutokset projektiin
Git Bashissa:

```bash
cp .dev.env.example .dev.env   # kerran: aseta CODESYS-polku ja profiili
./dev sync                     # kopioi src/ projektiin ja kääntää sen
```

Sulje projekti CODESYSissa (**File > Close Project**) ennen
`./dev sync` -komentoa. Uudet POUt ja DUTit pitää ensin luoda
CODESYSissa. Lisätietoa: [DEV_WORKFLOW.md](DEV_WORKFLOW.md).

Älä avaa tiedostoa `JalaLogicLite.project` tekstieditorissa. Se on
binääritiedosto ja menee rikki.

## Testaus

Testitapaukset ja niiden tulokset ovat tiedostossa
[TESTING.md](TESTING.md). Merkitse jokaisesta testistä, onko se
ajettu simulaatiossa vai vielä tekemättä.

## Osallistuminen

Muutokset `main`-haaraan tehdään vain pull requestin kautta, ja
projektin omistaja tarkistaa ne. Käytä haaroja `feature/*`, `fix/*`
tai `docs/*` ja Conventional Commits -viestejä (esim. `fix: ...`).

## Tekoälyn käyttö

Koodi ja dokumentaatio on tehty tekoälyavustajan avulla. Tekijä
tarkistaa kaiken koodin ennen julkaisua. Käännös- ja testitulokset
kirjataan vasta, kun ne on oikeasti ajettu CODESYSissa.
