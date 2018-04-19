library(trollR)

# train <- read_csv("raw-data/train.csv")

mdl_data <- build_features(train$comment_text, term_count_min = 3)
usethis::use_data(mdl_data, overwrite = T)
# save(mdl_truth, file = "mdl_truth_data.rda")
# mdl_truth

# REBUILD PACKAGE NOW!

y <- train %>% select(-id, -comment_text) %>% rowSums() %>% {. > 0} * 1

library(xgboost)

p <- list(objective = "binary:logistic",
          booster = "gbtree",
          eval_metric = "auc",
          nthread = 8,
          eta = 0.2,
          max_depth = 5,
          min_child_weight = 5,
          subsample = 0.7,
          colsample_bytree = 0.7)

toy <- xgboost(mdl_data$model_matrix, y,
               params = p,
               print_every_n = 20, nrounds = 1000,
               early_stopping_rounds = 100)

y_pred <- 1*(predict(toy, mdl_data$model_matrix) > 0.35)
caret::confusionMatrix(factor(y_pred), factor(y))

xgb.save(toy, "inst/xgboost_model.buffer")

# REBUILD PACKAGE NOW!


# cv <- xgb.cv(mdl_data$model_matrix, label = y, params = p, print_every_n = 20, nrounds = 1000,
#              early_stopping_rounds = 100, nfold = 8)

