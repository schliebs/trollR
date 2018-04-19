#!!!! https://tex.stackexchange.com/questions/125274/error-font-ts1-zi4r-at-540-not-found !!!
'
devtools::document()
devtools::build()

pack <- "trollR"
path <- "C:/Users/Schliebs/OneDrive/github/trollR" #getwd()#find.package(pack)#

file.remove("C:/Users/Schliebs/OneDrive/github/trollR/trollR.pdf")
system(paste(shQuote(file.path(R.home("bin"), "R")),"CMD", "Rd2pdf", shQuote(path)))

pkgdown::build_site()


'


