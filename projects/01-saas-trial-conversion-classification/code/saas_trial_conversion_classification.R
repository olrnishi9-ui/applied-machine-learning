saas <- read.csv("saas_trial.csv")
dim(saas)
str(saas)
#1(a)
rows_deleted <- sum(!complete.cases(saas))
saas <- na.omit(saas)
rows_deleted
saas_clean <- saas

#1(b)
continuous_vars <- c(
  "trial_days_active",
  "features_used",
  "sessions_per_week",
  "team_size",
  "usage_index"
)

saas_clean[continuous_vars] <- lapply(
  saas_clean[continuous_vars],
  log1p
)

summary(saas_clean[continuous_vars])

#1(c)
saas_clean[continuous_vars] <- scale(
  saas_clean[continuous_vars]
)
summary(saas_clean[continuous_vars])
saas <- saas_clean

#1(d)
channels <- model.matrix(
  ~ signup_channel - 1,
  data = saas
)

colnames(channels) <- c("Organic", "Paid", "Referral")

saas <- cbind(
  saas[names(saas) != "signup_channel"],
  channels
)
channel_counts <- colSums(channels)

barplot(
  channel_counts,
  main = "Users by Signup Channel",
  xlab = "Signup Channel",
  ylab = "Number of Users"
)
table(saas$upgraded)

par(mar = c(4, 4, 2, 1))

barplot(
  channel_counts,
  main = "Users by Signup Channel",
  xlab = "Signup Channel",
  ylab = "Number of Users"
)
data.frame(
  Signup_Channel = names(channel_counts),
  Users = as.integer(channel_counts)
)

#2a
required_columns <- c(
  "trial_days_active",
  "features_used",
  "sessions_per_week",
  "team_size",
  "usage_index",
  "upgraded",
  "Organic",
  "Paid",
  "Referral"
)

saas <- saas[, required_columns, drop = FALSE]

set.seed(2025)

train_index <- sample(
  seq_len(nrow(saas)),
  floor(0.70 * nrow(saas))
)

train <- saas[train_index, , drop = FALSE]
test  <- saas[-train_index, , drop = FALSE]

dim(train)
dim(test)


# Rebuild the data from the original file
saas <- read.csv("saas_trial.csv")
saas <- na.omit(saas)

continuous_vars <- c(
  "trial_days_active", "features_used", "sessions_per_week",
  "team_size", "usage_index"
)

saas[continuous_vars] <- lapply(saas[continuous_vars], log1p)
saas[continuous_vars] <- scale(saas[continuous_vars])

channels <- model.matrix(~ signup_channel - 1, data = saas)
colnames(channels) <- sub("^signup_channel", "", colnames(channels))
saas <- cbind(saas[names(saas) != "signup_channel"], channels)

set.seed(2025)
train_index <- sample(seq_len(nrow(saas)), floor(0.70 * nrow(saas)))
train <- saas[train_index, , drop = FALSE]
test  <- saas[-train_index, , drop = FALSE]

# 3(a)
logit_model <- glm(
  upgraded ~ . - Referral,
  data = train,
  family = binomial
)

train_prob <- predict(logit_model, newdata = train, type = "response")
test_prob  <- predict(logit_model, newdata = test, type = "response")

stopifnot(!anyNA(train_prob), !anyNA(test_prob))

train_pred <- ifelse(train_prob >= 0.5, 1, 0)
test_pred  <- ifelse(test_prob >= 0.5, 1, 0)

c(
  Train_Misclassification = mean(train_pred != train$upgraded),
  Test_Misclassification  = mean(test_pred != test$upgraded)
)

#3b 
confusion_05 <- table(
  Actual = test$upgraded,
  Predicted = test_pred
)

confusion_05

#3c
library(pROC)

roc_curve <- roc(
  test$upgraded,
  test_prob,
  levels = c(0, 1),
  direction = "<",
  quiet = TRUE
)

plot(
  roc_curve,
  main = "ROC Curve for Logistic Regression"
)

best_cutoff <- coords(
  roc_curve,
  x = "best",
  best.method = "closest.topleft",
  ret = c("threshold", "sensitivity", "specificity"),
  transpose = FALSE
)

best_cutoff

optimal_p <- best_cutoff$threshold[1]

optimal_p

#3d
optimal_pred <- ifelse(
  test_prob >= optimal_p,
  1,
  0
)

confusion_optimal <- table(
  Actual = test$upgraded,
  Predicted = optimal_pred
)

confusion_optimal

#3e
TN <- confusion_optimal["0", "0"]
FP <- confusion_optimal["0", "1"]
FN <- confusion_optimal["1", "0"]
TP <- confusion_optimal["1", "1"]

rates <- c(
  TPR = TP / (TP + FN),
  TNR = TN / (TN + FP),
  FPR = FP / (FP + TN),
  FNR = FN / (FN + TP)
)

rates

#4a
library(MASS)

dummy_columns <- c("Organic", "Paid", "Referral")

train_lda <- train[, !names(train) %in% dummy_columns]
test_lda  <- test[, !names(test) %in% dummy_columns]

lda_model <- lda(
  upgraded ~ .,
  data = train_lda
)

lda_train_pred <- predict(lda_model, train_lda)
lda_test_pred  <- predict(lda_model, test_lda)


lda_train_error <- mean(
  lda_train_pred$class != train_lda$upgraded
)

lda_test_error <- mean(
  lda_test_pred$class != test_lda$upgraded
)

c(
  Train_Misclassification = lda_train_error,
  Test_Misclassification = lda_test_error
)

#4b
lda_confusion <- table(
  Actual = test_lda$upgraded,
  Predicted = lda_test_pred$class
)

lda_confusion

#4c
high_certainty <- colSums(
  lda_test_pred$posterior > 0.8
)

high_certainty

#4d
TN <- lda_confusion["0", "0"]
FP <- lda_confusion["0", "1"]
FN <- lda_confusion["1", "0"]
TP <- lda_confusion["1", "1"]

lda_rates <- c(
  TPR = TP / (TP + FN),
  TNR = TN / (TN + FP),
  FPR = FP / (FP + TN),
  FNR = FN / (FN + TP)
)

lda_rates

#5a
library(FNN)


x_train <- as.matrix(train[, names(train) != "upgraded"])
x_test  <- as.matrix(test[, names(test) != "upgraded"])
y_train <- factor(train$upgraded)
y_test  <- factor(test$upgraded, levels = levels(y_train))

set.seed(1234)

knn_results <- do.call(rbind, lapply(3:11, function(k) {
  train_pred <- FNN::knn(x_train, x_train, y_train, k = k)
  test_pred  <- FNN::knn(x_train, x_test, y_train, k = k)
  
  data.frame(
    k = k,
    Train_Error = mean(train_pred != y_train),
    Test_Error  = mean(test_pred != y_test)
  )
}))

knn_results
colnames(x_train)

#5b
k_values <- 3:11

confusion_matrices <- lapply(k_values, function(k) {
  test_pred <- FNN::knn(
    train = x_train,
    test  = x_test,
    cl    = y_train,
    k     = k
  )
  
  table(Actual = y_test, Predicted = test_pred)
})

names(confusion_matrices) <- paste("k =", k_values)
print(confusion_matrices)

#5c
best <- knn_results[
  which.min(knn_results$Test_Error),
]

c(
  Best_k = best$k,
  Test_Accuracy = 1 - best$Test_Error
)

