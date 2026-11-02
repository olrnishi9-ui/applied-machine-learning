#1a
set.seed(1)

x <- rnorm(500)
y <- -2*x^3 + 0.4*x^4 + rnorm(500, 0, 3)

df <- data.frame(y = y, x = x)

colMeans(df)

#1b
set.seed(123)

foldid <- sample(rep(1:10, each = 50))

table(foldid)

#defining functions 
cv_four_models <- function(df, foldid) {
  
  formulas <- list(
    y ~ x,
    y ~ x + I(x^2),
    y ~ x + I(x^2) + I(x^3),
    y ~ x + I(x^2) + I(x^3) + I(x^4)
  )
  
  cv_mse <- numeric(4)
  
  for (degree in 1:4) {
    
    predictions <- numeric(nrow(df))
    
    for (k in 1:10) {
      
      test <- foldid == k
      
      fit <- lm(
        formulas[[degree]],
        data = df[!test, ]
      )
      
      predictions[test] <- predict(
        fit,
        newdata = df[test, ]
      )
    }
    
    cv_mse[degree] <- mean((df$y - predictions)^2)
  }
  
  return(cv_mse)
}

mse_123 <- cv_four_models(df, foldid)

data.frame(
  Degree = 1:4,
  CV_MSE = mse_123
)


#1c
seeds <- 124:133

cv_results <- matrix(
  NA_real_,
  nrow = length(seeds),
  ncol = 4
)

for (s in seq_along(seeds)) {
  
  set.seed(seeds[s])
  
  foldid <- sample(rep(1:10, each = 50))
  
  cv_results[s, ] <- cv_four_models(df, foldid)
}

matplot(
  1:4,
  t(cv_results),
  type = "b",
  pch = 16,
  lty = 1,
  col = rainbow(10),
  xaxt = "n",
  xlab = "Polynomial degree",
  ylab = "10-fold CV MSE",
  main = "CV results across 10 random partitions"
)

axis(1, at = 1:4)

#2
# Run once if needed: install.packages("bestglm")

library(bestglm)

X <- sapply(1:10, function(p) df$x^p)
colnames(X) <- paste0("x", 1:10)

poly_data <- data.frame(X, y = df$y)

#2a
best_fit <- bestglm(
  Xy = poly_data,
  family = gaussian,
  IC = "AIC",
  method = "exhaustive"
)


formula(best_fit$BestModel)

coef(best_fit$BestModel)

AIC(best_fit$BestModel)

#2b
forward_fit <- bestglm(
  Xy = poly_data,
  family = gaussian,
  IC = "AIC",
  method = "forward"
)

formula(forward_fit$BestModel)
coef(forward_fit$BestModel)
AIC(forward_fit$BestModel)

#2c
backward_fit <- bestglm(
  Xy = poly_data,
  family = gaussian,
  IC = "AIC",
  method = "backward"
)

formula(backward_fit$BestModel)
coef(backward_fit$BestModel)
AIC(backward_fit$BestModel)

#2d
comparison <- data.frame(
  Method = c("Best subsets", "Forward", "Backward"),
  AIC = c(
    AIC(best_fit$BestModel),
    AIC(forward_fit$BestModel),
    AIC(backward_fit$BestModel)
  )
)

print(comparison)

#3
# Run once if needed: install.packages(c("ISLR2", "glmnet"))

library(ISLR2)
library(glmnet)

dat <- ISLR2::Boston

# Predictor matrix and response
x <- model.matrix(medv ~ ., data = dat)[, -1]
y <- dat$medv

#3a
set.seed(123)

foldid <- sample(rep(1:5, length.out = nrow(dat)))

ols_pred <- numeric(nrow(dat))

for (k in 1:5) {
  test <- foldid == k
  
  fit <- lm(medv ~ ., data = dat[!test, ])
  
  ols_pred[test] <- predict(fit, newdata = dat[test, ])
}

ols_mse <- mean((y - ols_pred)^2)
ols_mse

#3b
grid <- 10^seq(4, -6, length = 100)

ridge_cv <- cv.glmnet(
  x, y,
  alpha = 0,
  lambda = grid,
  foldid = foldid,
  type.measure = "mse"
)

ridge_index <- which.min(ridge_cv$cvm)
ridge_mse <- ridge_cv$cvm[ridge_index]

data.frame(
  Lambda = ridge_cv$lambda.min,
  CV_MSE = ridge_mse
)

#3c
lasso_cv <- cv.glmnet(
  x, y,
  alpha = 1,
  lambda = grid,
  foldid = foldid,
  type.measure = "mse"
)

lasso_index <- which.min(lasso_cv$cvm)
lasso_mse <- lasso_cv$cvm[lasso_index]

lasso_coef <- as.matrix(
  coef(lasso_cv, s = "lambda.min")
)

# Exclude the intercept when counting selected predictors
lasso_nonzero <- sum(lasso_coef[-1, 1] != 0)

data.frame(
  Lambda = lasso_cv$lambda.min,
  CV_MSE = lasso_mse,
  Nonzero_predictors = lasso_nonzero
)

#3d
comparison3 <- data.frame(
  Model = c("OLS", "Ridge", "Lasso"),
  CV_MSE = c(ols_mse, ridge_mse, lasso_mse)
)

# Print from lowest to highest CV MSE
comparison3[order(comparison3$CV_MSE), ]

#3e
chosen_lambda <- c(
  lasso_cv$lambda.min,
  lasso_cv$lambda.1se
)

idx <- match(chosen_lambda, lasso_cv$lambda)

comparison_e <- data.frame(
  Choice = c("lambda.min", "lambda.1se"),
  Lambda = chosen_lambda,
  CV_MSE = lasso_cv$cvm[idx],
  Nonzero_predictors = lasso_cv$nzero[idx]
)

print(comparison_e)

# Quantify the trade-off
data.frame(
  MSE_increase = comparison_e$CV_MSE[2] -
    comparison_e$CV_MSE[1],
  
  Predictors_removed = comparison_e$Nonzero_predictors[1] -
    comparison_e$Nonzero_predictors[2]
)

#4a
library(glmnet)

dat4 <- MASS::birthwt
dat4$bwt <- NULL
names(dat4)

#4b
sum(is.na(dat4))   # 0 means no missing values

dat4[c("race", "smoke", "ht", "ui")] <-
  lapply(dat4[c("race", "smoke", "ht", "ui")], factor)

x4 <- model.matrix(low ~ ., dat4)[, -1]
y4 <- dat4$low

colnames(x4)

#4c
set.seed(2025)
fold4 <- sample(rep(1:5, length.out = nrow(dat4)))
grid4 <- 10^seq(3, -5, length = 100)

# Shared fitting function for ridge and lasso
fit_cv4 <- function(a) {
  cv.glmnet(
    x4, y4,
    family = "binomial",
    alpha = a,
    lambda = grid4,
    foldid = fold4,
    type.measure = "deviance",
    keep = TRUE
  )
}

ridge4 <- fit_cv4(0)
plot(ridge4)

# Extract results at the requested lambda
report4 <- function(fit, choice) {
  j <- match(fit[[choice]], fit$lambda)
  prob <- plogis(fit$fit.preval[, j])
  
  data.frame(
    Lambda = fit$lambda[j],
    Nonzero_predictors = fit$nzero[j],
    Misclassification_rate = mean((prob >= 0.3) != y4)
  )
}

ridge_result <- report4(ridge4, "lambda.min")
ridge_result

#4d
lasso4 <- fit_cv4(1)
plot(lasso4)

lasso_result <- report4(lasso4, "lambda.1se")
lasso_result

#4e
results4 <- rbind(
  Ridge = ridge_result,
  Lasso = lasso_result
)

results4
