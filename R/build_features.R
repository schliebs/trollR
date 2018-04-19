#' Builds the feature-matrix from a text-vector
#'
#' @param x a vector of text
#' @param term_count_min a number passed to
#' \code{\link[text2vec]{prune_vocabulary}}, defaults to 1. In case the function
#' is used for training, it can and should be set to some higher value, i.e., 3.
#' @param mdl is a list of existing models-data (containing the vectorizer, the
#' tfidf, and the lsa object), defaults to NULL, in which case it is rebuild
#' @param parallel T/F if the task should be executed in parallel, defaults to TRUE
#' @param quiet T/F if the function remains silent, defaults to FALSE
#'
#' @return a list of two: a dgCMatrix that contains the features (columns) for
#' each text (row) and as a second element a list of the model that can be passed
#' as mdl
#' @export
#'
#' @examples
#' text <- c(
#'   "This is a first text that describes something",
#'   "A second Text That USES A LOT of CAPITALS",
#'   "Lastly MANY!!!! (like, really a lot!) punctuations!!!"
#' )
#'
#' build_features(text)
#'
#' dtm <- c("capit", "someth", "punctuat", "use", "mani", "second", "last",
#'    "describ", "like", "first", "realli")
#' build_features(text, dtm = dtm)
#'
#' # a second example
#' train <- c("Banking is finance", "flowers are not houses", "finance is power", "houses are build")
#' test <- c("finance is greed", "flowers belong in the garbage", "houses are build")
#'
#' a1 <- build_features(test)
#' a12 <- build_features(test, mdl = a1$mdl)
#'
#' a2 <- build_features(train, mdl = a1$mdl)
#' a2$res
build_features <- function(x, term_count_min = 1,
                           mdl = NULL, parallel = TRUE, quiet = FALSE) {

  t0 <- Sys.time()
  if (!quiet) cat("Calculating Features...\n")

  d <- data_frame(text = x)

  d <- d %>% mutate(
    length = str_length(text),
    ncap = str_count(text, "[A-Z]"),
    ncap_len = ncap / length,
    nsen = str_count(text, fixed(".")),
    nexcl = str_count(text, fixed("!")),
    nquest = str_count(text, fixed("?")),
    npunct = str_count(text, "[[:punct:]]"),
    nword = str_count(text, "\\w+"),
    nsymb = str_count(text, "&|@|#|\\$|%|\\*|\\^"),
    nsmile = str_count(text, "((?::|;|=)(?:-)?(?:\\)|D|P))")#,
    #nslur = str_count(tolower(text), paste(shitwordlist, collapse = "|"))
  )

  it_raw <- x %>%
    str_to_lower() %>%
    str_replace_all("[^[:alpha:]]", " ") %>%
    str_replace_all("\\s+", " ")

  if (parallel) {
    n_cores <- parallel::detectCores()
    doParallel::registerDoParallel(n_cores)

    it <- it_raw %>%
      text2vec::itoken_parallel(tokenizer = tokenizers::tokenize_word_stems,
                                progressbar = !quiet, n_chunks = n_cores)
  } else { # sequential execution

    it <- it_raw %>% text2vec::itoken(tokenizer =  tokenizers::tokenize_word_stems,
                                      progressbar = !quiet)
  }

  if (!is.null(mdl)) {

    vectorizer <- mdl$vectorizer
    tfidf <- mdl$tfidf

  } else {

    vectorizer <- text2vec::create_vocabulary(
      it, ngram = c(1, 1),
      stopwords = tm::stopwords("en")
    ) %>%
      text2vec::prune_vocabulary(
        term_count_min = term_count_min,
        doc_proportion_max = 0.5,
        doc_proportion_min = 0.001
        # vocab_term_max = 4000
      ) %>%
      text2vec::vocab_vectorizer()
  }

  if (!quiet) cat("Create DTM...\n")
  dtm <- text2vec::create_dtm(it, vectorizer)

  mdl_new <- list(
    vectorizer = vectorizer
  )

  res <- d %>%
    select(-text) %>%
    Matrix::sparse.model.matrix(~ . - 1, .) %>%
    cbind(dtm)

  if (!quiet) cat(sprintf("Finished in %s seconds\n",
                          difftime(Sys.time(), t0, units = "secs") %>% round(2)))
  return(list(model_matrix = res, mdl = mdl_new))
}
