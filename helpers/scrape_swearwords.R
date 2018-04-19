library(rvest)
library(tidyverse)

url <- 'https://www.noswearing.com/dictionary'

site <-
  read_html(url)


subsites <-
  site %>%
  html_nodes(xpath = '/html/body/center/div[2]/*') %>%
  html_attr('href') %>%
  . [4:length(.)]

human_wait = function(t = 2, tt = 4){
  Sys.sleep(sample(seq(t, tt, by=0.001), 1))
}

getCurseWords <- function(x){

page <-
  read_html(x)

selector <- "/html/body/center/center[2]/div/table"

table <- page %>%
  html_nodes(xpath = selector) %>%
  html_nodes("a") %>%
  html_attr("name")

return(table)

human_wait(t = 2,tt = 4)

}

result <- map(.x = subsites,.f = getCurseWords)
names(result) <- c(LETTERS)

shitwordlist <-
  unlist(result) %>%
  as.character() %>%
  .[!is.na(.)]

devtools::use_data(shitwordlist,overwrite = TRUE)





