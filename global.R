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

# ---- Lettura dati base ----
province <- fread(here("data", "anagrafica_province.csv"))
stazioni <- fread(here("data", "anagrafica_stazioni.csv"))
parametri <- c("PM10", "PM2.5", "NO2", "SO2", "CO", "O3")

# ---- Valori dei selettori ----
# Parametri ----
nomi <- sapply(parametri, function(p) etichette_parametro(p)$nome)
opzioni <- setNames(parametri, nomi)

# Date ----
data_min = Sys.Date() - 30
data_max = Sys.Date() - 2
data_def = Sys.Date() - 2

