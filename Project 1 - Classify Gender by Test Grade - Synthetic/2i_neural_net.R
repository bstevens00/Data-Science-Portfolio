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

#####################################
# Classification Model - Neural Net #
#####################################

library(neuralnet) # needed for Neural Net model




################################################
# Partition the Data into Training and Testing #
################################################

# We need to create some training and test data.
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

mod <- neuralnet(gender ~ mathScore + readingScore + writingScore,
                 data = data_train)


# Now for the actual model/predictions
probs <- predict(mod, data_test)[,2] # only interested in the male probs


predictions <- list()
for(j in 1:length(probs)){
  if(probs[j] > .5){
    predictions[[j]] <- "male"
  } else {
    predictions[[j]] <- "female"
  } 
}
predictions <- factor(unlist(predictions))



# Let's see how the predictions stacked up against what was real
real_vs_pred <- data.frame(
  "Math_Score" = data_test$mathScore,
  "Reading_Score" = data_test$readingScore,
  "Writing_Score" = data_test$writingScore,
  "Observed" = test_labels$gender,
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


# Skip these hidden lines. They were used to write data to .csv files for use
# in the simple ensemble model file, 1j, and are not needed for this analysis.
#####

# # Write the Predictions of the pruned tree to a .csv for later use in the
# # ensemble model (1j).
# nnet_prediction <- data.frame(
#   "nnet" = real_vs_pred$Prediction
# )
# 
# write.csv(nnet_prediction,
#           "output\\nnet_prediction.csv",
#           row.names = TRUE)
# 
# # We'll also store the probabilities associated with these predictions for
# # evaluating said ensemble model (ij).
# nnet_probs <- data.frame(
#   "NNet" = probs
# )
# write.csv(nnet_probs,
#           "output\\nnet_probs.csv",
#           row.names = TRUE)
####


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
                 main = "ROC for Neural Net Model",
                 xlab = "False Positive Percentage (1 - Specificity)",
                 ylab = "True Positive Percentage (Sensitivity)",
                 legacy.axes = TRUE)
roc_curve # An AUC of 95.11% means we can predict the classification 95.11% of
# the time, which is much better than guessing, and indicates a real difference
# between the two genders.