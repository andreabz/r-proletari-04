# R/report_helper.R
# Funzioni di supporto per generazione report giornaliero qualità dell'aria
#' Questo file contiene funzioni per:
#' - generare sezioni del report per ciascun parametro
#' - commentare automaticamente i superamenti dei valori limite
#'   secondo quanto previsto dal D.Lgs. 155/2010
library(data.table)
library(ggplot2)
library(DT)

#' Etichette delle colonne adattive per HTML e PDF
#'
#' Restituisce le etichette delle colonne con i giusti a capo per HTML.
#'
#' @param parametro Nome del parametro (es. "PM10", "NO2", "O3").
#' @return Vettore nominato con le etichette delle colonne.
#' @export
etichette_colonne <- function(parametro) {
  
  # funzione interna per gestire il formato degli a capo
  myfmt <- function(...) {
    paste(c(...), collapse = "</br>")
  }
  
  switch(parametro,
         "PM10" = c(
           stazione   = "Stazione",
           comune     = "Comune",
           val_pm10   = myfmt("Concentrazione", "(µg/m³)")
         ),
         "PM2.5" = c(
           stazione        = "Stazione",
           comune          = "Comune",
           val_pm25        = myfmt("Concentrazione", "(µg/m³)"),
           ratio_pm25_pm10 = "PM2.5/PM10"
         ),
         "NO2" = c(
           stazione        = "Stazione",
           comune          = "Comune",
           min_val         = myfmt("Min", "(µg/m³)"),
           max_val         = myfmt("Max", "(µg/m³)"),
           n_supera_200    = "≥ 200 µg/m³",
           n_supera_400_3h = myfmt("≥ 400 µg/m³", "per 3h")
         ),
         "SO2" = c(
           stazione  = "Stazione",
           comune    = "Comune",
           min_val   = myfmt("Min", "(µg/m³)"),
           max_val   = myfmt("Max", "(µg/m³)")
         ),
         "CO" = c(
           stazione    = "Stazione",
           comune      = "Comune",
           min_8h      = myfmt("Min 8h MA", "(mg/m³)"),
           max_8h      = myfmt("Max 8h MA", "(mg/m³)"),
           n_supera_10 = "≥ 10 mg/m³"
         ),
         "O3" = c(
           stazione            = "Stazione",
           comune              = "Comune",
           min_oraria          = myfmt("Min", "(µg/m³)"),
           max_oraria          = myfmt("Max", "(µg/m³)"),
           min_8h              = myfmt("Min 8h MA", "(µg/m³)"),
           max_8h              = myfmt("Max 8h MA", "(µg/m³)"),
           n_supera_120        = "≥ 120 µg/m³",
           n_supera_180_orario = "≥ 180 µg/m³",
           n_supera_240_3h     = myfmt("≥ 240 µg/m³", "per 3h")
         ),
         NULL
  )
}

#' Etichette dei parametri in forma testuale e simbolica
#'
#' Restituisce sia il nome esteso del parametro (es. "Ozono") sia
#' la sua rappresentazione simbolica (es. O pedice 3).
#'
#' @param parametro Stringa del parametro (es. "O3").
#' @return Una lista con elementi `nome` (carattere) e `simbolo` (espressione).
#' @export
etichette_parametro <- function(parametro) {
  switch(parametro,
         "PM10"  = list(nome = "Polveri sottili PM10", simbolo = "PM₁₀"),
         "PM2.5" = list(nome = "Polveri sottili PM2.5", simbolo = "PM₂.₅"),
         "NO2"   = list(nome = "Diossido di azoto", simbolo = "NO₂"),
         "SO2"   = list(nome = "Diossido di zolfo", simbolo = "SO₂"),
         "CO"    = list(nome = "Monossido di carbonio", simbolo = "CO"),
         "O3"    = list(nome = "Ozono", simbolo = "O₃"),
         list(nome = parametro, simbolo = parametro)
  )
}

#' Dizionario dei tipi di superamento normativo
#'
#' Restituisce la descrizione normativa di un superamento e l'articolo corretto
#' (maschile/femminile) per garantire concordanza grammaticale.
#'
#' @param tipo Codice interno che identifica il tipo di limite/soglia.
#' @return Una lista con `label` (stringa) e `articolo` ("il" o "la").
#' @export
descrizione_superamento <- function(tipo) {
  switch(tipo,
         "limite_200"        = list(label = "valore limite orario (200 µg/m³)", articolo = "il"),
         "limite_350"        = list(label = "valore limite orario (350 µg/m³)", articolo = "il"),
         "soglia_info"       = list(label = "soglia di informazione (180 µg/m³)", articolo = "la"),
         "soglia_allarme_NO2"= list(label = "soglia di allarme (400 µg/m³, 3h)", articolo = "la"),
         "valore_obiettivo"  = list(label = "valore obiettivo (120 µg/m³, media mobile 8h)", articolo = "il"),
         "limite_CO"         = list(label = "valore limite media mobile 8h (10 mg/m³)", articolo = "il"),
         "soglia_allarme_O3" = list(label = "soglia di allarme (240 µg/m³, 3h)", articolo = "la"),
         NULL
  )
}

#' Genera la tabella di riepilogo per un parametro
#'
#' @param parametro Nome del parametro (es. "NO2")
#' @param res Data.table con i risultati per il parametro
#' @return Una tabella formattata con DT
#' @export
tabella_parametro <- function(parametro, res) {
  data <- res$date[1]
  lab <- etichette_parametro(parametro)
  
  # Colonne da escludere
  exclude <- c("station_id", "date", "reftime")
  if (parametro == "PM10") exclude <- c(exclude, "supera_50")
  if (parametro == "PM2.5") exclude <- c(exclude, "val_pm10")
  
  coltbl <- setdiff(colnames(res), exclude)
  tbl <- copy(res[, ..coltbl])
  
  # Colonne numeriche → arrotonda a 2 cifre significative
  nums <- names(tbl)[vapply(tbl, is.numeric, logical(1))]
  tbl[, (nums) := lapply(.SD, function(x) signif(x, 2)), .SDcols = nums]
  
  # Etichette colonne con <br>
  labels <- etichette_colonne(parametro)
  label_map <- labels[names(labels) %in% coltbl]
  
  for (i in seq_along(names(tbl))) {
    nm <- names(tbl)[i]
    if (nm %in% names(label_map)) {
      setnames(tbl, old = nm, new = label_map[[nm]])
    }
  }
  
  # === RENDER DT ===
  DT::datatable(
    tbl,
    escape = FALSE,  # permette HTML negli header
    rownames = FALSE,
#    width = "100%",  # forza l’allineamento
    selection = "none",
    options = list(
      dom = 't',
      paging = FALSE,
      info = FALSE,
      ordering = TRUE,
      scrollX = TRUE,  # 🔥 disattivalo: causa più problemi che benefici
      autoWidth = FALSE,  # 🔥 evita il calcolo errato delle colonne
      language = list(
        url = '//cdn.datatables.net/plug-ins/1.13.6/i18n/it-IT.json'
      )
    ),
    class = "compact stripe hover soviet-table"
  )
}

#' Genera un commento sui superamenti dei valori limite
#'
#' @param parametro Nome del parametro ("PM10", "PM2.5", "NO2", "SO2", "CO", "O3")
#' @param res Tabella di risultati specifica per il parametro
#'
#' @return Una stringa con il commento in tono sovietico-satirico.
#'
#' @details
#' La funzione controlla i superamenti dei limiti secondo D.Lgs. 155/2010:
#' - PM10: 50 µg/m³ come media giornaliera
#' - PM2.5: nessun limite orario, si commenta il valore medio
#' - NO2: 200 µg/m³ orario, 400 µg/m³ per 3 ore consecutive
#' - SO2: 350 µg/m³ orario
#' - CO: 10 mg/m³ come massima media mobile 8h
#' - O3: 120 µg/m³ (media mobile 8h, target), 180 µg/m³ orario (informazione),
#'       240 µg/m³ per 3 ore consecutive (allarme)
#'
#' Gestisce in automatico singolare e plurale.
commento_superamenti <- function(parametro, res) {
  commenti <- c()
  
  # helper interno per il singolare/plurale
  sp_phrase <- function(n, descr, stazioni) {
    if (n == 0) {
      return(paste0("- Non si registrano superamenti ", descr, 
                    " presso le stazioni di misura considerate."))
    }
    verbo <- ifelse(n == 1, "si registra", "si registrano")
    sost  <- ifelse(n == 1, "superamento", "superamenti")
    dove <-  ifelse(n == 1, "presso la stazione", "presso le stazioni")
    return(paste0("Per il parametro ", parametro, " ", verbo, " ", n, " ", sost, 
                  " del ", descr, " ", dove, " ", 
                  paste(stazioni, collapse = ", "), "."))
  }
  
  if(is.null(res)) {
    "Nessun dato: possibile sabotaggio da parte di elementi borghesi."
  } else {
    
    if (parametro == "PM10") {
      sup <- res[supera_50 == TRUE]
      n <- nrow(sup)
      commenti <- c(commenti, sp_phrase(n, "limite giornaliero di 50 µg/m³", sup$stazione))
      
    } else if (parametro == "PM2.5") {
      commenti <- c(commenti, "Il PM2.5 non prevede limiti orari giornalieri secondo normativa: "
                    ,"si riporta quindi il valore medio per le stazioni considerate.")
      
    } else if (parametro == "NO2") {
      sup200 <- res[n_supera_200 > 0]
      sup400 <- res[n_supera_400_3h > 0]
      commenti <- c(commenti,
                    sp_phrase(sum(res$n_supera_200), "del limite orario di 200 µg/m³", sup200$stazione),
                    sp_phrase(sum(res$n_supera_400_3h), "del limite di 400 µg/m³ per tre ore consecutive", sup400$stazione))
      
    } else if (parametro == "SO2") {
      sup350 <- res[n_supera_350 > 0]
      commenti <- c(commenti,
                    sp_phrase(sum(res$n_supera_350), "del limite orario di 350 µg/m³", sup350$stazione))
      
    } else if (parametro == "CO") {
      sup <- res[n_supera_10 > 0]
      commenti <- c(commenti,
                    sp_phrase(sum(res$n_supera_10),
                              "del valore limite di 10 mg/m³ sulla media mobile (MA) di 8 ore", sup$stazione))
      
    } else if (parametro == "O3") {
      sup120 <- res[n_supera_120 > 0]
      sup180 <- res[n_supera_180_orario > 0]
      sup240 <- res[n_supera_240_3h > 0]
      commenti <- c(commenti,
                    sp_phrase(sum(res$n_supera_120), "del valore obiettivo di 120 µg/m³ (massima media mobile - MA - sulle 8 ore)", sup120$stazione),
                    sp_phrase(sum(res$n_supera_180_orario), "della soglia di informazione di 180 µg/m³ oraria", sup180$stazione),
                    sp_phrase(sum(res$n_supera_240_3h), "della soglia di allarme di 240 µg/m³ per tre ore consecutive", sup240$stazione))
    }
    
    paste(paste(commenti, collapse = "\n"), "\n")
    
  }
}
