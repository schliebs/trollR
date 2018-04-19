
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
devtools::install_github("schliebs/trollR",
                         auth_token = "6957b42653250daa253173f2b5e0f8e384a8f961")
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

Data Examples
=============

The training dataset `train`

``` r
library(trollR)
train <- read_csv("raw-data/train.csv")
#> Parsed with column specification:
#> cols(
#>   id = col_character(),
#>   comment_text = col_character(),
#>   toxic = col_integer(),
#>   severe_toxic = col_integer(),
#>   obscene = col_integer(),
#>   threat = col_integer(),
#>   insult = col_integer(),
#>   identity_hate = col_integer()
#> )
train %>% glimpse()
#> Observations: 159,571
#> Variables: 8
#> $ id            <chr> "0000997932d777bf", "000103f0d9cfb60f", "000113f...
#> $ comment_text  <chr> "Explanation\nWhy the edits made under my userna...
#> $ toxic         <int> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, ...
#> $ severe_toxic  <int> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
#> $ obscene       <int> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
#> $ threat        <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
#> $ insult        <int> 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
#> $ identity_hate <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
```

toxic
-----

``` r
train %>% filter(toxic == 1) %>% select(comment_text) %>% top_n(3) %>% pull()
#> Selecting by comment_text
#> [1] "“ I protected the pages against your very poor editing, which is understandable as you're new here.\n\nMy editing was not poor as anyone can see it for him/herself. But let us take you for your word. You protected the page against my poor editing which is understandable because I am new here. Oh really? Can you show me where in the rules of Wikipedia says protect a page against a newcomer if his editing is poor? Who decided my editing is poor? You! Based on what? Based on your religious fervor! There was nothing wrong with my style that would contravene the standards of Wikipedia. It was the content of what I wrote that you could not stand. You keep justifying your biased action against me hiding behind the rules and fail each and every time to say exactly which rules I broke. There is no rule that I broke. You know that. That is why you constantly act like a mommy talking to a child. “if you behave good we will let you play”. Be specific Ms. SlimVirgin. I can show the rules that you broke. Can you show me the rules that I broke. Can you be specific for once? Why not apologize and demonstrate that you can also be a great person? \n\n“Secondly, the suggestions I left on the talk pages actually favored your view to a large extent” \n\nAre you trying to insult my intelligence? \n\nSo you are Indonesian, the same country MENJ comes from and all those death threats were issued against Ali Sina that you could not tolerate. Well it is difficult to see the nationality of a person through the Internet. However it is not that difficult to see the bias. In fact most Iranians are now anti Islamists. I guess they had enough of Islam. \n\nYou did enough of lecturing Ms. SlimVirgin about how I should apply the rules of Wikipedia. I read those rules before making my first contribution. You should read it again to refresh your memory. I have accused you of being biased against me and have proven it. There is also a complaint against you by someone else. So I am not the only one receiving you sting. Instead of lecturing me why don’t you answer my charges? These lecturings are smoke screens behind which you try to hide your own sins."
#> [2] "✋🏼 \n\nDrake Bell is transphobic trash and people need to know that!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
#> [3] "„Same Ukraininan vandal” — same to who? Russian nazi, stop drinking vodka!"
```

severe\_toxic
-------------

``` r
train %>% filter(severe_toxic == 1) %>% select(comment_text) %>% top_n(3) %>% pull()
#> Selecting by comment_text
#> [1] "| decline=Niggers, jews, bad news! Also my cock is hard so it's time for rape lol 86.181.0.14"
#> [2] "Σ IS A GIGANTIC ASSHOLE. \n\nΣ IS A GIGANTIC ASSHOLE."                                        
#> [3] "|fukin arseholes dicks cunts die u priks"
```

obscene
-------

``` r
train %>% filter(obscene == 1) %>% select(comment_text) %>% top_n(3) %>% pull()
#> Selecting by comment_text
#> [1] "—   | Talk  I, who am coming in from the wild, I, who happen to be Reform and think this Sanhedrin is, pardon my French, bullshit, shall be the third, as I believe that honorable editing is a Wikimitzvah."
#> [2] "✋🏼 \n\nDrake Bell is transphobic trash and people need to know that!"                                                                                                                                        
#> [3] "———————————\nHahahah get fucked filthy mudslime\nhttps://www.youtube.com/watch?v=sz90k9mug24"
```

threat
------

``` r
train %>% filter(threat == 1) %>% select(comment_text) %>% top_n(3) %>% pull()
#> Selecting by comment_text
#> [1] "{{Unblock|Unblock or I'll kill you."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
#> [2] "{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!{{unblock}}LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON, NIGGAZ, 420 MOONSHINE, FUCK!LIFETIME BAN LIFETIME BAN I WANTA FUCKIN LIFETIME BAN!!! BAIL OUT, BEAVIS AND BUTTHEAD, JESSICA SIMPSON"
#> [3] "your mom is my slave and your father is my bitch \n\nyou all shall bow down to me and your mothers will suck my balls. your father is my slave and i will drive him into the ground with my forhead. as you look upon this page and gasp i enter your soul and devour your flesh."
```

insult
------

``` r
train %>% filter(insult == 1) %>% select(comment_text) %>% top_n(3) %>% pull()
#> Selecting by comment_text
#> [1] "✋🏼 \n\nDrake Bell is transphobic trash and people need to know that!"                        
#> [2] "———————————\nHahahah get fucked filthy mudslime\nhttps://www.youtube.com/watch?v=sz90k9mug24"
#> [3] "„Same Ukraininan vandal” — same to who? Russian nazi, stop drinking vodka!"
```

identity\_hate
--------------

``` r
train %>% filter(identity_hate == 1) %>% select(comment_text) %>% top_n(3) %>% pull()
#> Selecting by comment_text
#> [1] "| decline=Niggers, jews, bad news! Also my cock is hard so it's time for rape lol 86.181.0.14"                                                                                                                                         
#> [2] "{{unblock}}  BECAUSE BAIL OUT IS THE BEST FUCKIN BAND EVER AND I SHOULD BE ABLE TO WRITE WEHATEVER I WANT ABOUT THEM.  AND I'M SICK OF THIS BLOCKING CRAP!  IF YOU'RE GONNA DO THAT, I WANT A LIFETIME BAN!  BAN!!!!\nFUCK YOU NIGGAZ!"
#> [3] "„Same Ukraininan vandal” — same to who? Russian nazi, stop drinking vodka!"
```

Non-Toxic Content
-----------------

``` r
train %>% 
  filter(
    toxic == 0,
    severe_toxic == 0,
    obscene == 0,
    threat == 0, 
    insult == 0,
    identity_hate == 0
  ) %>%
  select(comment_text) %>% top_n(3) %>% pull()
#> Selecting by comment_text
#> [1] "﻿Sensual Pleasures of the MindItalic text\n\nThere are endless creative ways to provoke and capture sensual feelings. Money can’t buy it, you can’t see it or hold it, outer\npackaging offers no competition for it and no grandiose flash of materialistic presence can incite it. Sensuality in it’s truest sense can only be felt within.  It is provoked by and through the power and brilliance of the mind. It is born there and lives there.\n\nSince it is a feeling rather than a physical event, it is more difficult to achieve and maintain than might be found with other less deeply rooted sexual experiences.  Knowledge, intuition and creativity are the tools necessary to discover where it lives and how to awaken it, what it takes to stimulate it and how to nurture it so it will grow. A conscientious partner can create a need and cravings simply by using the power of the mind.    \n\nAll of this offers new meaning to the old adage about the mind being a terrible thing to waste. There are hot spots in the psyche that can be triggered by suggestion and connection. (Emotional Buttons)  Pushing those buttons engenders our partner's sensory and sexual experience. We do this by using one type of energy to spark another and by channeling emotional reactions into sexuality. Where the adventure leads is limited only by the knowledge, intuition and creativity an individual possesses. Nothing is written in stone and there is no list of how to’s.  It’s freelance flight.\n\nKnowledge is power! Getting to know your partner and what makes her/him tick and tingle is the first step. The ability to\nunearth these secret treasures comes from paying close attention to things you say or do that result in an action or reaction\nindicating you have your finger on a button (hot spot). Finding all of those buttons, exploring the endless possibilities and\ndiscovering the wondrous places they lead, takes patience and thought, but the rewards are immeasurable.\n\nHaving well honed intuition is a valuable asset. Liken it, if you will, to a good quarter back with a natural talent for reading the defense. If you ‘know’ what your partner needs, wants and desires without her/him having to explain it all, then you hold a powerful advantage. Possessing a good base knowledge of the opposite sex, in general, offers a continual win, win proposition\n\nBeing gifted with a creative imagination or obtaining skills in this arena will offer many positives for a lasting and pleasurable sex life. Desires and cravings are born in the mind and live there so it would make sense to use the power of the mind to it fullest to gain the greatest results. Spice and adventure are two major factors in all sexual experiences. If they are not on the top of your list of priorities then they should be. Avoiding boredom is key in creating cravings for more. If it wasn't good the first time, why would anyone want to repeat it?  Taking your partner to a place where she/he has never been before and making each experience a lasting memory should be primary goals. That is the stuff heroes are made of.\n\nSexual stimulation can be achieved and sustained through physical manipulation, sexual pleasures, or through mind play and manipulation A physical presence, a verbal exchange, a mere mental/emotional connection or any combination of all of the above can create an ‘altered mental state’, a place of arousal and euphoria.\n\nSensual/erotic tasks and journals are great avenues to maintain altered states. Rituals and sensual tasks , while away from your\npartner can help keep the buttons pushed, the bond strong, keep the connection flowing and offer sexual stimulation on an\nongoing basis. Keeping your partner in an ‘altered state’ often and for as long as possible will help in creating cravings and lead to a path ultimate sexual pleasure.\n\nAltered states....\n1-Sexuality.....intensely 'turned on' riding a sexual high ...erotica.....consumed by passion\n2-Endorphin high...... an altered state resulting from physical or intense mental stimulation.\n3-Euphoria.....totally absorbed in your partner and the sensations and feelings being created.\n5-Head space......spellbound/entranced..lost in the release of control..total freedom and flight..to be absorbed in the trust and acceptance..a peaceful place\n6-Nirvana......meditative state.....heightened consciousness with loss of awareness.....having a sense of self through 'losing oneself'......total freedom through total loss of control.\n\nAll sexual experiences need to be consensual and remain safe."
#> [2] "这是什么意思？\n\nYou have been blocked from editing.\n62.194.166.79 (your account, your IP address or a range of addresses) was blocked by Jpgordon for the following reason (see our blocking policy):\ntor\n\nYour IP address is 62.194.166.79, and your block has been set to expire: indefinite."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
#> [3] "只, is it correctly written in the picture of the calligraphy?  I would say it isn't.  It is replaced by the wrong word 隻."
```

Overview of sample
------------------

``` r
theme_set(theme_light())
train %>% 
  mutate(n_insults = toxic + severe_toxic + obscene + threat + insult + identity_hate) %>% 
  group_by(n_insults) %>% 
  tally() %>% 
  ggplot(aes(x = n_insults, y = n)) + 
  geom_col() +
  geom_label(aes(label = n)) +
  labs(x = "Number of Insults per Comment", y = "Count")
```

<img src="man/figures/README-plot2-1.png" width="100%" />
