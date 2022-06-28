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




##############################################
# Classification Model - Logistic Regression #
##############################################

# This time we'll try Logistic Regression. Logistic Regression is a supervised
# learning method that uses discrete and continuous predictors to classify a
# discrete response variable. Here we'll use it for a dichotomous/binary
# response.

# Logistic Regression is harder to explain in words than k-nearest-neighbors or
# classification trees, but without getting lost in the mathematical theory,
# the model finds the probability of belonging to one class and compares it to
# the probability of belonging to the other. This ratio is called the "odds".
# The model takes the logarithm of the odds, also called "log of the odds" or
# "logit" function for short, is used to create a sinusoid curve ("s"-
# shaped curve). Like many models, if the probability of belonging to one class
# is higher than the other, an observation is classified into that category.




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

mod <- glm(gender ~ mathScore + readingScore + writingScore,
           data = data_train, family = "binomial") # here is the model
summary(mod)

probs <- predict(mod, data_test, type = "response") # Here we use the model to
# predict new data
probs # here are the probabilities that each of the students are a specific gender
# the closer the probability is to zero, the more likely it is the student is a
# girl. The closer the probability is to one, the more likely the student is a
# boy.


# Now that we have the probabilities, we'll use the cutoff that if your prob is
# under 50% (less than or equal 0.50), the model will classify you as female. If you are
# above that cutoff (greater than 0.50), male.

predictions <- list()
for(j in 1:length(probs)){
  if(probs[j] > .5){
    predictions[[j]] <- "1"
  } else {
    predictions[[j]] <- "0"
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

# Right now the gender column is coded as female/male and predictions as 0/1.
# Let's switch female/male to 0/1 as well, so that we can compare the observed
# versus predicted values.

real_vs_pred$Observed <- ifelse(real_vs_pred$Observed == "female", "0", "1")
real_vs_pred$Observed <- factor(real_vs_pred$Observed)


# Skip these hidden lines. They were used to write data to .csv files for use
# in the simple ensemble model file, 1j, and are not needed for this analysis.
#####

# # Write the Predictions of the pruned tree to a .csv for later use in the
# # ensemble model (1j).
# 
# logistic_prediction <- data.frame(
#   "logistic" = predictions
# )
# 
# write.csv(logistic_prediction,
#           "output\\logistic_prediction.csv",
#           row.names = TRUE)
# 
# # We'll also store the probabilities associated with these predictions for
# # evaluating said ensemble model (ij).
# logistic_probs <- data.frame(
#   "logistic" = probs
# )
# write.csv(logistic_probs,
#           "output\\logistic_probs.csv",
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
                 main = "ROC for Logistic Regression Model",
                 xlab = "False Positive Percentage (1 - Specificity)",
                 ylab = "True Positive Percentage (Sensitivity)",
                 legacy.axes = TRUE)
roc_curve # We have an Area under the curve of 95.24%, which is great, meaning
# that this is a nice model, and we are able to correctly predict the
# gender of the student based on their test grades 95.24% of the time! In this
# sythetic data, there appears to be a discernible difference between genders
# and their test scores.




#########################################
# Meta Content - Where to go from here? #
#########################################

# At this point, the reader may choose to move horizontally to another one
# of the models by viewing files 1a - 1b, 1d - 1i or see how all the models work
# together to make a potentially better model in 1j, the ensemble model.