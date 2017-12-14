library(shiny)
library(shinydashboard)
library(DT)

# Actual code -----
dashboardPage(title = "REBBL Player Market",
              skin="black",
              dashboardHeader(title = span(tagList(a(href="https://www.reddit.com/r/rebbl", img(src = "img/ReBBL_logo_800px_72dpi.png", width = "70px")),"Market"))),
              dashboardSidebar(disable = T),
              dashboardBody(
                includeCSS("www/css/dt.css"),
                tags$head(tags$style(HTML("
    .progress-striped .bar {
                                          background-color: #149bdf;
                                          background-image: -webkit-gradient(linear, 0 100%, 100% 0, color-stop(0.25, rgba(255, 255, 255, 0.6)), color-stop(0.25, transparent), color-stop(0.5, transparent), color-stop(0.5, rgba(255, 255, 255, 0.6)), color-stop(0.75, rgba(255, 255, 255, 0.6)), color-stop(0.75, transparent), to(transparent));
                                          background-image: -webkit-linear-gradient(45deg, rgba(255, 255, 255, 0.6) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, 0.6) 50%, rgba(255, 255, 255, 0.6) 75%, transparent 75%, transparent);
                                          background-image: -moz-linear-gradient(45deg, rgba(255, 255, 255, 0.6) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, 0.6) 50%, rgba(255, 255, 255, 0.6) 75%, transparent 75%, transparent);
                                          background-image: -o-linear-gradient(45deg, rgba(255, 255, 255, 0.6) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, 0.6) 50%, rgba(255, 255, 255, 0.6) 75%, transparent 75%, transparent);
                                          background-image: linear-gradient(45deg, rgba(255, 255, 255, 0.6) 25%, transparent 25%, transparent 50%, rgba(255, 255, 255, 0.6) 50%, rgba(255, 255, 255, 0.6) 75%, transparent 75%, transparent);
                                          -webkit-background-size: 40px 40px;
                                          -moz-background-size: 40px 40px;
                                          -o-background-size: 40px 40px;
                                          background-size: 40px 40px;
                                          }
                                          "))),
                fluidRow(
                  box(width=12, title = "Race", collapsible = T,
                      uiOutput("race_ui")
                  ),
                  conditionalPanel(
                    "input.race_picker != null",
                    box(width = 12, title = "Players available",
                        DT::dataTableOutput("team_summary")
                    )
                  )
                )
              )
)