source("init.R")

ui <- page_navbar(
  id = "main_navbar",
  title = div(
    img(src = "rproletari.png", height = "80px", class = "navbar-logo"),
    span(class = "navbar-title-text",
         tags$div("R per proletari"),
         tags$div("Episodio 4 - Bollettini a richiesta", class = "subtitle")
    )
  ),
  window_title = "R per proletari",
  
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#BA1212",
    secondary = "#fada5e",
    base_font = font_google("Inter"),
    heading_font = font_google("Anton")
  ),
  
  # ✅ head_content va qui, PRIMA dei nav_panel
  header = tags$head(
    tags$link(rel = "stylesheet", href = "mappa.css"),
    tags$link(rel = "stylesheet", href = "soviet-style.css"),
    tags$link(rel = "stylesheet", href = "layout-proletario.css"),
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"),
    tags$script(src = "social-icons.js")
  ),
  
  # ✅ i pannelli ora sono argomenti non nominati
  nav_panel(
    "Bollettini del popolo",
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        position = "left",
        open = TRUE,
        withTags({
          label(class = "control-label", b("Seleziona la provincia:"))
        }),
        includeHTML(here("www", "mappa.html")),
        tags$script(src = "mappa.js"),
        br(),
        uiOutput("data_selector"),
        br(),
        uiOutput("parametro_selector"),
        br(),
        actionButton("genera", "Genera bollettino", class = "btn btn-danger w-100")
      ),
      
      uiOutput("instructions"),
      htmlOutput("report_title"),
      uiOutput("report_comment"),
      br(),
      DTOutput("report_table"),
      br(),
      plotOutput("report_plot")
    )
  ),
  
  nav_panel(
    "Come funziona",
    includeMarkdown(here("www", "come-funziona.md"))
  )
)
