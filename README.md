
<!-- README.md is generated from README.Rmd. Please edit that file -->

# plumber.control

<!-- badges: start -->

[![R build
status](https://github.com/vanhry/plumber.control/workflows/R-CMD-check/badge.svg)](https://github.com/vanhry/plumber.control/actions)
<!-- badges: end -->

The goal of plumber.control is to control all of your R plumber
(actually any http based) services in one place.

## Installation

Development version

``` r
remotes::install_github("vanhry/plumber.control")
```

``` r
library(plumber.control)
```

If you want to use this library you must create `yaml` file of your
plumber services

``` yaml
# http://localhost:7055/health
plumber_local:
  host: localhost
  port: 7055
  path:
  method_plumber: health
  scheme: http

# http://localhost/paysystem/healthcheck
plumber_paysystem:
  host: localhost
  port:
  path: paysystem
  method_plumber: healthcheck
  scheme: http
```

Add to your `plumber.R` file **/healthcheck** method

``` r
#' @get /healthcheck
function(res) {
  res$status <- 200
  res$body <- "Healthy"
  res
}
```

You can use `create_table_plumber("path/to/file")` to receive the table
of all
services

``` r
data <- create_table_plumber(system.file("plumber_services.yaml",package="plumber.control"))
data
#>              Service Status                                    URL result
#> 2      plumber_local    404           http://localhost:7055/health  FALSE
#> 21 plumber_paysystem    404 http://localhost/paysystem/healthcheck  FALSE
```

Also it’s possible to use shiny application with:

``` r
plumber.control::run_app()
```

![Shiny app screen](inst/shiny_app_image.png)

Build Docker

``` shell
docker build . -t user/plumbercontrol_app -f Dockerfile.min
```

Project was created using [golem](https://github.com/ThinkR-open/golem)
package
