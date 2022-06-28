# This is a branch or continuation of the Exploratory Data Analysis of the 
# StudentsPerformance.csv data. It is a possible and natural last step after
# considering all of the solo models. You may begin here, but all visualizations
# of the data will be absent. For a fuller view of this data, view the file 
# below, titled 1_EDA_student_performance.R:

# URL: https://github.com/bstevens00/Data-Science-Portfolio/tree/main/Exploratory%20Data%20Analysis/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic

###############################################
# Reading in the data in the format last seen #
###############################################

# import the data
library(readr)
studPerf <- read_csv("https://raw.githubusercontent.com/bstevens00/Data-Science-Portfolio/main/data/StudentsPerformance.csv")

# The categorical data needs to be formatted as factor, not character.
studPerf[, 1:5] <- lapply(studPerf[, 1:5], factor)

# Changing the order of the ordinal variable, so smallest education is first,
# and greatest education is last
levels(studPerf$`parental level of education`)
ed_ranked <- c("some high school", "high school",
               "some college", "associate's degree",
               "bachelor's degree", "master's degree")
studPerf$`parental level of education` <- 
  factor(studPerf$`parental level of education`,
         levels = ed_ranked)

colnames(studPerf) <- c("gender", "race", "parentEd", "reducedLunch",
                        "testPrepCourse", "mathScore", "readingScore",
                        "writingScore")




#####################################################
# Classification Model - Simple Classification Tree #
#####################################################

library(rpart) # Used for building classification and regression trees
library(rpart.plot)  # plotting regression trees

# We'll use a Simple Classification Tree this time. A Classification tree
# is a supervised machine learning method that uses discrete and continuous
# predictors to classify a dichotomous/binary outcome, such as "yes/no" or
# "boy/girl". It does this by recursively and binarily splitting the data into
# increasingly more purified rectangular-spaced subsets.

# First, a hyperplane is drawn to split the data in half (if there are only 2
# predictors, it's a literal line, and if there are 3 predictors, it's a plane).
# Then, somewhere alone this "trunK" of the tree, a new branch grows, further
# splitting the data. Then, another branch. And another, until all of the
# observations are in entirely pure rectangles (leaves/terminal nodes).

# The issue is that while it perfectly fits the data, it will overfit new data,
# That's because while all trees of the same species have a similar look to them,
# there are different variations amongst individual trees. That is, some of the
# splits in the training data are due to how the underlying data actually
# behaves, and some of it is due to noise/random chance. We don't want to model
# the random chance, so we need to prune the tree (ignore some of the later
# tree splits.)

# This is a literal thing that happens in classification trees, pruning. We'll
# do this in a bit.




################################################
# Partition the Data into Training and Testing #
################################################

# Now we need to create some training and test data.
# We'll do an 80/20 split, 80 percent of the data will act as training data
# and 20 percent will be hold out data for the testing of the model.

# What is 80 percent of 1000 (800, but this is what the code below answers)
training_size <- floor(0.8 * nrow(studPerf))
testing_size <- nrow(studPerf) - training_size

# For reproducibility, this allows the upcoming randomly generated numbers to
# be locked in when re-running this demonstration.
set.seed(6)

# Randomly assign the observations to be training or test values. We don't want
# to just cut them down the middle, in case they were reported in a specific
# order (again, the data is synthetic, but it's a good habit).

# First, choose the row numbers that will be the training observations
training_index <- sample(seq_len(nrow(studPerf)), size = training_size)
# The remaining rows are test observations

# Training labels (training outputs)
train_labels <- studPerf[training_index, 1]
# Test labels (testing outputs)
test_labels <- studPerf[-training_index, 1]

# Training data
data_train <- studPerf[training_index, c(1, 6:8)]
# Testing data
data_test <- studPerf[-training_index, c(1, 6:8)]




######################
# Creating the Model #
######################

# Now for the model.

mod_noprune <- rpart(gender ~ mathScore + readingScore + writingScore,
                     data = data_train,
                     cp = 0) # here is the model without any pruning

mod <- rpart(gender ~ mathScore + readingScore + writingScore,
             data = data_train) # here is the model after pruning algorithm

# plot the trees
prp(mod_noprune) # here is the perfectly pure tree, but overfitted
prp(mod) # here is a less pure tree, but least overfit, which we want

printcp(mod_noprune) # we see that there are 21 splits or 22 terminal nodes
printcp(mod) # the pruned tree only has 10 splits or 11 terminal nodes



predictions_noprune <- predict(object = mod_noprune,
                               newdata = data_test[, 2:4],
                               type = "class")
predictions_noprune # here is what the unpruned model predicts for new data

predictions <- predict(object = mod,
                          newdata = data_test[, 2:4],
                          type = "class")
predictions # here are the predictions for the pruned model


# And the associated probabilities for these predictions.
probs_noprune <- predict(object = mod_noprune,
                         newdata = data_test[, 2:4],
                         type = "prob")
probs_noprune

probs <- predict(object = mod,
                 newdata = data_test[, 2:4],
                 type = "prob")
probs # here are the probabilities that each of the students are a specific gender


# Let's see how the predictions stacked up against what was real
real_vs_pred <- data.frame(
  "Math_Score" = data_test$mathScore,
  "Reading_Score" = data_test$readingScore,
  "Writing_Score" = data_test$writingScore,
  "Observed" = test_labels$gender,
  "Prediction_NoPrune" = predictions_noprune,
  "Prediction" = predictions
)

real_vs_pred




#######################################################
# Evaluating the Model using Machine Learning Metrics #
#######################################################

# Right now the observation and gender columns are coded with "female/male".
# Let's switch this to "0/1" so we can utilize the caret package.

real_vs_pred$Observed <- ifelse(real_vs_pred$Observed == "female", "0", "1")
real_vs_pred$Observed <- factor(real_vs_pred$Observed)
real_vs_pred$Prediction <- ifelse(real_vs_pred$Prediction == "female", "0", "1")
real_vs_pred$Prediction <- factor(real_vs_pred$Prediction)
real_vs_pred$Prediction_NoPrune <- ifelse(real_vs_pred$Prediction_NoPrune == "female", "0", "1")
real_vs_pred$Prediction_NoPrune <- factor(real_vs_pred$Prediction_NoPrune)


# Skip these hidden lines. They were used to write data to .csv files for use
# in the simple ensemble model file, 1j, and are not needed for this analysis.
#####

# # Write the Predictions of the pruned tree to a .csv for later use in the
# # ensemble model (1j).

# ctree_prediction <- data.frame(
#   "ctree" = real_vs_pred$Prediction
# )
# 
# write.csv(ctree_prediction,
#           "output\\ctree_prediction.csv",
#           row.names = TRUE)
# 
# # We'll also store the probabilities associated with these predictions for
# # evaluating said ensemble model (ij).
# ctree_probs <- data.frame(
#   "ctree" = probs[, 2]
# )
# write.csv(ctree_probs,
#           "output\\ctree_probs.csv",
#           row.names = TRUE)
#####


# We'll evaluate this model using a confusion matrix and some common machine
# learning metrics.

library(caret) # All-in-one Confusion Matrix and list of metrics
library(MLmetrics) # If we want only a specific measurement

# From the MLmetrics package, we can get some of the individual metrics we want.
Sensitivity(y_true = unlist(test_labels), y_pred = predictions)
Specificity(unlist(test_labels), predictions)
Precision(unlist(test_labels), predictions)
AUC(probs[, 2], as.numeric(unlist(test_labels)) - 1)

# We can also use the confusionMatrix fuction from caret, which is great to
# give us a full diagnostic on the model.
confusionMatrix(real_vs_pred$Prediction_NoPrune, real_vs_pred$Observed)
confusionMatrix(real_vs_pred$Prediction, real_vs_pred$Observed)

# Looks like the classifier without any pruning actually does better when
# applied to new data this time, which happens, but is less common. Still, it's
# not MUCH better, so for the later ensemble model, we'll use the simpler model
# without pruning.





# Now, let's analyze the sensitivity and specificity tradeoff using a Receiver
# Operating Characteristic curve, or ROC curve, as well as the Area Under the
# Curve, or AUC. The purpose of this curve is to find the "sweet spot(s)" where
# the model gets the best Sensitivity and Specificity combined, rather than 
# sacrificing too much of one for little gains of the other.
library(pROC)

par(pty = "s") # this just makes the plot of the roc curve square.
roc_curve_unpruned <- roc(response = test_labels$gender,
                          predictor = probs_noprune[, 1],
                          plot = TRUE,
                          auc = TRUE,
                          percent = TRUE,
                          main = "ROC for Unpruned Tree Model",
                          xlab = "False Positive Percentage (1 - Specificity)",
                          ylab = "True Positive Percentage (Sensitivity)",
                          legacy.axes = TRUE)
roc_curve_unpruned # We have an Area under the curve of 87.09%, which is good,
# meaning that this is a pretty good model, and we are able to correctly predict
# the gender of the student based on their test grades 87.09% of the time!

roc_curve <- roc(response = test_labels$gender,
                 predictor = probs[, 1],
                 plot = TRUE,
                 auc = TRUE,
                 percent = TRUE,
                 main = "ROC for Pruned Tree Model",
                 xlab = "False Positive Percentage (1 - Specificity)",
                 ylab = "True Positive Percentage (Sensitivity)",
                 legacy.axes = TRUE)
roc_curve # 83.66% is good too, but not as good as the unpruned model.




#########################################
# Meta Content - Where to go from here? #
#########################################

# At this point, the reader may choose to move horizontally to another one
# of the models by viewing files 1a, 1c - 1i or see how all the models work
# together to make a potentially better model in 1j, the ensemble model.