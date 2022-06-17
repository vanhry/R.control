#' plumbers_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_plumbers_table_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
    column(4, actionButton(ns("refresh"), "Refresh table")),
    column(4, fileInput(ns("yaml_file"), NULL, accept=c(".yml",".yaml"),placeholder = "Upload yaml"))
    ),
    hr(),
    DT::dataTableOutput(ns("plumbers_table"))
  )
}

#' plumbers_table Server Functions
#'
#' @noRd
mod_plumbers_table_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    observeEvent(input$refresh, {

      if (is.null(input$yaml_file)){
        showModal(modalDialog(
          "Please upload a valid yaml file",
          easyClose = T
        ))
        return()
      }

      services <- create_table_plumber(input$yaml_file$datapath,is.shiny = T)

      if (is.null(services))
        return()

      print('here')
      output$plumbers_table <- DT::renderDataTable({
        # add colors to Status
        services$Status <- as.character(services$Status) %>%
          purrr::map_chr(., ~ ifelse(startsWith(.,"2"),
                                     as.character(shiny::span(.,style='color:green')),
                                     as.character(shiny::span(.,style='color:red'))))
        # add links to URL
        services$URL <- purrr::map_chr(services$URL, ~ paste0("<a href='",.,"'>",.,"</a>"))
        DT::datatable(services %>% dplyr::select(-c("result")),
                      escape = FALSE,
                      selection = "none",
                      options = list(pageLength = 10,
                                     dom = 'frtip',
                                     searching = FALSE),
                      rownames = FALSE)
      })
    })
  })
}
