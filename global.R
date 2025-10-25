# ────────────────────────────────────────────────
# global.R — Inizializzazione del progetto
# ────────────────────────────────────────────────

library(shiny)
library(bslib)
library(httr2)
library(here)
library(markdown)
library(commonmark)
library(data.table)
library(ggplot2)
library(DT)


# 4. Carica funzioni personalizzate
source(here("R", "utils.R"))
source(here("R", "data_anagrafiche.R"))
source(here("R", "analisi_numerica.R"))
source(here("R", "analisi_grafica.R"))
source(here("R", "report_helper.R"))
