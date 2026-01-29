library(shiny)
library(bslib)
library(tidyverse)
library(arrow)
library(DT)
library(bsicons)
library(waiter)

# ==============================================================================
# 1. PREPARAÇÃO
# ==============================================================================
arquivos_encontrados <- list.files("dados_dashboard", pattern = "base_dashboard_.*\\.parquet", full.names = TRUE)

if (length(arquivos_encontrados) == 0) {
  anos_disponiveis <- c(2024) 
} else {
  anos_disponiveis <- str_extract(basename(arquivos_encontrados), "\\d{4}") %>% sort(decreasing = TRUE)
}

# ==============================================================================
# 2. UI (Interface)
# ==============================================================================
ui <- page_sidebar(
  theme = bs_theme(version = 5, bootswatch = "flatly", primary = "#2c3e50"),
  
  fillable = FALSE,
  
  # CABEÇALHO
  title = div(
    style = "display: flex; align-items: center;", 
    img(src = "favicon_light.png", height = "45px", style = "margin-right: 15px;"), 
    div(
      div("Ars Metrica", style = "font-weight: 800; font-size: 1.1em; line-height: 1; color: #2c3e50;"),
      div("Monitor Legislativo de Votações Nominais", style = "font-weight: 400; font-size: 0.8em; color: #7f8c8d;")
    )
  ),
  
  tags$head(
    tags$link(rel = "shortcut icon", href = "favicon_light.png"),
    tags$style(HTML("
      /* CSS GERAL */
      .navbar, .navbar-static-top, header.navbar { background-color: #FFFFFF !important; border-bottom: 1px solid #e0e0e0 !important; }
      .navbar-brand, .navbar-text { color: #2c3e50 !important; }
      
      /* KPI DISCRETO */
      .kpi-discreto {
        background-color: #FFFFFF !important;
        border: 1px solid #ecf0f1 !important;
        border-left: 4px solid #2c3e50 !important;
        box-shadow: none !important;
        border-radius: 4px !important;
        color: #2c3e50 !important;
        padding: 5px 10px !important; 
        min-height: 0 !important;
      }
      .kpi-discreto .value-box-value { font-size: 1.5rem !important; font-weight: 700; margin-bottom: 0 !important; line-height: 1.2; }
      .kpi-discreto .value-box-title { font-size: 0.75rem !important; text-transform: uppercase; letter-spacing: 1px; color: #7f8c8d !important; margin-bottom: 0 !important; }
      .kpi-discreto .value-box-showcase i { font-size: 1.8rem !important; opacity: 0.15; }
      
      /* Botões */
      .btn-download-custom { font-size: 0.8rem; padding: 2px 10px; background-color: #ecf0f1; color: #2c3e50; border: 1px solid #bdc3c7; }
      .btn-download-custom:hover { background-color: #bdc3c7; color: #fff; }
      
      /* Animação */
      @keyframes pulse { 0% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.05); opacity: 0.8; } 100% { transform: scale(1); opacity: 1; } }
    "))
  ),
  
  use_waiter(), 
  
  waiter_show_on_load(
    html = tagList(
      img(src = "favicon_light.png", height = "180px", style = "margin-bottom: 20px; animation: pulse 2s infinite; filter: drop-shadow(0px 5px 5px rgba(0,0,0,0.1));"),
      h4("Ars Metrica", style = "color: #2c3e50; font-family: sans-serif; font-weight: 600; letter-spacing: 2px;"),
      div("Carregando Monitor Legislativo de Votações Nominais...", style = "color: #7f8c8d; font-size: 0.9em; margin-top: 10px;")
    ),
    color = "#FFFFFF"
  ),
  
  sidebar = sidebar(
    title = "Filtros",
    selectInput("input_ano", "Ano:", choices = anos_disponiveis, selected = anos_disponiveis[1]),
    selectizeInput("input_partido", "Partido:", choices = NULL, multiple = TRUE, options = list(placeholder = "Todos")),
    selectizeInput("input_uf", "Estado (UF):", choices = NULL, multiple = TRUE, options = list(placeholder = "Todos")),
    hr(),
    div(style = "font-size: 0.8rem; color: #555; background-color: #f8f9fa; padding: 10px; border-radius: 4px; border-left: 4px solid #2c3e50;",
        bs_icon("info-circle"), strong(" Notas Metodológicas:"), br(), br(),
        strong("1. Total > 513:"), " O número reflete parlamentares ativos no ano. O excedente deve-se à posse de suplentes (rotatividade).", br(), br(),
        strong("2. Governismo:"), " Calculado sobre orientações oficiais da Liderança do Governo."
    ),
    div(class = "mt-auto", style = "padding-top: 20px; text-align: center;",
        hr(style = "margin: 10px 0; border-top: 1px solid #e0e0e0;"),
        div(style = "color: #7f8c8d; font-size: 0.8em; line-height: 1.4;",
            span("Powered by", style = "font-weight: 300;"), br(),
            span(bs_icon("cpu"), " AUTOMATA", style = "font-family: monospace; font-weight: bold; color: #2c3e50; letter-spacing: 1px;"), br(),
            span("Ars Metrica Intelligence", style = "font-size: 0.85em; opacity: 0.8;")
        )
    )
  ),
  
  # --- CONTEÚDO PRINCIPAL ---
  div(
    class = "main-content-wrapper",
    style = "padding-bottom: 50px;",
    
    # 1. KPIs
    layout_columns(
      fill = FALSE,
      value_box(title = "Total de Votações", value = textOutput("kpi_votos"), showcase = bs_icon("bank2"), class = "kpi-discreto"),
      tooltip(
        value_box(title = "Deputados Ativos", value = textOutput("kpi_deps"), showcase = bs_icon("people"), class = "kpi-discreto"),
        "Parlamentares únicos que registraram ao menos um voto no período (inclui titulares e suplentes)."
      ),
      value_box(title = "Apoio Gov. (Taxa)", value = textOutput("kpi_governismo"), showcase = bs_icon("graph-up-arrow"), class = "kpi-discreto")
    ),
    
    br(),
    
    # 2. GRÁFICO TEMAS
    card(
      fill = FALSE,
      card_header(
        "O Que o Congresso Votou?", 
        downloadButton("download_temas", "Baixar Gráfico", class = "btn-download-custom")
      ),
      plotOutput("plot_temas", height = "350px") 
    ),
    
    br(),
    
    # 3. TABELA COM DOWNLOAD
    card(
      fill = FALSE,
      style = "min-height: 500px;", 
      card_header(
        "Raio-X das Votações (Detalhado)",
        # --- AQUI ESTÁ O NOVO BOTÃO DE DOWNLOAD ---
        downloadButton("download_tabela", "Baixar Dados (CSV)", class = "btn-download-custom")
      ),
      DTOutput("tabela")
    )
  )
)

# ==============================================================================
# 3. SERVER
# ==============================================================================
server <- function(input, output, session) {
  
  # --- CARREGAMENTO ---
  dados_brutos <- reactive({
    on.exit({ waiter_hide() })
    req(input$input_ano)
    Sys.sleep(1.5) 
    caminho <- file.path("dados_dashboard", paste0("base_dashboard_", input$input_ano, ".parquet"))
    if (file.exists(caminho)) read_parquet(caminho) else NULL
  })
  
  observeEvent(dados_brutos(), {
    df <- dados_brutos()
    req(df)
    updateSelectizeInput(session, "input_partido", choices = sort(unique(na.omit(df$siglaPartido))), server = TRUE)
    updateSelectizeInput(session, "input_uf", choices = sort(unique(na.omit(df$siglaUf))), server = TRUE)
  })
  
  dados_filtrados <- reactive({
    req(dados_brutos())
    df <- dados_brutos()
    if (!is.null(input$input_partido)) df <- df %>% filter(siglaPartido %in% input$input_partido)
    if (!is.null(input$input_uf)) df <- df %>% filter(siglaUf %in% input$input_uf)
    df
  })
  
  # --- KPIs ---
  output$kpi_governismo <- renderText({
    req(dados_filtrados())
    df <- dados_filtrados()
    if("alinhamento" %in% names(df)) {
      base_calc <- df %>% filter(alinhamento %in% c("Concordou", "Discordou"))
      if(nrow(base_calc) > 0) {
        taxa <- mean(base_calc$alinhamento == "Concordou")
        return(scales::percent(taxa, accuracy = 0.1))
      }
    }
    return("N/A")
  })
  
  output$kpi_votos <- renderText({ format(n_distinct(dados_filtrados()$id_votacao), big.mark = ".") })
  output$kpi_deps <- renderText({ format(n_distinct(dados_filtrados()$id_deputado), big.mark = ".") })
  
  # --- GRÁFICO TEMAS ---
  output$plot_temas <- renderPlot({
    req(dados_filtrados())
    df <- dados_filtrados()
    if(nrow(df) == 0) return(NULL)
    
    df_plot <- df %>%
      distinct(id_votacao, .keep_all = TRUE) %>%
      mutate(Tipo = case_when(
        str_detect(descricao, "PEC|Constituição") ~ "PEC (Emenda Const.)",
        str_detect(descricao, "MPV|Medida Provisória") ~ "MPV (Medida Prov.)",
        str_detect(descricao, "PLP|Lei Complementar") ~ "PLP (Lei Compl.)",
        str_detect(descricao, "PL|Projeto de Lei") ~ "PL (Projeto de Lei)",
        str_detect(descricao, "PDL|Decreto Legislativo") ~ "PDL (Decreto Leg.)",
        TRUE ~ "Outros"
      )) %>%
      count(Tipo)
    
    ggplot(df_plot, aes(x = reorder(Tipo, n), y = n)) +
      geom_col(aes(fill = Tipo), width = 0.6, show.legend = FALSE) +
      geom_text(aes(label = n), hjust = -0.2, size = 5, color = "#2c3e50") +
      scale_fill_viridis_d(option = "mako", begin = 0.3, end = 0.8) +
      coord_flip() +
      theme_minimal(base_size = 14) +
      labs(x = NULL, y = NULL) +
      theme(panel.grid.major.y = element_blank())
  })
  
  # --- DOWNLOAD GRÁFICO ---
  output$download_temas <- downloadHandler(
    filename = function() { paste("ars_metrica_legislativo_", input$input_ano, ".png", sep = "") },
    content = function(file) {
      req(dados_filtrados())
      df <- dados_filtrados()
      df_plot <- df %>%
        distinct(id_votacao, .keep_all = TRUE) %>%
        mutate(Tipo = case_when(
          str_detect(descricao, "PEC|Constituição") ~ "PEC",
          str_detect(descricao, "MPV|Medida Provisória") ~ "MPV",
          str_detect(descricao, "PLP|Lei Complementar") ~ "PLP",
          str_detect(descricao, "PL|Projeto de Lei") ~ "PL",
          str_detect(descricao, "PDL|Decreto Legislativo") ~ "PDL",
          TRUE ~ "Outros"
        )) %>% count(Tipo)
      
      p <- ggplot(df_plot, aes(x = reorder(Tipo, n), y = n)) +
        geom_col(aes(fill = Tipo), width = 0.6, show.legend = FALSE) +
        geom_text(aes(label = n), hjust = -0.2, size = 4) +
        scale_fill_viridis_d(option = "mako", begin = 0.3, end = 0.8) +
        coord_flip() +
        theme_minimal() +
        labs(title = paste("Votações por Tema -", input$input_ano), caption = "Fonte: Ars Metrica | Powered by Automata", x = NULL, y = NULL) +
        theme(plot.title = element_text(face="bold", color="#2c3e50"), plot.caption = element_text(family = "mono", color = "#7f8c8d"))
      ggsave(file, plot = p, device = "png", width = 8, height = 5)
    }
  )
  
  # --- TABELA INTERATIVA ---
  output$tabela <- renderDT({
    req(dados_filtrados())
    df <- dados_filtrados()
    
    cols_show <- c("data", "nome", "siglaPartido", "siglaUf", "voto", "descricao")
    if("alinhamento" %in% names(df)) cols_show <- c(cols_show, "alinhamento")
    
    dtable <- df %>%
      select(all_of(cols_show)) %>%
      rename(Data=data, Deputado=nome, Partido=siglaPartido, UF=siglaUf, Voto=voto, Descrição=descricao)
    
    if("alinhamento" %in% names(df)) dtable <- dtable %>% rename(`Apoio Gov` = alinhamento)
    
    datatable(dtable, options = list(scrollX = TRUE, pageLength = 10)) %>%
      formatStyle(
        if("Apoio Gov" %in% names(dtable)) "Apoio Gov" else "Voto",
        target = "row",
        backgroundColor = styleEqual(c("Concordou", "Discordou"), c("#d4edda", "#f8d7da"))
      )
  })
  
  # --- DOWNLOAD TABELA (NOVA FUNÇÃO) ---
  output$download_tabela <- downloadHandler(
    filename = function() { 
      paste("monitor_legislativo_dados_", input$input_ano, ".csv", sep = "") 
    },
    content = function(file) {
      req(dados_filtrados())
      df <- dados_filtrados()
      
      # Seleciona e renomeia para ficar bonito no Excel
      cols_show <- c("data", "nome", "siglaPartido", "siglaUf", "voto", "descricao")
      if("alinhamento" %in% names(df)) cols_show <- c(cols_show, "alinhamento")
      
      export_df <- df %>%
        select(all_of(cols_show)) %>%
        rename(Data=data, Deputado=nome, Partido=siglaPartido, UF=siglaUf, Voto=voto, Descricao=descricao)
      
      if("alinhamento" %in% names(df)) export_df <- export_df %>% rename(`Apoio Gov` = alinhamento)
      
      # Salva como CSV (UTF-8)
      write.csv(export_df, file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)