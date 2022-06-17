#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import magrittr
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  mod_plumbers_table_server("plumbers_table_1")
}
