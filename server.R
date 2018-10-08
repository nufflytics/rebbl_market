library(nufflytics)
library(tidyverse)
library(shiny)
library(DT)

# Data setup -----
load("data/key.rda")

# Actual code -----
get_player_summary <- function(t) {
  if(!("roster" %in% names(t))) return(NULL)
  
  map_df(t$roster, 
         ~(keep(., names(.)!="attributes") %>% 
             modify_at("casualties_state_id", ~map(.,id_to_casualty) %>% glue::collapse(", ")) %>% 
             modify_at("skills", ~map(., ~glue::glue("<img src='img/skills/{.}.png' title='{stringr::str_replace_all(.,'([a-z])([A-Z])','\\\\1 \\\\2')}' width=30 style='padding: 1px'>")) %>% glue::collapse("")) %>% 
             modify_depth(1,fill_nulls, "") %>% 
             modify_at("name",as.character)
         )
  ) %>% 
    arrange(number) %>%
    mutate(
      Type = stringr::str_replace_all(type, c(".*_"="", "([a-z])([A-Z])"="\\1 \\2")),
      nskills = stringr::str_count(skills,"<img"),
      skills = ifelse(level-nskills >1, paste0(skills,'<img src="img/skills/PositiveRookieSkills.png" title="Pending Level up" width=30 stype="padding: 1px">'), skills),
      Team = t$team$name
    ) %>% 
    select(
      Team, 
      Player = name,
      Type,
      Level=level,
      SPP = xp,
      TV = value,
      Injuries = casualties_state_id,
      `Acquired Skills` = skills
    )
  
}

get_player_data <- function(team_data) {
  players <- map(team_data, get_player_summary) %>% discard(is.null) %>% bind_rows %>% arrange(desc(TV))
  
  if (nrow(players)==0) return(data_frame(Player = "None available",	Type="",	Level="",	SPP="",	TV="", Injuries="",	`Acquired Skills`=""))
  
  players
}

shinyServer(function(input, output) {
  
  team_data <- reactiveValues()
  
  teams_response <- withProgress(api_teams(key, "REBBL Player Market"), message = "Finding teams", value = 1)
  
  races = teams_response$teams$race %>% unique() %>% stringr::str_replace_all("([a-z])([A-Z])","\\1 \\2") %>% sort
  
  
  output$race_ui <- renderUI(HTML(paste0('<div id="race_picker" class="btn-toolbar form-group shiny-input-radiogroup shiny-input-container shiny-input-container-inline shiny-bound-input" data-toggle="buttons">',
                         glue::glue('<label class="btn btn-primary">
                                    <input type="radio" name="race_picker" value="{races}"> {races}
                                    </label>') %>% glue::collapse("\n") ,
                         '</div>')))
  
  
  team_summary_ready <- reactiveValues(ready = FALSE)
  
  output$team_summary_ready = renderText(as.integer(team_summary_ready[["ready"]]))
  
  update_data <- function() {
    if(input$race_picker %in% names(team_data) | input$race_picker == "") return(NULL)
    
    api_response <- withProgress(message = "Loading players", value = 1,
                                 {teams_response$teams %>% 
                                   filter(race == stringr::str_replace_all(input$race_picker," ",""), team != "MNG Winners!") %>% 
                                   .$team %>% 
                                   map(~api_team(key, name = .))}
                                 )
    
    team_data[[input$race_picker]] = get_player_data(api_response)
    
    team_summary_ready[["ready"]] <- TRUE
  }
  
  observeEvent(input$race_picker,
               {update_data()}
  )

  output$team_summary <- DT::renderDataTable(
    {
      DT::datatable(
        team_data[[input$race_picker]],
        class = "display compact",
        selection = "none",
        escape  = F,
        rownames = F,
        options = list(
          dom = "t",
          pageLength = 100,
          ordering = T,
          scrollX = T
        )
    )
    }
  )
})
