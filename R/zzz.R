.onLoad <- function(libname, pkgname) {
  allowed_names <- c("id","host",'port','path',"method_plumber","scheme")
  options("allowed_names"=allowed_names)
}
