.onLoad <- function(libname, pkgname) {
  allowed_names <- c("id","host",'port','path',"method_plumber","scheme","is_shiny_app")
  options("allowed_names"=allowed_names)
}
