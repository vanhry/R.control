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
    column(4, fileInput(ns("yaml_file"), NULL, accept=c(".yml",".yaml"),
                        placeholder = "Upload yaml"))
    ),
    hr(),
    div(class = "content_row",
    DT::dataTableOutput(ns("plumbers_table")),
    tags$script(
      glue::glue(
        "$(document).on('click', '#{{ns('plumbers_table')}} button', function () {
                            Shiny.onInputChange('{{ns('lastClickId')}}',this.id);
                            Shiny.onInputChange('{{ns('lastClick')}}', Math.random())
                        });",
          .open = "{{", .close = "}}"
      )
    ))
  )
}

#' plumbers_table Server Functions
#'
#' @noRd
mod_plumbers_table_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    rv <- reactiveValues(data=NULL)
    observeEvent(input$refresh, {

      if (is.null(input$yaml_file)){
        showModal(modalDialog(
          "Please upload a valid yaml file",
          easyClose = T
        ))
        return()
      }

      services <- create_table_plumber(input$yaml_file$datapath,is.shiny = T)
      rv$services <- services
      if (is.null(services))
        return()

      services <- services %>%
        tibble::rownames_to_column(var = 'index') %>%
        dplyr::mutate(Details = dplyr::case_when(
          is_shiny_app==T ~ paste0('<button class="btn btn-default action-button" id="detail_', index,
                                   '" type="button">Details</button>')
        ))

      output$plumbers_table <- DT::renderDataTable({
        # add colors to Status
        services$Status <- as.character(services$Status) %>%
          purrr::map_chr(color_status)
        # add links to URL
        services$URL <- purrr::map_chr(services$URL,
                                       ~ paste0("<a href='",.,"'>",.,"</a>"))
        DT::datatable(services %>% dplyr::select(-c("index", "result", "is_shiny_app")),
                      escape = FALSE,
                      selection = "none",
                      options = list(pageLength = 10,
                                     dom = 'frtip',
                                     searching = FALSE),
                      rownames = FALSE)
      })
    })

    observeEvent(input$lastClick, {
      if (input$lastClickId %>% startsWith("detail")) {
        selected_row <-
          as.numeric(
            gsub(
              "detail_",
              "",
              input$lastClickId
            )
          )

        print(selected_row)
        url <- rv$services[selected_row,]$URL
        print(url)

        shinybusy::show_modal_spinner(
          spin = "atom",
          color = "#123B55",
          text = "Please wait...",
          session = shiny::getDefaultReactiveDomain()
        )

        hrefs <- httr::GET(url) %>%
          xml2::read_html() %>%
          rvest::html_nodes("a") %>%
          rvest::html_attr("href") %>%
          stringr::str_split(pattern = "//")

        # filter other stuff
        filter_vec <- hrefs %>%
          purrr::map(length) %>%
          magrittr::is_less_than(2)

        # keep only names of services
        clean_hrefs <- hrefs[filter_vec] %>%
          stringr::str_replace_all("/", "")

        # create valud url path
        valid_hrefs <- fs::path(url, clean_hrefs)

        # perform req
        res <- valid_hrefs %>%
          purrr::map(head_url) %>%
          httr2::multi_req_perform()

        # get status based on whether req was success
        list_res <- res %>%
          purrr::map(function(x)
            ifelse(utils::hasName(x,"resp"),
                   x$resp$status, x$status_code)) %>%
          `names<-`(clean_hrefs)

        # prepare names
        values <- list_res %>% as.character() %>%
          purrr::map_chr(color_status)

        shinyapps <- names(list_res)
        new_data <- data.frame(`Shiny apps` = shinyapps,
                               `Status` = values)

        output$shiny_apps <- DT::renderDataTable({
          DT::datatable(new_data,
                        escape = FALSE,
                        class = 'cell-border stripe',
                        selection = "none",
                        rownames = FALSE,
                        filter="none",
                        options = list(
                                       pageLength=100,
                                       searching=F,
                                       lengthChange = FALSE,
                                       scrollX = TRUE))
        })

        shiny::showModal(
          modalDialog(
            fluidPage(DT::dataTableOutput(ns("shiny_apps"))),
            easyClose = T
          )
        )
      }
      })
  })
}
