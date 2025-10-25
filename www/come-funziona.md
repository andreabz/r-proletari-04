## Come funziona l’app

L'applicazione raccoglie tutto il lavoro svolto negli episodi precedenti, disponibile su [github](https://github.com/andreabz/) e [linkedin](https://it.linkedin.com/in/andreabazzano), e lo traduce in una interfaccia pronta all'uso.  
Con poche scelte – la provincia, la data, il parametro – ogni compagno può generare il proprio bollettino, un report dal sapore operaio, fatto di numeri che raccontano la realtà dell'aria che respiriamo.

- **Seleziona la provincia** – per sapere cosa accade a casa vostra, in città o in campagna.  
- **Scegli la data** – per leggere quel che è successo ieri, oggi o in un momento preciso della lotta contro i veleni.  
- **Indica il parametro** – ozono, NO₂, PM10 e altri contaminanti che soffocano il popolo.

Un clic su *“Genera bollettino”* ed è fatta: tabelle, grafici, analisi schiette, senza gergo borghese.

> *“Riposa compagno Stachánov,<br> ora il compagno silicio lavora per il popolo!”*

### Dietro le quinte

- raccolta dei dati attraverso l'API dai compagni di ARPAE Emilia-Romagna;  
- pulizia e armonizzazione delle informazioni, per una verità nitida e libera da misteri;  
- calcoli di medie e soglie per mostrare chi rispetta i limiti e chi aggredisce la salute del popolo;  
- visualizzazioni che trasformano numeri in immagini potenti, comprensibili a tutti.

### Uno strumento vivo, nato dalla comunità

L'app non è un prodotto chiuso ma uno spazio aperto, nato da una serie di post su LinkedIn e dalla
volontà di fare rete tra compagni informati.  
Ogni report è un grido di lotta, ogni clic un atto di partecipazione.  
Qui non si fanno pipeline ambiziose, non si allenano algoritmi al servizio del capitale: qui vogliamo sgravarci dal lavoro
ripetitivo e frustrante a cui siamo chiamati noi proletari del dato.

> *“Il lavoro ripetitivo uccide il proletario digitale:<br> ribellatevi e scrivete codice”*

### Struttura dell'applicazione

- `ui.R` – definisce l'interfaccia grafica dell'applicazione.
- `server.R` – definisce la reattività e la logica dell'applicazione.
- `global.R` – script per caricare le librerie e gli script necessari.  
- `R/` – funzioni per scaricare, pulire e analizzare i dati.  
- `data/` – archivio dei dati grezzi delle anagrafiche.  
- `renv/` + `renv.lock` – ambiente R riproducibile e condivisibile.

### Criteri di valutazione dei dati secondo il Decreto Legislativo 155/2010

Il report confronta i dati osservati con i valori limite di legge, ad esempio:

- PM10 → media giornaliera ≤ 50 µg/m³ (max 35 superamenti/anno).
- NO₂ → max oraria ≤ 200 µg/m³ (max 18 superamenti/anno).
- O₃ → max media mobile 8h ≤ 120 µg/m³ (max 25 superamenti/anno).
- CO → max media mobile 8h ≤ 10 mg/m³.
- SO₂ → max giornaliera ≤ 125 µg/m³ (max 3 superamenti/anno).
- SO₂ → max oraria ≤ 350 µg/m³ (max 24 superamenti/anno).

### Contatti e contributi

Il codice è libero come dev'essere la conoscenza: ogni compagno o compagna può leggerlo, copiarlo, migliorarlo o farne una propria versione.  
Le pull request sono benvenute, purché portino avanti la causa della trasparenza e dell'efficienza proletaria.

📬 **Scrivici** su [LinkedIn](https://it.linkedin.com/in/andreabazzano) o unisciti allo sviluppo su [GitHub](https://github.com/andreabz/).  
Ogni bug è una contraddizione interna del sistema: segnalarlo è un atto rivoluzionario.

Se l'app ti è utile, condividila. Se ti piace, forkala. Se non funziona, riparala.  
L'importante è non restare fermi.

> *“La statistica al servizio del popolo, non del profitto.”*

<!-- Riga vuota finale obbligatoria -->