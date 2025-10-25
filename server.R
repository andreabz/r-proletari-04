server <- function(input, output, session) {
  # ---- Lettura dati base ----
  province <- fread(here("data", "anagrafica_province.csv"))
  stazioni <- fread(here("data", "anagrafica_stazioni.csv"))
  parametri <- c("PM10", "PM2.5", "NO2", "SO2", "CO", "O3")
  
  # ---- Gestione date ----
  output$data_selector <- renderUI({
    dateInput(
      "data",
      "Seleziona la data:",
      min = Sys.Date() - 30,
      max = Sys.Date() - 2,
      value = Sys.Date() - 2,
      language = "it"
    )
  })
  
  # ---- Selezione provincia dalla mappa ----
  provincia <- reactiveValues(sigla = NULL, nome = NULL)
  observeEvent(input$provincia_click, {
    provincia$sigla <- input$provincia_click
    provincia$nome <- carica_provincia(input$provincia_click)
  })
  
  # ---- Selezione del parametro ----
  output$parametro_selector <- renderUI({
    nomi <- sapply(parametri, function(p)
      etichette_parametro(p)$nome)
    selectInput("parameter_sel",
                "Seleziona il parametro:",
                choices = setNames(parametri, nomi))
  })
  
  # ---- Helper ----
  vals <- reactiveVal(FALSE)
  
  observeEvent(input$genera, {
    vals(TRUE)
  })
  
  output$instructions <- renderUI({
    if (!vals()) {
      tagList(
        div(class = "shiny-markdown-container",
            tags$p(HTML("Benvenuto Compagno!<br>
                  Seleziona la provincia, la data e il parametro di interesse
                  per generare il bollettino.<br><br>
                  Ricordati che se cerchi dati ufficiali, devi rivolgerti
                  ai bollettini di <a href='https://www.arpae.it/it/temi-ambientali/aria/dati-qualita-aria'>ARPA Emilia-Romagna</a>")
            )
        )
      )
    } else {
      NULL  # sparisce il testo dopo clic
    }
  })
  
  # ---- Dataset e risultati: solo su click ----
  dati_generati <- eventReactive(input$genera, {
    req(provincia$sigla, input$data, input$parameter_sel)
    
    data_formattata <- format(input$data, "%d/%m/%Y")
    dati <- load_data(
      prov_sigla = provincia$sigla,
      data = data_formattata,
      par = input$parameter_sel
    )
    
    parametro <- etichette_parametro(input$parameter_sel)
    
    if (!is.null(dati)) {
      tabella <- report_parametro(dati, input$parameter_sel)
    } else {
      tabella <- NULL
    }
    
    list(
      parametro_sel = input$parameter_sel,
      parametro_nome = parametro$nome,
      parametro_simbolo = parametro$simbolo,
      provincia = provincia$nome,
      data_formattata = data_formattata,
      dati = dati,
      dati_righe = dim(dati)[1],
      tabella = tabella
    )
  })
  
  # ---- Titolo ----
  output$report_title <- renderText({
    req(dati_generati())
    
    HTML(
      paste0(
        "<h4>Report del ",
        dati_generati()$data_formattata,
        "per la provincia di ",
        dati_generati()$provincia,
        " - ",
        dati_generati()$parametro_nome,
        " (",
        dati_generati()$parametro_simbolo,
        ")</h4>"
      )
    )
  })
  
  # ---- Commento ----
  output$report_comment <- renderUI({
    req(dati_generati())
    
    commento_superamenti(parametro = dati_generati()$parametro_sel,
                         res = dati_generati()$tabella) |> commonmark::markdown_html() |> HTML()
  })
  
  # ---- Tabella ----
  output$report_table <- renderDataTable({
    req(dati_generati())
    req(dati_generati()$tabella)
    
    tabella_parametro(parametro = dati_generati()$parametro_sel,
                      res = dati_generati()$tabella)
  })
  
  # ---- Grafico ----
  output$report_plot <- renderPlot(height = 450, width = 900, {
    req(dati_generati())
    req(dati_generati()$tabella)
    req(dati_generati()$parametro_sel %notin% c("PM10", "PM2.5"))
    
    grafico_parametro(parametro = dati_generati()$parametro_sel,
                      dati = dati_generati()$dati)
    
  })
}
