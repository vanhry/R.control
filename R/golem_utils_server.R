
#' @title read_plumbers
#' @name read_plumbers
#' @description Read yaml of plumbers
#' @param file location of description of plumber services
#'
#'
#' @noRd
read_plumbers <- function(file) {
  if (is.null(file))
    stop("`file` must be specified")
  if (fs::file_exists(file)){
    data <- yaml::read_yaml(file = file)
  } else {
    stop("`file` doesn't exist")
  }

  return(data)
}


#' @title single_query_plumber
#' @name single_query_plumber
#' @description Perform the single plumber service check
#' @param host,port of the plumber service
#' @param path of the plumber service, specify it with `/path`
#' @param method_plumber healthcheck path
#' @param scheme http/https
#'
#' @noRd
single_query_plumber <- function(id, host=NULL, port=NULL, path=NULL, method_plumber=NULL, scheme=NULL, is_shiny_app=NULL) {
  if (is.null(host)) {
    host <- "localhost"
  }
  if (is.null(method_plumber)) {
    method_plumber <- "healthCheck"
  }
  if (is.null(scheme)) {
    scheme <- "http"
  }
  if (is.null(path))
    path <- ""

  if (!is.null(port)){
    if (is.na(as.numeric(port)))
      stop("`Port` must be a numeric")
  }

  # building url
  url <- httr2::url_parse(host)
  url$hostname <- host
  if (!is.null(port))
    url$port <- port

  url$path <- fs::path("/", path, method_plumber)
  url$scheme <- scheme
  url <- httr2::url_build(url)

  # create request
  req <- httr2::request(url) %>%
    httr2::req_method(
      ifelse(is_shiny_app,
             "HEAD",
             "GET")
    )

  # add optional fields
  # if (!purrr::is_empty(headers))
  #   req %>% httr2::req_headers(!!!headers)
  #
  # if (!purrr::is_empty(body_json))
  #   req %>% httr2::req_body_json(body_json)

  # perform the request
  res_code <- tryCatch({
    res <- req %>% httr2::req_perform()
    return(rlang::list2(
      id = id,
      status = as.character(res$status_code),
      url = url,
      result = T,
      is_shiny_app = is_shiny_app
    ))
  }, error=function(e) {

    return(rlang::list2(
      id = id,
      status = "404",
      url = url,
      result = F,
      is_shiny_app = is_shiny_app
    ))
  })
}

#' @title create_table_plumber
#' @name create_table_plumber
#'
#' @description make queries to check whether or not plumbers work
#'
#' @param file file of yaml with plumbers
#' @param is.shiny whether shiny env
#' @import dplyr
#' @export
create_table_plumber <- function(file, is.shiny=F) {
  # prepare the list of services
  yaml_raw <- read_plumbers(file)

  if (isFALSE(is.list(yaml_raw))) {
    if (isFALSE(is.shiny)) {
      stop("Yaml file must be non empty")
    } else {
      showModal(modalDialog(
        "Yaml file must be non empty",
        easyClose = T
      ))
      return(NULL)
    }
  }

  # stack list into data.frame
  yaml_df <- as.data.frame(do.call(rbind, yaml_raw)) %>%
    tibble::rownames_to_column(var = "id")

  # check names of yaml
  if (!all(names(yaml_df) %in% getOption("allowed_names"))) {
    if (isFALSE(is.shiny)) {
      stop(paste("You are not allowed to use another names than",
                 paste0(getOption("allowed_names"),collapse = ",")))
    } else {
      showModal(modalDialog(
        "Yaml file is invalid",
        easyClose = T
      ))
      return(NULL)
    }
  }

  # perform query for each services
  params_plumbers <- purrr::pmap(yaml_df, single_query_plumber)

  # stack results into data.frame
  res.df <- do.call(rbind.data.frame, params_plumbers)

  # change colnames
  colnames(res.df) <- c("Service","Status", "URL", "result","is_shiny_app")

  return(res.df)
}


#' @description create html status based on status
#' @param x character of service status
#'
#'
#' @noRd
color_status <- function(x) {
  ifelse(startsWith(x,"2"),
         as.character(shiny::span(x,style='color:green')),
         as.character(shiny::span(x,style='color:red')))
}

#' @description prepare Head method
#' @param url url of head
#'
#' @noRd
head_url <- function(url) {
  httr2::request(url) %>%
    httr2::req_method("HEAD")
}
