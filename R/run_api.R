#' Run the Plumber API
#'
#' @param ... parameters passed to \code{\link[plumber]{plumber}}
#'
#' @return invisible NULL
#' @export
#'
#' @examples
#' \dontrun{
#'   run_api()
#'   # try to got to: http://127.0.0.1:8000/trollR
#'   # or use http://127.0.0.1:8000/trollR?text=This may be a troll comment
#' }
run_api <- function(port = 8000) {
  library(plumber)
  r <- plumb(system.file("plumber_api.R", package = "trollR"))

  message("trollR Server API up and running!")
  message(sprintf("Running on localhost:%s/trollR (or http://127.0.0.1:%s/trollR)", port, port))
  message(sprintf("To use the API use: localhost:%s/trollR?text=hello world", port))
  message("End the Server API by pressing (ESC)...")
  suppressMessages(r$run(port = port))

  return(invisible(NULL))
}
