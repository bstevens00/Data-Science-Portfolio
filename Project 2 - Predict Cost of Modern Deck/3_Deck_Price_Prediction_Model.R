library(readr) # to import the data
library(ggplot2) # for the graphs
library(reshape2) # to reform the data in a way that ggplot2 likes it
library(MASS) # for the AIC method which is missing from regsubsets()
library(tidyverse) # for the everything
library(leaps) # for the exhaustive regression model search, regsubsets()
library(forecast) # accuracy() function to evaluate a model on test set
library(glmnet) # for Lasso and Ridge regression
library(rpart) # for simple regression tree
# library(rpart.plot) # for tree plot (not used)
library(randomForest) # for Random Forest algorithm
library(MLmetrics) # for the R2 calculation on the test data
library(caret) # findCorrelation() function
library(e1071) # for Support Vector Machine




##################
# Pre-Processing #
##################

# Import the data and take a look.
mmeta <- read_csv("https://raw.githubusercontent.com/bstevens00/Data-Science-Portfolio/main/data/project_2_modern_meta_8.6.2021.csv")

# The Archetype needs to be converted to a factor, we'll leave colors alone,
# as binary variables left as numeric play well with most algorithms.
mmeta[, 2] <- lapply(mmeta[, 2], FUN = factor)
str(mmeta)

# We also need to remove the Hammer-Time deck from the dataset, as
# it's the only deck with that Archetype, and that's going to make problems
# when we're trying to train and test the models.

mmeta <- mmeta[-4, ]

# This gets rid of this observation, but we need to remove the Aggro-Combo
# Archetype from the levels too.
levels(mmeta$Archetype) # Aggro-Combo present
mmeta$Archetype <- factor(mmeta$Archetype)
levels(mmeta$Archetype) # Removed

original_df <- mmeta # Storing the dataframe before we cut the deck names off

# Cutting out unused or redundant variables which are linear combinations of
# the others (like Total Fetchlands, which is just the sum of a bunch of
# columns, and would create unnecessary multicollinearity for no added benefit).
mmeta <- dplyr::select(mmeta, -one_of("Deck_Name",
                                      "Colors",
                                      "Proportion_of_Metagame",
                                      "Total_Fetchlands"))

# Finally, we'll normalize the remaining numeric features
min_max_norm <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

numeric_features <- as.data.frame(lapply(mmeta[2:18], min_max_norm))
# Note that the color columns didn't change, as normalization puts the data
# on a scale from 0 to 1, which these columns already were abiding by.

mmeta[2:18] <- numeric_features

set.seed(6) # for reproducibility

######################
# Variable Selection #
######################

# In real-world datasets, it is fairly common to have columns that are nothing
# but noise. We're are better off getting rid of such variables because of the
# memory space they occupy, the time and the computational resources it is
# going to cost, especially in large datasets. Sometimes, we have a variable
# that makes business sense, but are not sure if it actually helps in
# predicting the Y. We also need to consider a feature could be useful in one
# ML algorithm (say a decision tree) but may go underrepresented or unused by
# another (like a regression model).

# Some models have variable selection baked into their algorithm, and some do
# not. For this reason, we will first begin by screening the useful predictors
# first, so that we can understand why they are dropped by the later algorithms.

# Recall from the correlation matrix in the Exploratory Data Analysis, the
# Blue lands were the most correlated with deck price, as well as the popularity
# (deck count). We should expect these variables to be selected as important.

# The varImp function evaluates the variable importance differently, depending
# on the algorithm selected. Here, we've chosen multiple linear regression
# for the method ("lm"). This means the varImp function will choose variables
# using the absolute value of the t-statistic for each model parameter.

control <- trainControl(method="repeatedcv", number=10, repeats=3)
# train the model
model <- train(Deck_Price_USD ~ ., data = mmeta, method="lm", preProcess="scale", trControl=control)
# estimate variable importance
importance <- varImp(model, scale=FALSE)
importance

plot(importance,
     main = "Variable Importance: Which Predictors Affect Deck Price Most?",
     xlab = "The Higher this Number, the More Predictive")



# We see clear importance in the Archetype feature, as 4 of the top 6 features
# are levels from that feature out of 22 possible features from which to select.

# Another trend is there 3 distinct groups of importance. The first is whether
# the Archetype is Control Combo. The next in importance is the Archetype,
# Whether the deck plays Blue (Floode Strand, Misty Rainforest, Scalding Tarn).
# Finally, It appears that the presence of Black in a deck is important for
# predicting price.

# The last group are the mediocre predictors or worse, which is everything from
# Arid Mesa down.

# Let's use this smaller group of predictors in a Multiple Linear Regression
# model later.

mmeta_imporant_vars <- mmeta[, c(1, 4, 10, 12, 16, 19)]
# Includes Archetype, Flooded Strand, Misty Rainforest, Scalding Tarn, Black,
# and Deck Price.




# Another take at this would be to try a random forest method for determining
# the importance. We could do this a lot of ways, and we could even take the
# top 5 predictors from multiple different algorithms, creating a sort of
# ensemble of rank-sort-voted best predictors! But we'll just do one more to
# get a second take at variable importance.

model2 <- train(Deck_Price_USD ~ ., data = mmeta, method="rf", preProcess="scale", trControl=control)
importance2 <- varImp(model2, scale=FALSE)
importance2
plot(importance2)

# This method appears to snub Archetype as not important, and goes all in on
# the popularity of the deck. However, it too cares about the number of Blue
# Fetchlands! Which we really did expect.







#########################
# Partitioning the Data #
#########################

# In the previous project, we used Cross Validation, which is a fantastic
# resampling method to increase the number of predictions. Here though, for the
# sake of variety, we'll only split the data into the classic 80/20
# training/testing data.

train_index <- sample(1:nrow(mmeta), nrow(mmeta)*0.8)
train_df <- mmeta[train_index, ] # data we'll use to train our models
test_df <- mmeta[-train_index, ] # data we'll use to compare models

# Special subselection of predictors as determined by variable importance alg.
imp_var_train <- mmeta_imporant_vars[train_index, ] # data we'll use to train our models
imp_var_test <- mmeta_imporant_vars[-train_index, ] # data we'll use to compare models



##############################
# How To Evaluate the Models #
##############################

# This is a prediction problem, so we're interested in how the model behaves on
# the testing data, not the training. The first is the domain of predictive
# analytics and the second of explanatory modeling. We want the second.

# Unlike Classification problems, there is no equivalent to a confusion matrix.
# When doing explanatory modeling, a popular method for testing model fit is
# the R-Squared, which ranges from 0-1. This has a different meaning when
# applied to the test data.

# R-Squared Rule of Thumb for test data: High R2 is > 0.6. This ensures the
# model fits the data relatively well. You expect some loss in R-Squared when
# moving from the training to the test data.

# We will also consider the Root Mean Squared Error (RMSE), which has gained
# popularity as the de facto score with which predictive/regression models are
# measured against one another.

# RMSE assumes that error are unbiased and follow a normal distribution.
# Here are the key points to consider on RMSE:

# 1. The power of 'square root'  empowers this metric to show large number
# deviations.
# 2. The 'squared' nature of this metric helps to deliver more robust results
# which prevents cancelling the positive and negative error values. In other
# words, this metric aptly displays the plausible magnitude of error term.
# 3. It avoids the use of absolute error values which is highly undesirable in
# mathematical calculations.
# 4. When we have more samples, reconstructing the error distribution using
# RMSE is considered to be more reliable.
# 5. RMSE is highly affected by outlier values. Hence, make sure you've removed
# outliers from your data set prior to using this metric.
# 6. As compared to mean absolute error, RMSE gives higher weightage and
# punishes large errors.

# The Root Mean Square Error is similar to the Standard Deviation. But instead
# of being calculated with respect to a single mean with a bunch of points
# dispersed around it, the RMSE is using the prediction line as the mean, and
# slowly moving along it and seeing how far the values are off of it on average.

# RMSE Rule of Thumb for test data: Lower the better. The test set RMSE should
# be less than 10% of the range in the numeric response variable.

# Here is the range of the deck prices in the format:
deck_price_rang <- range(mmeta$Deck_Price_USD)[2] - range(mmeta$Deck_Price_USD)[1]



#####################################
# Creating and Analyzing the Models #
#####################################

###-----
#--- Multiple Linear Regression (all predictors, no alterations)
###-----

mlr <- lm(Deck_Price_USD ~ ., data = train_df)
summary(mlr)
# Using an alpha = 0.05 level of significance...
# Looks like multiple levels of the Archetype predictor are significant

# Here are the predictions on the holdout/test data.
mlr_preds <- predict(mlr, newdata = test_df)

# Checking the Root Mean Square Error
mlr_RMSE <- accuracy(mlr_preds, test_df$Deck_Price_USD)
mlr_RMSE

# We have an RMSE of 394.8869. Importantly, this is a relative calculation, so
# we'll need to compare it to other models we'll be creating, but we can compare
# it to the 10% of the range of the response rule from before!

# Percent of the range the RMSE makes up:
mlr_RMSE[2]/deck_price_rang
# This model's RMSE is 27% of the range, so it's not a good model.


# Now the R-Squared
mlr_R2 <- R2_Score(mlr_preds, test_df$Deck_Price_USD)
mlr_R2

# R-Squared should a value from 0 to 1. This is odd. What's happening?

# Bottom line: R2 can be greater than 1.0 only when an invalid (or nonstandard)
# equation is used to compute R2 and when the chosen model (with constraints,
# if any) fits the data really poorly, worse than the fit of a horizontal line.
# Also, a negative R2 is not a mathematical impossibility or the sign of a
# computer bug. It simply means that the chosen model (with its constraints)
# fits the data really poorly.

# So, since it wasn't calculated wrong, we can assume this model is very bad,
# and we'd be better off just using the average price as a prediction than
# to use this model. Yikes. Well, can hopefully only go up from here!





# Now let's try the model which includes only the predictors deemed important
# as determined by the t-statistic from the caret package algorithm.
mlr_2 <- lm(Deck_Price_USD ~ ., data = imp_var_train)
summary(mlr_2)

mlr_2_preds <- predict(mlr_2, newdata = imp_var_test)

# Checking the Root Mean Square Error
mlr_2_RMSE <- accuracy(mlr_2_preds, test_df$Deck_Price_USD)
mlr_2_RMSE

mlr_2_RMSE[2]/deck_price_rang
# This score is better, but still much more than 10% of the range


mlr_2_R2 <- R2_Score(mlr_2_preds, test_df$Deck_Price_USD)
mlr_2_R2
# This R2 is at least within the realistic range this time! But, it's still
# not impressive. We want something above 0.6, and 0.2 won't cut it.


# That's okay. These were more demonstrations of how to evaluate the predictive
# power of a model using the RMSE and R2 anyway. Let's see if we have more luck
# using more sophisticated models and algorithms.






###-----
#--- Exhaustive Search (All possible linear models)
###-----

# Let's try to run an exhaustive search for every possible model, including
# all 18 predictors. This algorithm is best for finding the "Best Fit" for
# use in Explanatory Analysis, but let's try it to have something with which
# to compare our other algorithms.

# THIS WILL PRODUCE A WARNING READ BELOW.
exhaustive_search <- regsubsets(Deck_Price_USD ~ .,
                                nvmax = dim(train_df)[2],
                                nbest = 1,
                                data = train_df,
                                method = "forward",
                                warn.dep = FALSE)

# Apparently there's 1 linearly dependency, so one of the predictor columns
# is a combination of redundant information from the other columns... Must be
# a categorical variable, since we did Principal Component Analysis, and there
# wasn't any sign of dimension decrease.

# Trying to run the model without "Archetype" as a predictor.
exhaustive_search <- regsubsets(Deck_Price_USD ~ .,
                                nvmax = dim(train_df)[2],
                                nbest = 1,
                                data = train_df[, -1],
                                method = "exhaustive")
# It works. This makes a bit of sense, as the Archetype of a deck is often
# color-related, and apparently so related it's color dependent!

# Switching the "-1" to "-2", then "-3", "-4"... all the way to the end of the
# predictors ended with only the Archetype being a linear combination. It may
# be the case that it should be dropped.

# Let's see how it behaves without that column.

######################## Ignore this section below
# If we were interested in Explanatory Modeling, the following would be useful:
exhaustive_summary <- summary(exhaustive_search)

# Show the models
exhaustive_summary$which

# Check the metrics for fit, R squared, Adj R squared, Mallows Cp, etc.

# First, R-Squared.
exhaustive_summary$rsq # Each option better than last
# R-squared (R2) is a statistical measure that represents the proportion of
# the variance for a dependent variable that's explained by an independent
# variable or variables in a regression model.

# The R2 is going up in every case, meaning there isn't a more complex model
# that is blatantly worse than the one that preceded it. However,
# R squared always inflates with more predictors. Let's look at the pentalized
# cousin of R squared...

# Adjusted R-Squared.
exhaustive_summary$adjr2 # 8th score or 8 predictors is best
# Adjusted R-Squared penalizes the model for using additional predictors, as
# the Rsq will increase every time you add a new predictor by design, this
# will take into account adding complexity to the model and punish less 
# parsimonious models.

# Here, it can be seen that the Adjusted R-Squared increases until 7 predictors
# are used, before dropping back down. However, it only provides Adj-R = 0.473
# as a score, which isn't impressive at all.

exhaustive_summary$cp
# The best Mallow's Cp score is the one that is closest to the number of
# predictors in that model. The first score we're looking for 1, the second
# score we're looking for it two, etc. It'll likely continue going down until
# the number we're looking for intercects with the drop of what the cp actually
# ends up being. In this case around 4 predictors we get Cp = 4.33 and 5
# we get Cp = 4.47. So about 4 or 5 predictors should be used according to
# Mallow's Cp.
######################## Ignore this section above


# Exhaustive Search for model using Adjusted R-Squared for the training data
summary(exhaustive_search)

mlr_3_adjr <- lm(Deck_Price_USD ~ Deck_Count +
                   Bloodstained_Mire +
                   Flooded_Strand +
                   Marsh_Flats +
                   Misty_Rainforest +
                   Prismatic_Vista +
                   Verdant_Catacombs +
                   Scalding_Tarn,
                 data = train_df[, -1]
)

summary(mlr_3_adjr)

# Making preds and finding RMSE
mlr_3_preds <- predict(mlr_3_adjr, newdata = test_df)

# Checking the Root Mean Square Error
mlr_3_RMSE <- accuracy(mlr_3_preds, test_df$Deck_Price_USD)
mlr_3_RMSE
# This RMSE is worse than the previous model.

mlr_3_R2 <- R2_Score(mlr_3_preds, test_df$Deck_Price_USD)
mlr_3_R2
# Worse than the previous model




mlr_4_cp <- lm(Deck_Price_USD ~ Marsh_Flats +
                 Misty_Rainforest +
                 Verdant_Catacombs +
                 Scalding_Tarn,
               data = train_df[, -1]
)

mlr_4_preds <- predict(mlr_4_cp, newdata = test_df)
mlr_4_RMSE <- accuracy(mlr_4_preds, test_df$Deck_Price_USD)
mlr_4_RMSE
# Looks like the simpler model takes it, here! Woo woo Mallow's Cp!

mlr_4_R2 <- R2_Score(mlr_4_preds, test_df$Deck_Price_USD)
mlr_4_R2
# Still a bad R-Squared, though.

# Again,
# since we're not doing Explanatory Modeling, we don't really care about the
# best model for fitting the training data, rather the best model for fitting
# the test data. We'll use these models to illustrate how a higher R2 in the
# training data doesn't always translate to a higher predictive power on the
# test data.






###-----
#--- StepAIC
###-----

# The Akaike Information Criterion (AIC) is a popular algorithmic model
# selection algorithm that uses a single number, the AIC, to compare models
# relative to each other, similar to the R-Squared, Adjusted R-Squared, and
# Mallow's Cp. It's part of the leaps() package, not the MASS() one. This
# algorithm attempts forward and backward selection in the same way as the
# leaps() library, except it uses AIC instead of the other 3 metrics.


# Forward and Backward with AIC

# Using he MASS package, stepAIC method. Similary to the R2, Adjusted R2,
# and Mallow's Cp, the AIC is a number that helps us choose regression
# subsets. For AIC, the lower the score the better.

# Start by creating the model for the analysis
mlr_5_AIC <- lm(Deck_Price_USD ~ ., data = mmeta)

stepAIC(mlr_5_AIC, method = "backward")
# The backward selection method uses 13 variables

stepAIC(mlr_5_AIC, method = "forward")
# This one comes to the same conclusion

stepAIC(mlr_5_AIC, method = "both")
# And the hybrid method as well

# So, the Goodness of fit metrics, the Adj R, Mallow's Cp, and AIC, all have
# varying preferences for models. We'll check to see how each of the choices
# for the varying models do in predicting the test data.

# Replacing the model with the smaller one the StepAIC found
mlr_5_AIC <- lm(formula = Deck_Price_USD ~ Archetype +
                  Black +
                  Green +
                  Flooded_Strand + 
                  Misty_Rainforest +
                  Scalding_Tarn,
                data = mmeta)


mlr_5_preds <- predict(mlr_5_AIC, newdata = test_df)
mlr_5_RMSE <- accuracy(mlr_5_preds, test_df$Deck_Price_USD)
mlr_5_RMSE
# This RMSE is our best so far, but still not quite there

mlr_5_R2 <- R2_Score(mlr_5_preds, test_df$Deck_Price_USD)
mlr_5_R2
# Getting better, but not quite there!





###-----
#--- Ridge and Lasso Regression
###----- 

# alpha is for the elastic net mixing parameter, with range [0,1]. 1 is
# lasso regression (default) and 0 is ridge regression.

ridge_reg <- cv.glmnet(data.matrix(train_df[, c(1:18)]),
                       train_df$Deck_Price_USD, 
                       type.measure = 'mse',
                       nfolds=10,
                       alpha=0)

# summary for this package doesn't provide what we're used to using lm()
# so we have to request the coefficients of the model directly.
coef(ridge_reg)

ridge_preds <- predict(ridge_reg, data.matrix(test_df[, c(1:18)]))
# convert matrix to vector using c()
ridge_preds <- c(ridge_preds)
ridge_RMSE <- accuracy(ridge_preds, test_df$Deck_Price_USD)
ridge_RMSE
# This RMSE is one of the better ones we've seen, but it's 100
# points larger than the StepAIC method. Mediocre.


ridge_R2 <- R2_Score(ridge_preds, test_df$Deck_Price_USD)
ridge_R2 # positive at least, but not good.





lasso_reg <- cv.glmnet(data.matrix(train_df[, c(1:18)]),
                       train_df$Deck_Price_USD, 
                       type.measure = 'mse',
                       nfolds=10,
                       alpha=1)

# summary for this package doesn't provide what we're used to using lm()
# so we have to request the coefficients of the model directly.
coef(lasso_reg)

lasso_preds <- predict(lasso_reg, data.matrix(test_df[, c(1:18)]))
# convert matrix to vector using c()
lasso_preds <- c(lasso_preds)
lasso_RMSE <- accuracy(lasso_preds, test_df$Deck_Price_USD)
lasso_RMSE # Worse than Ridge Regression!

lasso_R2 <- R2_Score(lasso_preds, test_df$Deck_Price_USD)
lasso_R2 # Bad.




# Since Ridge did a solid amount better, let's try an Elastic Net that's
# weighted 80/20 towards Ridge
elastic_net <- cv.glmnet(data.matrix(train_df[, c(1:18)]),
                         train_df$Deck_Price_USD, 
                         type.measure = 'mse',
                         nfolds=10,
                         alpha=0.8)

# summary for this package doesn't provide what we're used to using lm()
# so we have to request the coefficients of the model directly.
coef(elastic_net)

elastic_net_preds <- predict(elastic_net, data.matrix(test_df[, c(1:18)]))
# convert matrix to vector using c()
elastic_net_preds <- c(elastic_net_preds)
elastic_net_RMSE <- accuracy(elastic_net_preds, test_df$Deck_Price_USD)
elastic_net_RMSE
# It's worse than both the pure versions!

elastic_net_R2 <- R2_Score(elastic_net_preds, test_df$Deck_Price_USD)
elastic_net_R2 # Bad.






###-----
#--- Simple Regression Tree
###----- 

# "class" for a classification tree, "anova" for a regression tree
# we want a regression tree

reg_tree <- rpart(Deck_Price_USD ~ ., data = train_df, method = 'anova')
tree_preds <- predict(reg_tree, newdata = test_df)
tree_RMSE <- accuracy(tree_preds, test_df$Deck_Price_USD)
tree_RMSE # Not good.

tree_R2 <- R2_Score(tree_preds, test_df$Deck_Price_USD)
tree_R2 # Bad.



###-----
#--- Random Forest
###-----

random_forest <- randomForest(Deck_Price_USD ~ ., data = train_df)
rforest_preds <- predict(random_forest, newdata = test_df)
rforest_RMSE <- accuracy(rforest_preds, test_df$Deck_Price_USD)
rforest_RMSE
# Decent, close to StepAIC

rforest_R2 <- R2_Score(rforest_preds, test_df$Deck_Price_USD)
rforest_R2
# Decent.





###-----
#--- Support Vector Machine
###-----

svm_mod <- svm(Deck_Price_USD ~ .,
               data = mmeta,
               kernel = "radial",
               cost = 10,
               type = "eps",
               probability = TRUE)

svm_preds <- predict(svm_mod, test_df)

# Checking the Root Mean Square Error
svm_RMSE <- accuracy(svm_preds, test_df$Deck_Price_USD)
svm_RMSE
# This RMSE is incredible!

svm_RMSE[2]/deck_price_rang

svm_R2 <- R2_Score(svm_preds, test_df$Deck_Price_USD)
svm_R2
# This R-Squared value is almost perfect, literally almost 1!





############################
# Individual Model Results #
############################

results_RMSE <- cbind(t(mlr_RMSE),
                      t(mlr_2_RMSE),
                      t(mlr_3_RMSE),
                      t(mlr_4_RMSE),
                      t(mlr_5_RMSE),
                      t(ridge_RMSE),
                      t(lasso_RMSE),
                      t(elastic_net_RMSE),
                      t(tree_RMSE),
                      t(rforest_RMSE),
                      t(svm_RMSE)
)

results_R2 <- cbind(t(mlr_R2),
                    t(mlr_2_R2),
                    t(mlr_3_R2),
                    t(mlr_4_R2),
                    t(mlr_5_R2),
                    t(ridge_R2),
                    t(lasso_R2),
                    t(elastic_net_R2),
                    t(tree_R2),
                    t(rforest_R2),
                    t(svm_R2)
)

rownames(results_R2) <- "R2"

# Binding these two columns together
results <- rbind(results_RMSE, results_R2)


# Creating column names
alg_names <- c("Mult_Reg",
               "MLR_Important",
               "Exh_Adj_R2",
               "Exh_M_Cp",
               "StepAIC",
               "Ridge_Reg",
               "Lasso_Reg",
               "Elastic_Net",
               "Reg_Tree",
               "RForest",
               "SVM"
)

# Adding names to df
colnames(results) <- alg_names


results <- data.frame(t(results))

results <- results[, c(2, 6)]
results

# Here are the results of the multiple models, sorted by best RMSE (lowest)
arrange(results, RMSE) %>%
  select(RMSE, R2)

# Here are the results sorted by the best R2 (Highest)
arrange(results, desc(R2)) %>%
  select(RMSE, R2)

# As we can see, the best performing model is - by far - the Support Vector
# Machine.

# The next two closest were StepAIC and Random Forest.

# While neither of these models quite makes the cut for an acceptable model,
# as the 10% cut off for RMSE was...
0.1*deck_price_rang # 131.4
# and the R-Squared scores were about .2 lower than we needed, which is a lot...

# We may still try an Ensemble model that mergest together the strongest models.







####################
# Ensemble Attempt #
####################

# Let's merge the three top models. Even though that Support Vector Machine
# result is going to be hard to beat!


model_preds <- cbind(mlr_5_preds, rforest_preds, svm_preds)

# finding the average price prediction for each of the 12 hold out values
ensemble_pred <- rowMeans(model_preds)

model_preds <- data.frame(model_preds, ensemble_pred, test_df$Deck_Price_USD)


colnames(model_preds) <- c("StepAIC",
                           "RForest",
                           "SVM",
                           "Ensemble",
                           "Observed")

model_preds
# Here we see all the predictions for each of the 12 hold out values, as well
# as how they stack up at a glance compared to what was expected as a value in
# each case.

# The Ensemble and Observed values are added on for additional information.
ensemble_RMSE <- accuracy(model_preds$Ensemble, test_df$Deck_Price_USD)
ensemble_RMSE
# The RMSE isn't small enough to be under the 10% cut off, but it's almost 100
# lower than before.

ensemble_R2 <- R2_Score(model_preds$Ensemble, test_df$Deck_Price_USD)
ensemble_R2
# The R-Squared value is above 0.6, which we like to see.






###########################################
# Final Results - Price Prediction Model? #
###########################################

# Considering the weak RMSE and R-Squared values for almost every individual
# model aside from the remarkably-well-performing Support Vector Machine model,
# if we were to choose a prediction model, it should assuredly be the baseline
# Support Vector Machine model.

# Let's see it in action, predicting the price of a deck for which we already
# know the price, on average.

# Let's select a deck from the original df, which still had names attached.
original_df[26, c(1, 2, 23)]
# Hardened Scales is our random choice/ An aggro deck with an average price
# of 526. Incidentally, MATH: 526 was the name of my college Stats course.
# Extremely useful information.

# Let's see how well our model, Support Vector Machine, predicts it.
new_observation <- mmeta[26,]

predict(svm_mod, newdata = new_observation) # 492.7499

# The actual price of this deck is 526 USD, and the model predicted it as
# 492.75 USD, which is only off by about 35 USD. That's incredible, considering
# the price of decks in for format range from 262 to 1576 USD.
range(mmeta$Deck_Price_USD)
