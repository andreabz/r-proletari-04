# R per proletari - Episodio 04

**R per proletari** è una serie di post su LinkedIn dedicata a chi vuole
liberarsi dal giogo del lavoro manuale e automatizzare la produzione di report
ripetitivi con la potenza collettiva di **R**, **Quarto** e **Shiny**.

In questo *episodio 04*, il proletariato può contare su uno Stachánov di silicio
pronto a creare su richiesta bollettini della qualità dell'aria per qualunque data
e provincia dell'Emilia-Romagna. I dati utilizzati sono quelli dei compagni di 
**ARPA Emilia-Romagna** sui principali inquinanti atmosferici.

---

## Obiettivi

- Creare una interfaccia che permetta all'utente di selezionare la provincia, la data e il parametro di interesse.  
- Scaricare i dati necessari dalle [API di ARPA Emilia-Romagna](https://dati.arpae.it/datastore/dump/4dc855a1-6298-4b71-a1ae-d80693d43dcb).  
- Analizzare i dati secondo i criteri del  
  [Decreto Legislativo 155/2010](https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:decreto.legislativo:2010-08-13;155).  
- Generare a richiesta i dati del bollettino.

👉 L'applicazione è disponibile su:  
[https://abazz.shinyapps.io/r-proletari-04/](https://abazz.shinyapps.io/r-proletari-04/)

---

## Struttura del progetto

- `ui.R` – definisce l'interfaccia grafica dell'applicazione.  
- `server.R` – definisce la reattività e la logica dell'applicazione.  
- `global.R` – script per caricare le librerie e gli script necessari.  
- `R/` – funzioni per scaricare, pulire e analizzare i dati.  
- `data/` – archivio dei dati grezzi delle anagrafiche.  
- `renv/` + `renv.lock` – ambiente R riproducibile e condivisibile.

---

## Requisiti

- **R >= 4.2**  
- Tutti i pacchetti R sono gestiti tramite **renv**.

---

## Setup

1. Clonare il repository:

   ```bash
   git clone https://github.com/andreabz/r-proletari-04.git
   cd r-proletari-04
   ```
   
2. Inizializzare l'applicazione

   ```r
   renv::restore()
   runApp()
   ```
   
## Criteri di valutazione dei dati secondo il Decreto Legislativo 155/2010

Il report confronta i dati osservati con i valori limite di legge, ad esempio:

- PM10 → media giornaliera ≤ 50 µg/m³ (max 35 superamenti/anno).
- NO₂ → max oraria ≤ 200 µg/m³ (max 18 superamenti/anno).
- O₃ → max media mobile 8h ≤ 120 µg/m³ (max 25 superamenti/anno).
- CO → max media mobile 8h ≤ 10 mg/m³.
- SO₂ → max giornaliera ≤ 125 µg/m³ (max 3 superamenti/anno).
- SO₂ → max oraria ≤ 350 µg/m³ (max 24 superamenti/anno).

## Output

Una applicazione web `shiny` disponibile all'indirizzo [https://abazz.shinyapps.io/r-proletari-04/](https://abazz.shinyapps.io/r-proletari-04/)

## Contatti e contributi

Il codice è libero come dev'essere la conoscenza: ogni compagno o compagna può **leggerlo, copiarlo, migliorarlo o farne una propria versione**.  
Le *pull request* sono benvenute, purché portino avanti la causa della **trasparenza e dell’efficienza proletaria**.

📬 **Scrivici:** [LinkedIn](https://it.linkedin.com/in/andreabazzano)  
💻 **Partecipa:** [GitHub](https://github.com/andreabz/)

Ogni bug è una **contraddizione interna del sistema**: segnalarlo è un atto rivoluzionario.  
Se l'app ti è utile, **condividila**.  
Se ti piace, **forkala**.  
Se non funziona, **riparala**.  
L’importante è **non restare fermi**.

> *“La statistica al servizio del popolo, non del profitto.”*
