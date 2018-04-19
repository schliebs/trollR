#' Detect if given texts are trolls
#'
#' @param x a vector of text
#' @param model_ a model that is passed to predict, defaults to the \code{model}
#' supplied with this package
#' @param mdl_data_ a model as returned by \code{\link{build_features}} (the mdl)
#'  containing the vectorizer, tfidf, and the lsa objects. Defaults to the
#'  \code{mdl_data} from this package.
#'
#' @return a vector with the same lengths as x that holds the predicted probabilities
#' that the given text is trolling
#' @export
#'
#' @examples
#' text <- c("You suck, die!", "What a nice world we have today", "I like you", "I hate you")
#' (pred <- predict_troll(text))
predict_troll <- function(x, model_ = NULL, mdl_data_ = NULL) {
  if (is.null(mdl_data_)) mdl_data_ <- mdl_data
  if (is.null(model_)) model_ <- xgboost::xgb.load(system.file("xgboost_model.buffer",
                                                               package = "trollR"))

  model_matrix <- build_features(x, mdl = mdl_data_$mdl, term_count_min = 1,
                                 parallel = F, quiet = T)
  pred <- predict(model_, model_matrix$model_matrix)
  return(pred)
}
