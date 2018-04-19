library(trollR)
library(xgboost)

train <- read_csv("../train.csv")
y <- train %>% select(-id, -comment_text) %>% rowSums() %>% {. > 0} * 1

# 1. Build the Features
mdl_data <- build_features(train$comment_text, term_count_min = 3)
usethis::use_data(mdl_data, overwrite = T)

# Load or Train the Model (xgbost)

# directly load the model
# model <- xgb.load("inst/xgboost_model.buffer")

# train the model
p <- list(objective = "binary:logistic",
          booster = "gbtree",
          eval_metric = "auc",
          nthread = 8,
          eta = 0.2,
          max_depth = 5,
          min_child_weight = 5,
          subsample = 0.7,
          colsample_bytree = 0.7)

model <- xgboost(mdl_data$model_matrix, y,
               params = p,
               print_every_n = 20, nrounds = 1000,
               early_stopping_rounds = 100)

xgb.save(model, "inst/xgboost_model.buffer")

# Evaluate the Performance of the Model
y_pred <- 1 * (predict(model, mdl_data$model_matrix) > 0.35)
caret::confusionMatrix(factor(y_pred), factor(y))



# REBUILD PACKAGE NOW!
