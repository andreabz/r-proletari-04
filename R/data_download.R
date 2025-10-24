# R/download_dati.R
# Scarica dati ARPAE Emilia-Romagna via SQL API, prepara per elaborazione e log
library(data.table)
library(httr2)

#' Sanitize SQL input
#'
#' Rimuove tutti i caratteri non ammessi da una stringa per prevenire
#' rischi di SQL injection. Mantiene solo lettere, numeri, underscore,
#' spazio e slash.
#'
#' @param x Character vector da sanitizzare.
#'
#' @return Character vector ripulito.
#' @examples
#' sanitize_sql("DROP TABLE utenti; --")
#' # [1] "DROP TABLE utenti "
sanitize_sql <- function(x) {
  gsub("[^a-zA-Z0-9_ /]", "", x)
}

#' Scarica dati ARPAE con query SQL
#'
#' Interroga l'API CKAN di ARPAE con una query SQL parametrizzata,
#' filtrando per `station_id` e per data specifica (`reftime`).
#' La data viene passata dall'utente in formato `dd/mm/YYYY` e
#' convertita automaticamente nel formato `MM/DD/YYYY` richiesto
#' dal dataset.
#'
#' @param dataset_id Stringa, identificativo del dataset su ARPAE.
#' @param stazioni_selezionate Vettore di character, codici stazione da includere.
#' @param parametri_selezionati Vettore di numeri, codici parametro da includere.
#' @param data_selezionata Stringa, data in formato `dd/mm/YYYY`.
#' @param limit Intero, numero massimo di record da scaricare (default: 1000).
#' @param offset Intero, offset per la paginazione (default: 0).
#'
#' @return Un `data.table` con i dati filtrati e puliti. Se non ci sono
#' record disponibili, restituisce un `data.table` vuoto.
#'
#' @examples
#' \dontrun{
#' dati <- scarica_dati_sql(
#'   dataset_id = "4dc855a1-6298-4b71-a1ae-d80693d43dcb",
#'   stazioni_selezionate = c("3000001", "3000022"),
#'   parametri_selezionati = 5,
#'   data_selezionata = "21/08/2025"
#' )
#' }
scarica_dati_sql <- function(dataset_id,
                             stazioni_selezionate,
                             parametri_selezionati,
                             data_selezionata,
                             limit = 1000,
                             offset = 0) {
  
  # ripulisco i valori di input e li trasformo in formati utili per SQL
  stations_sql <- paste0("('", paste(stazioni_selezionate |> sanitize_sql(), collapse = "','"), "')")
  data_sql <- format(as.Date(data_selezionata |> sanitize_sql(), "%d/%m/%Y"), "%m/%d/%Y")
  parameters_sql <- paste0("('", paste(parametri_selezionati |> sanitize_sql(), collapse = "','"), "')")
  
  # costruisco la query parametrizzata
  sql <- sprintf("
  SELECT *
  FROM \"%s\"
  WHERE station_id IN %s
    AND variable_id IN %s
    AND reftime LIKE '%s%%'
  LIMIT %d OFFSET %d
", dataset_id, stations_sql, parameters_sql, data_sql, limit, offset)
  
  url <- "https://dati.arpae.it/api/3/action/datastore_search_sql"
  
  # costruisco la richiesta all'API
  req <- request(url) |>
    req_method("POST") |>
    req_body_json(list(sql = sql))
  
  # salvo il risultato
  resp <- req_perform(req)
  content_json <- resp_body_json(resp, simplifyVector = TRUE)
  
  # se ottengo qualcosa, gli do una pulita e lo converto in data.table
  if (!is.null(nrow(content_json$result$records))) {
    dt <- as.data.table(content_json$result$records)
    dt <- pulisci_dati(dt)
    dt
  } else {
    data.table()
  }
}

#' Carica e unisce i dati del bollettino per una provincia, una data e un parametro
#'
#' Questa funzione è il cuore operativo dell'applicazione.  
#' Data una sigla di provincia, una data e un parametro atmosferico, recupera:
#' - le anagrafiche delle stazioni,
#' - le informazioni sulla provincia,
#' - gli identificativi dei parametri richiesti,
#' - e infine i dati grezzi dal database ARPAE (via SQL API),
#' restituendo un data frame completo e pronto per l'analisi.
#'
#' Se il parametro richiesto è `"PM2.5"`, la funzione aggiunge automaticamente
#' anche `"PM10"` per calcolare il rapporto \eqn{PM2.5 / PM10}.
#'
#' @param prov_sigla Character. Sigla della provincia (es. `"BO"`, `"MO"`, `"FE"`).
#' @param data Date o character. Data per la quale estrarre i dati.
#' @param par Character. Parametro da analizzare (es. `"NO2"`, `"PM10"`, `"PM2.5"`, `"O3"`).
#'
#' @details
#' La funzione coordina più step:
#' 1. Richiama le funzioni di supporto \code{carica_anagrafiche()},
#'    \code{carica_provincia()} e \code{carica_idparametro()} per ottenere
#'    le informazioni di contesto.
#' 2. Se necessario, integra \code{PM10} per confronti o rapporti.
#' 3. Scarica i dati dal dataset SQL indicato tramite \code{scarica_dati_sql()}.
#' 4. Unisce i dati osservati con le anagrafiche delle stazioni in base
#'    agli identificativi di stazione e parametro.
#'
#' Se non sono presenti dati per la combinazione richiesta, restituisce \code{NULL}.
#'
#' @return
#' Un data frame contenente i dati del parametro richiesto uniti alle anagrafiche
#' delle stazioni, oppure \code{NULL} se nessun dato è disponibile.
#'
#' @examples
#' \dontrun{
#' # Carica i dati del PM10 per Bologna il 1° ottobre 2025
#' dati_bo <- load_data(prov_sigla = "BO", data = "2025-10-01", par = "PM10")
#'
#' # Calcola automaticamente anche il rapporto PM2.5 / PM10
#' dati_bo_ratio <- load_data(prov_sigla = "BO", data = "2025-10-01", par = "PM2.5")
#' }
#'
#' @seealso
#' \code{\link{carica_anagrafiche}}, \code{\link{carica_idparametro}}, \code{\link{scarica_dati_sql}}
#'
#' @export
load_data <- function(prov_sigla, data, par){
  anagrafiche <- carica_anagrafiche(prov_sigla = prov_sigla)
  provincia <- carica_provincia(sigla = prov_sigla)
  parametro <- carica_idparametro(parametro = par)
  
  if (par == "PM2.5"){
  # aggiungo anche PM10 per calcolare il rapporto PM2.5 e PM10
    id_pm10 <- carica_idparametro(parametro = "PM10")
    parametro <- c(parametro, id_pm10)
    print(parametro)
  }
  
  # 2. Scarico i dati per quelle stazioni
  dati_api <- scarica_dati_sql(
    dataset_id = "4dc855a1-6298-4b71-a1ae-d80693d43dcb",
    stazioni_selezionate = anagrafiche$stazioni_selezionate,
    parametri_selezionati = parametro,
    data_selezionata = data
  )
  
  if(nrow(dati_api) != 0) {
    # 3. Merge con anagrafiche
    dati <- merge(
      dati_api,
      anagrafiche$anagrafica_stazioni,
      by.x = c("station_id", "variable_id"),
      by.y = c("cod_staz", "id_param")
    )
    
    dati
  } else {
    NULL
  }
}