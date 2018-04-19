
#* @get /trollR
classify_text <- function(text = "Hello World - Sample Text"){
  library(trollR)

  troll <- predict_troll(text)

  list(
    text = text,
    troll_certainty = troll
  )
}
