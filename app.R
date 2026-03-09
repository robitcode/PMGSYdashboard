library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(sf)
library(tmap)
library(DT)
library(rintrojs)
library(shinycssloaders)

data <- read.csv("PMGSY.csv")
india_shapefile <- st_read("INDIA.shp", quiet = TRUE)
colnames(india_shapefile)[1] <- "STATE_NAME"

data <- data %>%
  mutate(STATE_NAME = case_when(
    STATE_NAME == "Andaman And Nicobar" ~ "ANDAMAN AND NICOBAR ISLANDS",
    STATE_NAME == "Puducherry"          ~ "Pondicherry",
    STATE_NAME == "Odisha"              ~ "Orissa",
    TRUE                                ~ STATE_NAME
  ))

map_choices <- c(
  "Road works Sanctioned"            = "NO_OF_ROAD_WORK_SANCTIONED",
  "Road work Completed Percentage"   = "work_completed_percentage",
  "Road work in Balance Percentage"  = "road_work_balance_percentage",
  "Bridges Sanctioned"               = "NO_OF_BRIDGES_SANCTIONED",
  "Bridges Completed Percentage"     = "bridges_completed_percentage",
  "Bridges Balance Percentage"       = "bridges_balance_percentage",
  "Expenditure Occurred (in Lakhs)"  = "EXPENDITURE_OCCURED_LAKHS"
)

custom_css <- "
/* ---- Design tokens ---- */
:root {
  --navy:   #1B3A5C;
  --amber:  #E8890C;
  --teal:   #0A7C78;
  --red:    #C0392B;
  --sky:    #2980B9;
  --cream:  #F5F0E8;
  --light:  #EEF2F7;
  --muted:  #5D7285;
}

/* ---- Base ---- */
body { background-color: var(--cream) !important; font-family: 'Inter', sans-serif; }

/* ---- Navbar ---- */
.navbar {
  background: linear-gradient(135deg, #0d2137 0%, var(--navy) 60%, #1a4f72 100%) !important;
  border-bottom: 3px solid var(--amber) !important;
  box-shadow: 0 3px 16px rgba(0,0,0,0.25);
  padding: 0.55rem 1rem !important;
}
.navbar-brand { color: #fff !important; font-weight: 700; font-size: 1.15rem; letter-spacing: 0.3px; }
.navbar-brand img { filter: drop-shadow(0 1px 3px rgba(0,0,0,0.4)); }
.nav-link { color: rgba(255,255,255,0.82) !important; font-weight: 500; transition: color 0.2s; }
.nav-link:hover { color: #fff !important; }
.nav-link.active {
  color: var(--amber) !important;
  border-bottom: 2px solid var(--amber) !important;
  font-weight: 700;
}

/* ---- Sidebar ---- */
.sidebar {
  background: #fff !important;
  border-right: 2px solid var(--light);
  box-shadow: 2px 0 12px rgba(0,0,0,0.05);
}
.sidebar .sidebar-title { color: var(--navy); font-weight: 700; font-size: 1rem; }

/* ---- Cards ---- */
.card {
  border-radius: 12px !important;
  border: 1px solid #dce5ef !important;
  box-shadow: 0 2px 10px rgba(0,0,0,0.06);
}
.card-header {
  font-weight: 600 !important;
  background: linear-gradient(90deg, #f0f4f8, #e8edf3) !important;
  border-bottom: 1.5px solid #d0dbe7 !important;
  border-radius: 12px 12px 0 0 !important;
  color: var(--navy);
  font-size: 0.95rem;
}

/* ── Hero card ── */
.hero-card {
  background: linear-gradient(135deg, #0d2137 0%, var(--navy) 45%, #0A7C78 100%) !important;
  border: none !important;
  border-radius: 16px !important;
  position: relative;
  overflow: hidden;
}
.hero-card::after {
  content: '';
  position: absolute;
  top: -80px; right: -80px;
  width: 350px; height: 350px;
  background: rgba(255,255,255,0.04);
  border-radius: 50%;
  pointer-events: none;
}
.hero-card::before {
  content: '';
  position: absolute;
  bottom: -60px; left: -60px;
  width: 260px; height: 260px;
  background: rgba(232,137,12,0.07);
  border-radius: 50%;
  pointer-events: none;
}

/* Stat pills inside hero */
.stat-pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: rgba(255,255,255,0.1);
  border: 1px solid rgba(255,255,255,0.2);
  border-radius: 50px;
  padding: 5px 16px;
  color: #fff;
  font-size: 0.82rem;
  margin: 3px;
  backdrop-filter: blur(4px);
}
.stat-pill .stat-val { font-weight: 800; font-size: 1rem; color: var(--amber); }

/* Feature cards */
.feature-card {
  border-radius: 12px !important;
  border: none !important;
  transition: transform 0.22s ease, box-shadow 0.22s ease;
  overflow: hidden;
}
.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 28px rgba(0,0,0,0.13) !important;
}
.feature-icon-wrap {
  width: 56px; height: 56px;
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  margin: 0 auto 12px;
}
.fi-navy  { background: #e6edf5; }
.fi-teal  { background: #e4f4f3; }
.fi-amber { background: #fef3e0; }

/* Phase strips */
.phase-strip {
  border-left: 5px solid var(--amber);
  background: #fff;
  border-radius: 8px;
  padding: 12px 16px;
  margin-bottom: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.05);
}
.phase-strip.phase-teal  { border-color: var(--teal); }
.phase-strip.phase-navy  { border-color: var(--navy); }

/* Impact list */
.impact-item {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 7px 0;
  border-bottom: 1px dashed #e0e8f0;
}
.impact-item:last-child { border-bottom: none; }
.impact-dot {
  width: 8px; height: 8px; border-radius: 50%;
  background: var(--teal); margin-top: 6px; flex-shrink: 0;
}

/* Data source pill */
.ds-pill {
  background: var(--light);
  border-radius: 8px;
  padding: 12px 16px;
  font-size: 0.82rem;
  color: var(--muted);
}

/* ── EDA Filter Header ── */
.eda-filter-header {
  background: linear-gradient(90deg, #0d2137 0%, var(--navy) 60%, #1a5276 100%);
  color: #fff;
  border-radius: 12px;
  padding: 14px 20px;
  margin-bottom: 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 3px 14px rgba(27,58,92,0.3);
}
.eda-filter-header h5 { margin: 0; font-weight: 700; font-size: 1rem; }
.filter-badge {
  display: inline-flex; align-items: center; gap: 5px;
  background: rgba(255,255,255,0.12);
  border: 1px solid rgba(255,255,255,0.18);
  border-radius: 20px;
  padding: 3px 12px;
  font-size: 0.78rem;
  color: #fff;
  margin: 2px 4px 0 0;
}
.filter-badge.fb-amber {
  background: var(--amber);
  border-color: var(--amber);
  color: #1a1a1a;
  font-weight: 700;
}

/* Location badge in modal */
.loc-badge {
  display: inline-block;
  background: var(--light);
  color: var(--navy);
  border: 1px solid #c4d3e5;
  border-radius: 20px;
  padding: 4px 13px;
  font-size: 0.8rem;
  font-weight: 600;
  margin: 3px;
  letter-spacing: 0.2px;
}

/* Leaderboard card headers */
.ldb-success { background: var(--teal)  !important; color: #fff !important; border-radius: 11px 11px 0 0 !important; }
.ldb-danger  { background: var(--red)   !important; color: #fff !important; border-radius: 11px 11px 0 0 !important; }

/* Value box tweaks */
.value-box { border-radius: 10px !important; box-shadow: 0 2px 8px rgba(0,0,0,0.08) !important; }

/* Plot background */
.plot-container { background: transparent !important; }

/* Scrollbar */
::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-track { background: #f0f0f0; }
::-webkit-scrollbar-thumb { background: #b0bec5; border-radius: 10px; }
::-webkit-scrollbar-thumb:hover { background: var(--navy); }
"

ui <- page_navbar(
  title = tags$span(
    tags$img(
      src    = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Emblem_of_India.svg/800px-Emblem_of_India.svg.png",
      height = "28px", class = "me-2",
      style  = "vertical-align:middle;"
    ),
    "PMGSY Analytics"
  ),
  
  theme = bs_theme(
    version      = 5,
    bg           = "#F5F0E8",
    fg           = "#1a2636",
    primary      = "#1B3A5C",
    secondary    = "#546E7A",
    success      = "#0A7C78",
    info         = "#2980B9",
    warning      = "#E8890C",
    danger       = "#C0392B",
    base_font    = font_google("Inter"),
    heading_font = font_google("Poppins"),
    `enable-shadows` = TRUE
  ),
  
  tags$head(tags$style(HTML(custom_css))),
  introjsUI(),
  
  sidebar = sidebar(
    title = tags$span(icon("sliders", class = "me-1 text-warning"), "Filters"),
    width  = 280,
    bg     = "#ffffff",
    
    introBox(
      tagList(
        tags$div(class = "mb-3",
                 tags$label(icon("layer-group", class = "me-1 text-primary"), "PMGSY Scheme",
                            class = "form-label fw-bold small"),
                 selectInput("scheme", NULL,
                             choices = c("All", unique(data$PMGSY_SCHEME)), width = "100%")
        ),
        tags$div(class = "mb-3",
                 tags$label(icon("map-pin", class = "me-1 text-primary"), "State",
                            class = "form-label fw-bold small"),
                 selectInput("state", NULL,
                             choices = c("All States", unique(data$STATE_NAME)), width = "100%")
        ),
        tags$div(
          class = "p-2 rounded small",
          style = "background:#EEF2F7; color:#5D7285;",
          icon("circle-info", class = "me-1 text-info"),
          tags$em("Filters apply instantly across all panels.")
        )
      ),
      data.step  = 1,
      data.intro = "Start here! Pick a scheme or state — the entire dashboard updates automatically."
    )
  ),
  
  
  
  
  
  
  nav_panel("Home", value = "home_tab", icon = icon("gauge-high"),
            
            card(
              class = "hero-card text-white shadow mb-3 mt-1",
              style = "padding: 1.8rem 2.2rem; min-height: 200px;",
              div(class = "row align-items-center",
                  div(class = "col-md-8",
                      tags$p(class = "mb-1 fw-semibold",
                             style = "font-size:0.75rem; text-transform:uppercase; letter-spacing:1.5px; color:rgba(255,255,255,0.75);",
                             "Ministry of Rural Development · Government of India"),
                      tags$h2("Pradhan Mantri Gram Sadak Yojana",
                              class = "fw-bold mb-2", style = "font-size: 1.8rem; line-height:1.2;"),
                      tags$p("India's flagship rural road connectivity programme — ",
                             tags$strong("tracked, analyzed, and visualized."),
                             class = "mb-3", style = "font-size: 1rem; opacity: 0.9;"),
                      
                      div(class = "mb-3 d-flex flex-wrap",
                          tags$span(class = "stat-pill", icon("map"), " States Covered", tags$span(class = "stat-val", " 36")),
                          tags$span(class = "stat-pill", icon("indian-rupee-sign"), " Budget Outlay", tags$span(class = "stat-val", " ₹1.9L Cr+")),
                          actionButton("btn_tour", tagList(icon("compass"), " Take a Tour"),
                                       class = "btn btn-warning fw-bold rounded-pill shadow-sm px-4 me-2 mb-2"),
                          actionButton("btn_goto_eda", tagList("Explore Data ", icon("arrow-right")),
                                       class = "btn btn-outline-light rounded-pill px-4 mb-2",
                                       onclick = "$('a[data-value=\"eda_tab\"]').click();")
                      ),
                      
                  ),
                  div(class = "col-md-4 text-center d-none d-md-block",
                      icon("earth-asia", class = "fa-6x", style = "opacity:0.15;")
                  )
              )
            ),
            
            layout_columns(
              col_widths = c(6, 6), # Balanced to 6/6 to give the lists more horizontal breathing room
              
              card(
                class = "shadow-sm h-100 border-0",
                card_header(tagList(icon("book-open", class = "me-2 text-warning"), "About PMGSY"), class = "bg-transparent"),
                card_body(
                  class = "d-flex flex-column", # Flex column allows us to push the footer to the bottom
                  tags$p(class = "small text-muted mb-2",
                         "Launched in ", tags$strong("December 2000", class = "text-dark"),
                         " under the Ministry of Rural Development, PMGSY aims to provide all-weather road connectivity",
                         " to unconnected habitations. It is one of India's largest public infrastructure programmes."
                  ),
                  tags$p(class = "fw-semibold mb-2 mt-2", style = "color: var(--navy); font-size: 0.9rem;",
                         icon("timeline", class = "me-1 text-amber"), "Programme Phases"),
                  
                  div(class = "phase-strip py-2 mb-2",
                      tags$strong("PMGSY-I", class = "small"), tags$span(" · 2000 – 2019", class = "text-muted", style="font-size:0.75rem;"),
                      tags$br(), tags$span("Connect habitations ≥500 population with all-weather roads.", style="font-size:0.8rem;")
                  ),
                  div(class = "phase-strip phase-teal py-2 mb-2",
                      tags$strong("PMGSY-II", class = "small"), tags$span(" · 2013 – 2019", class = "text-muted", style="font-size:0.75rem;"),
                      tags$br(), tags$span("Upgrade and consolidate existing networks to improve durability.", style="font-size:0.8rem;")
                  ),
                  div(class = "phase-strip phase-navy py-2 mb-3",
                      tags$strong("PMGSY-III", class = "small"), tags$span(" · 2019 – Present", class = "text-muted", style="font-size:0.75rem;"),
                      tags$br(), tags$span("Connect routes to Gramin Agricultural Markets, Schools, & Hospitals.", style="font-size:0.8rem;")
                  ),
                  
                  div(class = "ds-pill mt-auto p-2",
                      icon("database", class = "me-1 text-primary"),
                      tags$strong("Data Source: ", style="font-size:0.8rem;"),
                      tags$span("OMMAS, Ministry of Rural Development.", style="font-size:0.75rem;")
                  )
                )
              ),
              
              card(
                class = "shadow-sm h-100 border-0",
                card_header(tagList(icon("bullseye", class = "me-2 text-danger"), "Objectives & Impact"), class = "bg-transparent"),
                card_body(
                  class = "d-flex flex-column",
                  
                  div(class = "mb-auto",
                      div(class = "impact-item py-1",
                          div(class = "impact-dot"),
                          div(tags$strong("All-weather connectivity", class = "small"), tags$br(),
                              tags$span(class="text-muted", style="font-size:0.8rem;", "Ensuring rural communities are not cut off during monsoons."))
                      ),
                      div(class = "impact-item py-1",
                          div(class = "impact-dot", style="background:var(--amber);"),
                          div(tags$strong("Market & economic access", class = "small"), tags$br(),
                              tags$span(class="text-muted", style="font-size:0.8rem;", "Connecting farmers to Agricultural Produce Markets and mandis."))
                      ),
                      div(class = "impact-item py-1",
                          div(class = "impact-dot", style="background:var(--sky);"),
                          div(tags$strong("Education & healthcare", class = "small"), tags$br(),
                              tags$span(class="text-muted", style="font-size:0.8rem;", "Linking villages to schools, PHCs, and district hospitals."))
                      ),
                      div(class = "impact-item py-1",
                          div(class = "impact-dot", style="background:var(--red);"),
                          div(tags$strong("Employment generation", class = "small"), tags$br(),
                              tags$span(class="text-muted", style="font-size:0.8rem;", "Millions of person-days of rural labour generated."))
                      ),
                      div(class = "impact-item py-1 border-0",
                          div(class = "impact-dot", style="background:var(--navy);"),
                          div(tags$strong("Poverty reduction", class = "small"), tags$br(),
                              tags$span(class="text-muted", style="font-size:0.8rem;", "Road connectivity correlates with household income growth."))
                      )
                  ),
                  
                  div(class = "text-center p-2 rounded mt-3", style = "background: var(--light);",
                      icon("chart-line", class = "text-success me-2"),
                      tags$strong("Use the sidebar", class = "text-primary small"),
                      tags$span(" to filter by scheme or state.", class = "text-muted small")
                  )
                )
              )
            ) # end layout_columns
  ), # end Home
  
  
  
  nav_panel("EDA & Insights", value = "eda_tab", icon = icon("magnifying-glass-chart"),
            
            uiOutput("eda_filter_header_ui"),
            
            introBox(
              layout_columns(
                col_widths = c(3, 3, 3, 3),
                value_box(title = "Roads Sanctioned (km)",  value = textOutput("kpi_road_sanc"),
                          theme = "secondary",  showcase = icon("route")),
                value_box(title = "Roads Completed (km)",   value = textOutput("kpi_roads"),
                          theme = "success",    showcase = icon("check-double")),
                value_box(title = "Road Balance (km)",      value = textOutput("kpi_road_bal"),
                          theme = "warning",    showcase = icon("triangle-exclamation")),
                value_box(title = "Road Completion Rate",   value = textOutput("kpi_road_perc"),
                          theme = "info",       showcase = icon("percent"))
              ),
              layout_columns(
                col_widths = c(3, 3, 3, 3),
                value_box(title = "Bridges Sanctioned",     value = textOutput("kpi_bridge_sanc"),
                          theme = "secondary",  showcase = icon("archway")),
                value_box(title = "Bridges Completed",      value = textOutput("kpi_bridges"),
                          theme = "success",    showcase = icon("bridge")),
                value_box(title = "Bridges Balance",        value = textOutput("kpi_bridge_bal"),
                          theme = "warning",    showcase = icon("clock-rotate-left")),
                value_box(title = "Total Expenditure",      value = textOutput("kpi_exp"),
                          theme = "primary",    showcase = icon("indian-rupee-sign"))
              ),
              data.step  = 2,
              data.intro = "These 8 KPIs tell the complete story — sanctioned vs completed vs remaining, for both roads and bridges. They update instantly with your filters."
            ),
            
            introBox(
              navset_card_pill(
                title = tags$strong("Leaderboards — Top & Bottom 5"),
                nav_panel("Expenditure",
                          layout_columns(
                            card(card_header("Highest Expenditure",  class = "ldb-success"), tableOutput("top_exp"),    border = FALSE),
                            card(card_header("Lowest Expenditure",   class = "ldb-danger"),  tableOutput("bot_exp"),    border = FALSE)
                          )
                ),
                nav_panel("Roads Completed",
                          layout_columns(
                            card(card_header("Most Roads Completed", class = "ldb-success"), tableOutput("top_road"),   border = FALSE),
                            card(card_header("Least Roads Completed",class = "ldb-danger"),  tableOutput("bot_road"),   border = FALSE)
                          )
                ),
                nav_panel("Bridges Completed",
                          layout_columns(
                            card(card_header("Most Bridges Completed",  class = "ldb-success"), tableOutput("top_bridge"), border = FALSE),
                            card(card_header("Least Bridges Completed", class = "ldb-danger"),  tableOutput("bot_bridge"), border = FALSE)
                          )
                )
              ),
              data.step  = 3,
              data.intro = "Best and worst performers at a glance. Adapts to show States (All States) or Districts (specific state) based on your filter."
            ),
            
            introBox(
              card(
                card_header(tagList(icon("table", class = "me-1"), "Aggregated Data View")),
                card_body(DTOutput("data_table"))
              ),
              data.step  = 4,
              data.intro = "The aggregated data table. All States → grouped by State. A specific state → drilled to District level."
            )
  ),
  
  
  
  nav_panel("Visualizations", value = "viz_tab", icon = icon("chart-mixed"),
            layout_columns(
              col_widths = c(3, 9),
              introBox(
                card(
                  card_header(tagList(icon("sliders", class = "me-1"), "Plot Controls")),
                  card_body(
                    selectizeInput("plot_var", "Select Metric:",
                                   choices = as.list(names(map_choices)),
                                   options = list(dropdownParent = "body"))
                  )
                ),
                data.step  = 4,
                data.intro = "Pick the metric to visualize. The chart updates immediately."
              ),
              card(
                card_header(tagList(icon("chart-bar", class = "me-1"), "Interactive Chart — Ranked by Location")),
                card_body(plotOutput("main_plot", height = "500px"))
              )
            )
  ),
  
  
  
  nav_panel("Geospatial Map", value = "geo_tab", icon = icon("earth-asia"),
            layout_columns(
              col_widths = c(3, 9),
              introBox(
                card(
                  card_header(tagList(icon("layer-group", class = "me-1"), "Map Controls")),
                  card_body(
                    selectizeInput("map_var", "Select Map Variable:",
                                   choices = as.list(map_choices),
                                   options = list(dropdownParent = "body")),
                    tags$p(class = "small text-muted mt-2",
                           icon("circle-info", class = "me-1 text-info"),
                           "District data is aggregated to state level for map boundaries.")
                  )
                ),
                data.step  = 5,
                data.intro = "Choose which PMGSY metric to shade the map by. Click on any state for a detailed popup."
              ),
              card(
                card_header(tagList(icon("map", class = "me-1"), "India State-Level Choropleth")),
                card_body(
                  withSpinner(
                    tmapOutput("india_map", height = "600px"),
                    type  = 6,
                    color = "#1B3A5C",
                    size  = 1.5
                  )
                )
              )
            )
  )
)



server <- function(input, output, session) {
  
  observeEvent(input$btn_tour, {
    introjs(session,
            options = list(showBullets = FALSE, showProgress = TRUE, showStepNumbers = TRUE),
            events  = list(
              onbeforechange = I("
          var step = $(targetElement).attr('data-step');
          if (step === '2' || step === '3') {
            $('a[data-value=\"eda_tab\"]').click();
          } else if (step === '3') {
            $('a[data-value=\"viz_tab\"]').click();
          } else if (step === '5') {
            $('a[data-value=\"geo_tab\"]').click();
          }
        ")
            )
    )
  })
  
  base_data <- reactive({
    df <- data
    if (input$scheme != "All") df <- df %>% filter(PMGSY_SCHEME == input$scheme)
    df
  })
  
  agg_data <- reactive({
    df <- base_data()
    if (input$state == "All States") {
      df_agg <- df %>%
        group_by(STATE_NAME) %>%
        summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") %>%
        rename(Location = STATE_NAME)
    } else {
      df_agg <- df %>%
        filter(STATE_NAME == input$state) %>%
        group_by(DISTRICT_NAME) %>%
        summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") %>%
        rename(Location = DISTRICT_NAME)
    }
    
    df_agg %>%
      mutate(
        work_completed_percentage     = if_else(LENGTH_OF_ROAD_WORK_SANCTIONED_KM > 0,
                                                (LENGTH_OF_ROAD_WORK_COMPLETED_KM / LENGTH_OF_ROAD_WORK_SANCTIONED_KM) * 100, 0),
        bridges_completed_percentage  = if_else(NO_OF_BRIDGES_SANCTIONED > 0,
                                                (NO_OF_BRIDGES_COMPLETED / NO_OF_BRIDGES_SANCTIONED) * 100, 0),
        bridges_balance_percentage    = if_else(NO_OF_BRIDGES_SANCTIONED > 0,
                                                (NO_OF_BRIDGES_BALANCE   / NO_OF_BRIDGES_SANCTIONED) * 100, 0),
        road_work_balance_percentage  = if_else(LENGTH_OF_ROAD_WORK_SANCTIONED_KM > 0,
                                                (LENGTH_OF_ROAD_WORK_BALANCE_KM / LENGTH_OF_ROAD_WORK_SANCTIONED_KM) * 100, 0)
      ) %>%
      mutate(across(ends_with("percentage"), \(x) round(x, 2)))
  })
  
  output$eda_filter_header_ui <- renderUI({
    scheme_label <- if (input$scheme == "All") "All Schemes" else input$scheme
    state_label  <- if (input$state  == "All States") "All States" else input$state
    df           <- base_data()
    
    if (input$state == "All States") {
      n_loc    <- length(unique(df$STATE_NAME))
      loc_type <- "States"
    } else {
      n_loc    <- length(unique(df$DISTRICT_NAME[df$STATE_NAME == input$state]))
      loc_type <- "Districts"
    }
    
    div(class = "eda-filter-header",
        
        div(
          tags$h5(icon("filter", class = "me-2"), "Current View"),
          div(class = "mt-1 d-flex flex-wrap",
              tags$span(class = "filter-badge",
                        icon("layer-group", class = "me-1"), "Scheme: ", tags$strong(scheme_label)
              ),
              tags$span(class = "filter-badge",
                        icon("map-pin", class = "me-1"), "Scope: ", tags$strong(state_label)
              ),
              tags$span(class = "filter-badge fb-amber",
                        icon("location-dot", class = "me-1"), n_loc, " ", loc_type, " in view"
              )
          )
        ),
        
        actionButton(
          "btn_show_locations",
          tagList(icon("list-ul"), paste0(" View ", loc_type, " (", n_loc, ")")),
          class = "btn btn-warning btn-sm fw-bold rounded-pill px-3 shadow-sm"
        )
    )
  })
  
  observeEvent(input$btn_show_locations, {
    df <- base_data()
    if (input$state == "All States") {
      locations   <- sort(unique(df$STATE_NAME))
      modal_title <- paste0("States in Current View — ", length(locations), " total")
    } else {
      locations   <- sort(unique(df$DISTRICT_NAME[df$STATE_NAME == input$state]))
      modal_title <- paste0("Districts in ", input$state, " — ", length(locations), " total")
    }
    
    showModal(modalDialog(
      title = div(
        icon("map-pin", class = "me-2 text-warning"),
        modal_title
      ),
      div(class = "p-2",
          lapply(locations, function(loc) tags$span(class = "loc-badge", loc))
      ),
      footer    = modalButton(tagList(icon("xmark"), " Close")),
      size      = "l",
      easyClose = TRUE
    ))
  })
  
  output$kpi_exp        <- renderText({
    paste0("₹", formatC(sum(agg_data()$EXPENDITURE_OCCURED_LAKHS, na.rm = TRUE),
                        format = "f", big.mark = ",", digits = 0), " L")
  })
  output$kpi_roads      <- renderText({
    formatC(sum(agg_data()$LENGTH_OF_ROAD_WORK_COMPLETED_KM, na.rm = TRUE),
            format = "f", big.mark = ",", digits = 0)
  })
  output$kpi_bridges    <- renderText({
    formatC(sum(agg_data()$NO_OF_BRIDGES_COMPLETED, na.rm = TRUE),
            format = "d", big.mark = ",")
  })
  output$kpi_road_sanc  <- renderText({
    formatC(sum(agg_data()$LENGTH_OF_ROAD_WORK_SANCTIONED_KM, na.rm = TRUE),
            format = "f", big.mark = ",", digits = 0)
  })
  output$kpi_road_bal   <- renderText({
    formatC(sum(agg_data()$LENGTH_OF_ROAD_WORK_BALANCE_KM, na.rm = TRUE),
            format = "f", big.mark = ",", digits = 0)
  })
  output$kpi_road_perc  <- renderText({
    sanc <- sum(agg_data()$LENGTH_OF_ROAD_WORK_SANCTIONED_KM, na.rm = TRUE)
    comp <- sum(agg_data()$LENGTH_OF_ROAD_WORK_COMPLETED_KM,  na.rm = TRUE)
    if (sanc > 0) paste0(round((comp / sanc) * 100, 1), "%") else "0%"
  })
  output$kpi_bridge_sanc <- renderText({
    formatC(sum(agg_data()$NO_OF_BRIDGES_SANCTIONED, na.rm = TRUE),
            format = "d", big.mark = ",")
  })
  output$kpi_bridge_bal  <- renderText({
    formatC(sum(agg_data()$NO_OF_BRIDGES_BALANCE, na.rm = TRUE),
            format = "d", big.mark = ",")
  })
  
  output$top_exp <- renderTable({
    agg_data() %>% arrange(desc(EXPENDITURE_OCCURED_LAKHS)) %>% head(5) %>%
      select(Location, `Expenditure (Lakhs)` = EXPENDITURE_OCCURED_LAKHS) %>%
      mutate(`Expenditure (Lakhs)` = formatC(`Expenditure (Lakhs)`, format = "f", big.mark = ",", digits = 0))
  }, width = "100%", align = "lr")
  
  output$bot_exp <- renderTable({
    agg_data() %>% arrange(EXPENDITURE_OCCURED_LAKHS) %>% head(5) %>%
      select(Location, `Expenditure (Lakhs)` = EXPENDITURE_OCCURED_LAKHS) %>%
      mutate(`Expenditure (Lakhs)` = formatC(`Expenditure (Lakhs)`, format = "f", big.mark = ",", digits = 0))
  }, width = "100%", align = "lr")
  
  output$top_road <- renderTable({
    agg_data() %>% arrange(desc(LENGTH_OF_ROAD_WORK_COMPLETED_KM)) %>% head(5) %>%
      select(Location, `Roads (km)` = LENGTH_OF_ROAD_WORK_COMPLETED_KM) %>%
      mutate(`Roads (km)` = formatC(`Roads (km)`, format = "f", big.mark = ",", digits = 0))
  }, width = "100%", align = "lr")
  
  output$bot_road <- renderTable({
    agg_data() %>% arrange(LENGTH_OF_ROAD_WORK_COMPLETED_KM) %>% head(5) %>%
      select(Location, `Roads (km)` = LENGTH_OF_ROAD_WORK_COMPLETED_KM) %>%
      mutate(`Roads (km)` = formatC(`Roads (km)`, format = "f", big.mark = ",", digits = 0))
  }, width = "100%", align = "lr")
  
  output$top_bridge <- renderTable({
    agg_data() %>% arrange(desc(NO_OF_BRIDGES_COMPLETED)) %>% head(5) %>%
      select(Location, Bridges = NO_OF_BRIDGES_COMPLETED) %>%
      mutate(Bridges = formatC(Bridges, format = "d", big.mark = ","))
  }, width = "100%", align = "lr")
  
  output$bot_bridge <- renderTable({
    agg_data() %>% arrange(NO_OF_BRIDGES_COMPLETED) %>% head(5) %>%
      select(Location, Bridges = NO_OF_BRIDGES_COMPLETED) %>%
      mutate(Bridges = formatC(Bridges, format = "d", big.mark = ","))
  }, width = "100%", align = "lr")
  
  output$data_table <- renderDT({
    datatable(agg_data(), options = list(scrollX = TRUE))
  })
  
  output$main_plot <- renderPlot({
    df <- agg_data()
    req(nrow(df) > 0)
    var_name <- map_choices[input$plot_var]
    
    ggplot(df, aes(x = reorder(Location, -!!sym(var_name)),
                   y = !!sym(var_name),
                   fill = !!sym(var_name))) +
      geom_col(color = "white", alpha = 0.93, width = 0.72) +
      scale_fill_gradient(low = "#5DADE2", high = "#1B3A5C", guide = "none") +
      theme_minimal(base_size = 13) +
      theme(
        axis.text.x      = element_text(angle = 45, hjust = 1, size = 10, color = "#3a4a5c"),
        axis.text.y      = element_text(size = 10, color = "#3a4a5c"),
        axis.title       = element_text(size = 12, face = "bold", color = "#1B3A5C"),
        plot.title       = element_text(size = 14, face = "bold", color = "#1B3A5C", margin = margin(b = 8)),
        panel.grid.major.x = element_blank(),
        panel.grid.minor   = element_blank(),
        panel.grid.major.y = element_line(color = "#e0e8f0", linewidth = 0.5),
        plot.background  = element_rect(fill = "#F5F0E8", color = NA),
        panel.background = element_rect(fill = "#F5F0E8", color = NA)
      ) +
      labs(
        title = paste(input$plot_var, "by Location"),
        x     = "Location",
        y     = input$plot_var
      )
  })
  
  output$india_map <- renderTmap({
    map_df <- base_data() %>%
      group_by(STATE_NAME) %>%
      summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") %>%
      mutate(
        work_completed_percentage    = if_else(LENGTH_OF_ROAD_WORK_SANCTIONED_KM > 0,
                                               (LENGTH_OF_ROAD_WORK_COMPLETED_KM / LENGTH_OF_ROAD_WORK_SANCTIONED_KM) * 100, 0),
        bridges_completed_percentage = if_else(NO_OF_BRIDGES_SANCTIONED > 0,
                                               (NO_OF_BRIDGES_COMPLETED / NO_OF_BRIDGES_SANCTIONED) * 100, 0),
        bridges_balance_percentage   = if_else(NO_OF_BRIDGES_SANCTIONED > 0,
                                               (NO_OF_BRIDGES_BALANCE   / NO_OF_BRIDGES_SANCTIONED) * 100, 0),
        road_work_balance_percentage = if_else(LENGTH_OF_ROAD_WORK_SANCTIONED_KM > 0,
                                               (LENGTH_OF_ROAD_WORK_BALANCE_KM / LENGTH_OF_ROAD_WORK_SANCTIONED_KM) * 100, 0)
      )
    
    if (input$state != "All States") map_df <- map_df %>% filter(STATE_NAME == input$state)
    
    merged_data <- india_shapefile %>% left_join(map_df, by = "STATE_NAME")
    metric_name <- names(map_choices)[map_choices == input$map_var]
    
    tmap_mode("view")
    tm_shape(merged_data) +
      tm_borders(col = "#ffffff", lwd = 1.2) +
      tm_fill(
        col       = input$map_var,
        style     = "quantile",
        palette   = "YlOrRd",
        id        = "STATE_NAME",
        title     = metric_name,
        popup.vars = setNames(c("STATE_NAME", input$map_var), c("State", metric_name))
      )
  })
}

shinyApp(ui, server)