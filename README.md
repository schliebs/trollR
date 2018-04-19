
<!-- README.md is generated from README.Rmd. Please edit that file -->
trollR - Online Troll Detection using R
=======================================

LSE Hackathon Challenge: Detecting Online Trolling Behaviour

Data source: <https://www.kaggle.com/c/jigsaw-toxic-comment-classification-challenge/>

Data description

A large number of Wikipedia comments which have been labeled by human raters for toxic behavior. The types of toxicity are:

-   toxic
-   severe\_toxic
-   obscene
-   threat
-   insult
-   identity\_hate

Usage
=====

To install the package use

``` r
# install.packages("devtools")
devtools::install_github("schliebs/trollR")
library(trollR)
library(xgboost)
```

``` r
predict_troll("Hello World - this is an example of trollR - Identifying trolling comments using R")
#> [1] 0.0722369

# take some text
text <- c(
  "I would like to point out that your comment was substandard!",
  "YOU SHOULD DIE!!!!",
  "YOU SHOULD DIE",
  "you should die!!!!",
  "you should die",
  "Go rot in hell",
  "I can also write something non-toxic -- really",
  "COCKSUCKER BEFORE YOU PISS AROUND ON MY WORK",
  "bloody hell, i forgot my purse at the pub yesterday"
)

# and find how likely it is to be trolling?
data_frame(text = text, troll = predict_troll(text)) %>% arrange(-troll)
#> # A tibble: 9 x 2
#>   text                                                          troll
#>   <chr>                                                         <dbl>
#> 1 COCKSUCKER BEFORE YOU PISS AROUND ON MY WORK                 0.972 
#> 2 bloody hell, i forgot my purse at the pub yesterday          0.958 
#> 3 Go rot in hell                                               0.796 
#> 4 you should die!!!!                                           0.729 
#> 5 YOU SHOULD DIE!!!!                                           0.714 
#> 6 YOU SHOULD DIE                                               0.667 
#> 7 you should die                                               0.543 
#> 8 I would like to point out that your comment was substandard! 0.0739
#> 9 I can also write something non-toxic -- really               0.0281
```

Thats all?
----------

Of course not

``` r
run_api()
```

![](https://puu.sh/A6q4N/d0661c33be.png)

Or from a terminal

``` bash
curl "http://localhost:8000/trollR?text=You suck you cocksucker"
```

`{"text":["You suck you cocksucker"],"troll_certainty":[0.9746]}`

But wait, there is more

``` r
run_shiny()
```

![](https://puu.sh/A6r1b/169e66db24.png)

Understanding the model
=======================

``` r
# load the model
model <- xgb.load(system.file("xgboost_model.buffer", package = "trollR"))
df <- xgb.importance(mdl_data$model_matrix %>% colnames(), model) %>% as_data_frame()

vars <- c("length", "ncap", "ncap_len", "nsen", "nexcl", "nquest", "npunct", 
          "nword", "nsymb", "nsmile", "nslur")
df %>% 
  arrange(-Gain) %>% 
  top_n(20, Gain) %>% 
  mutate(Feature = reorder(Feature, Gain),
         Vartype = Feature %in% vars) %>% 
  ggplot(aes(x = Feature, y = Gain, fill = Vartype)) + 
  geom_col() +
  coord_flip() +
  labs(y = "Feature Importance in the XGBoost Model", x = "", title = "") +
  theme(axis.text.y = element_text(size = 15, face = "bold")) +
  scale_fill_brewer(palette = "Set1", guide = F)
```

<img src="man/figures/README-plot1-1.png" width="100%" />
