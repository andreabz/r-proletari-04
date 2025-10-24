# ────────────────────────────────────────────────
# init.R — Inizializzazione del progetto
# ────────────────────────────────────────────────

# 1. Installa e carica 'renv' se mancante
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

# 2. Esegui restore solo se la libreria non esiste
if (!dir.exists("renv/library")) {
  message("📦 Primo avvio: ripristino dell’ambiente con renv...")
  renv::restore(prompt = FALSE)
} else {
  message("🔁 Ambiente renv già presente: skip restore.")
}

# 3. Carica pacchetti richiesti
packages <- c(
  "shiny", "bslib", "httr2", "here", "markdown",
  "commonmark", "data.table", "ggplot2", "DT"
)

# Caricamento silenzioso e automatico
invisible(lapply(packages, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}))

# 4. Carica funzioni personalizzate
source(here("R", "utils.R"))
source(here("R", "data_anagrafiche.R"))
source(here("R", "analisi_numerica.R"))
source(here("R", "analisi_grafica.R"))
source(here("R", "report_helper.R"))

message("✅ Ambiente inizializzato con successo.")
