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

################################################################
# Classification Model - Quadratic Discriminant Analysis (LDA) #
################################################################

library(MASS) # needed for LDA and QDA

# Here we'll use the LDA method to classify the gender of each observation.

# LDA data needs to be normalized. Normalization is a scaling technique in
# which data points are shifted and rescaled so that they end up in a range from
# 0 to 1. This way the algorithm is comparing "like" or equally weighted numbers.

# Note that technically, the 3 numeric predictors are on a similar scale in this
# example, but it's a good habit to do this, so we're going to do it.
studPerf[, 6:8] <- scale(studPerf[, 6:8])
View(studPerf) # note that the student test scores have changed to be centered
# around zero, and have all scaled down in size.




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

mod <- qda(gender ~ mathScore + readingScore + writingScore,
           data = data_train)


# Now for the actual model/predictions
predictions <- predict(mod, data_test)
preds <- predictions$class

# And here are the associated probabilities of the previous predictions
probs <- predictions$posterior[,2] # only interested in the male probs


# Let's see how the predictions stacked up against what was real
real_vs_pred <- data.frame(
  "Math_Score" = data_test$mathScore,
  "Reading_Score" = data_test$readingScore,
  "Writing_Score" = data_test$writingScore,
  "Observed" = test_labels$gender,
  "Prediction" = preds
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


# Skip these hidden lines. They were used to write data to .csv files for use
# in the simple ensemble model file, 1j, and are not needed for this analysis.
#####

# # Write the Predictions of the pruned tree to a .csv for later use in the
# # ensemble model (1j).
# QDA_prediction <- data.frame(
#   "QDA" = real_vs_pred$Prediction
# )
# 
# write.csv(QDA_prediction,
#           "output\\QDA_prediction.csv",
#           row.names = TRUE)
# 
# # We'll also store the probabilities associated with these predictions for
# # evaluating said ensemble model (ij).
# qda_probs <- data.frame(
#   "QDA" = probs
# )
# write.csv(qda_probs,
#           "output\\qda_probs.csv",
#           row.names = TRUE)
#####


# Let's see how the model does
library(caret) # All-in-one Confusion Matrix and list of metrics
confusionMatrix(real_vs_pred$Prediction, real_vs_pred$Observed)





# Now, let's analyze the sensitivity and specificity tradeoff using a Receiver
# Operating Characteristic curve, or ROC curve, as well as the Area Under the
# Curve, or AUC. The purpose of this curve is to find the "sweet spot(s)" where
# the model gets the best Sensitivity and Specificity combined, rather than 
# sacrificing too much of one for little gains of the other.
library(pROC)

par(pty = "s") # this just makes the plot of the roc curve square.
roc_curve <- roc(response = test_labels$gender,
                 predictor = probs,
                 plot = TRUE,
                 auc = TRUE,
                 percent = TRUE,
                 main = "ROC for Quadratic Discriminant Analysis Model",
                 xlab = "False Positive Percentage (1 - Specificity)",
                 ylab = "True Positive Percentage (Sensitivity)",
                 legacy.axes = TRUE)
roc_curve # An AUC of 95.3% means we can predict the classification 95.3% of
# the time, which is much better than guessing, and indicates a real difference
# between the two genders.