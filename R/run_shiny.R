#' Shiny App Launcher
#'
#' @param example name of the app, defaults to trollR
#'
#' @return Nothing
#' @export
#'
#' @examples
#' \dontrun{
#'  run_shiny()
#' }
run_shiny <- function(example = "trollR") {
  # locate all the shiny app examples that exist
  validExamples <- list.files(system.file("shiny-examples", package = "trollR"))

  validExamplesMsg <-
    paste0(
      "Valid examples are: '",
      paste(validExamples, collapse = "', '"),
      "'")

  # if an invalid example is given, throw an error
  if (!example %in% validExamples) {
    stop(
      'Please run `run_shiny()` with a valid example app as an argument.\n',
      validExamplesMsg,
      call. = FALSE)
  }

  # find and launch the app
  appDir <- system.file("shiny-examples", example, package = "trollR")
  shiny::runApp(appDir, display.mode = "normal")
}
