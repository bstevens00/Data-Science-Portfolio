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




##############################
# Classification Model - KNN #
##############################

library(class) # for KNN algorithm

# Here we'll use the K-Nearest Neighbors method to classify the gender of each
# observation. KNN is one of the simplest forms of machine learning algorithms
# mostly used for classification. It is a supervised learning method that
# classifies new observations based on how its "K" nearest neighbors are
# classified, which is funny, because it's almost like being "peer-pressured"
# into joining the bigger group, which is often how the very students being
# observed here behave as young adults! Anyway, note that it is always good
# practice to ensure that K is odd, so that there isn't a tie between
# classifications. Despite the relative simplicity of the algorithm,
# it is remarkably effective.

# K is chosen using many different methods. However. 
# For this demonstration, we'll use the heuristic K = square root of the number
# of observations. In this case, the square root of 1000 is ~31.6, so we'll do
# K = 31 to make sure it's an odd K. There are other methods for deciding K,
# such as cross validation, but we're going to keep it simple here.
our_k <- floor(sqrt(nrow(studPerf)))

# KNN calculates the distance between each newly introduced observation and the
# the closest neighbors. For this reason, any application of KNN requires all
# the predictors be converted into numeric values, so distances are calculable.
# However, here we are only interested in the numeric predictors, as we're
# trying to see if the test scores of a student can be used to predict their
# gender. So, if the scale of the different predictor variables differ by an 
# order of magnitude (one column of numbers is 10 times bigger, for
# example), those predictor variables are going to disproportionally affect a
# Euclidean distance calculation. Therefore, the data should be normalized
# first. Normalization is a scaling technique in which data are shifted
# and rescaled so that they end up with a mean of 0 and a standard deviation of
# 1. In other words, once the data is scaled, the student test scores will have
# 68% of the data fall between -1 and 1 for each predictor. This way the
# algorithm  is comparing "like" or numbers of similar magnitude.

# Note that technically, the 3 numeric predictors are on a similar scale in this
# example, so scaling is not necessary. It is, however, a good habit to do this,
# so we're going to do it.

# Note the test scores before.
View(studPerf)

# Scale them.
studPerf[, 6:8] <- scale(studPerf[, 6:8])

# Note the test scores after.
View(studPerf)




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
data_train <- studPerf[training_index, c(6:8)]
# Testing data
data_test <- studPerf[-training_index, c(6:8)]




######################
# Creating the Model #
######################

# Now for the actual model/predictions
predictions <- knn(train = data_train,
                   test = data_test,
                   cl = train_labels$gender,
                   k = our_k) # here is the model, using 3 nearest neighbors

# Here are the probabilities for these predictions, for use later
probs <- knn(train = data_train,
             test = data_test,
             cl = train_labels$gender,
             k = our_k,
             prob = TRUE) # here is the model, using 3 nearest neighbors

probs <- 1 - attr(probs, "prob") # want prob of boy, so 1 - prob of girl

# Let's see how the predictions stacked up against what was real
real_vs_pred <- data.frame(
  "Math_Score" = data_test$mathScore,
  "Reading_Score" = data_test$readingScore,
  "Writing_Score" = data_test$writingScore,
  "Observed" = test_labels$gender,
  "Prediction" = predictions
)

real_vs_pred # we can for each observation (student), we can now see their
# normalized score alongside their actual and model-predicted gender.




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

# knn_prediction <- data.frame(
#   "Observed" = real_vs_pred$Observed,
#   "KNN" = real_vs_pred$Prediction
# )
# 
# write.csv(knn_prediction,
#           "output\\knn_prediction.csv",
#           row.names = TRUE)
# 
# # We'll also store the probabilities associated with these predictions for
# # evaluating said ensemble model (ij).
# knn_probs <- data.frame(
#   "KNN" = probs
# )
# write.csv(knn_probs,
#           "output\\knn_probs.csv",
#           row.names = TRUE)
#####


# Let's check how effective our model is. To do this, there are a few nice
# packages, "caret" and "MLmetrics". But before we use those, we'll manually
# calculate some of the metrics to show what's going on under the surface.

# Create function to return accuracy measures.
get_class_acc <- function(response, prediction) {
  tp = sum(response == "0" & prediction == "0") # true positives
  fp = sum(response == "1" & prediction == "0") # false positives
  tn = sum(response == "1" & prediction == "1") # true negatives
  fn = sum(response == "0" & prediction == "1") # false negatives
  
  sens = tp / (tp + fn) # Sensitivity, Recall, True Positive Rate
  spec = tn / (fp + tn) # Specificity, True Negative Rate
  prec = tp / (tp + fp) # Precision, Positive Predictive Value
  npv = tn / (tn + fn) # Negative Predictive Value
  f1 = 2 * prec * sens / (prec + sens)
  acc = (tp + tn) / (tp + tn + fp + fn) # accuracy
  ba = (sens + spec) / 2 # balanced accuracy
  return(list(Sens = sens, Spec = spec, Prec = prec, NPV = npv, F1 = f1, Acc = acc, BA = ba))
  # there are a lot of metrics, here are some, caret has more
}

get_class_acc(real_vs_pred$Observed, real_vs_pred$Prediction)

# The closer metrics are to 1, the better. They range from 0 to 1.

# We see that we have some solid metrics across the board, as all of them are
# between 85% and 90%, which is decent and usable.

# Sensitivity refers to the model's ability to classify actual girls correctly
# as girls. 86.72% of the time, the model predicts "female" when the student
# is actually female, but 13.28% of the time, the model predicts "male" when
# the student is actually female.

# Specificity refers to the model's ability to classify actual boys correctly
# as boys. 87.35% of the time, the model predicts "male" when the student
# is actually male, but 12.65% of the time, the model predicts "female" when
# the student is actually male.

# So, let's see how this would look if we'd used the caret and MLmetrics
# packages, which we'll use for the rest of 1b-1j.

# We load them in.
library(caret)
library(MLmetrics)

# we calculate a few of the metrics from our manually function above.
Sensitivity(y_true = unlist(test_labels), y_pred = predictions)
Specificity(unlist(test_labels), predictions)
Precision(unlist(test_labels), predictions)
# Note these are the same outputs as above. Again, we'll use these functions
# in the future, rather than the created function from above.

# confusionMatrix(pred, truth)
confusionMatrix(predictions, unlist(test_labels))




# Another popular method of min-maxing a model for the most optimal cutoff
# probabilities in a classifier is the Receiver Operating Characteristic Curve,
# or "ROC Curve", as well as it's Area Under the Curve or "AUC". The purpose of
# this curve is to find the "sweet spot(s)" where the model gets the best
# Sensitivity and Specificity combined, rather than  sacrificing too much of
# one for little gains of the other.

# We will need the pROC library for this feature.
library(pROC)

# Here is the curve
par(pty = "s") # this just makes the plot of the roc curve square.
roc(response = test_labels$gender,
    predictor = probs,
    levels=c("female", "male"),
    plot = TRUE,
    auc = TRUE,
    legacy.axes = TRUE)

# Or, represented another way if we have an audience not familiar with the
# meaning of Sensitivity and Specificity, we can change these axes to help.
roc(response = test_labels$gender,
    predictor = probs,
    plot = TRUE,
    auc = TRUE,
    percent = TRUE,
    xlab = "False Positive Percentage (1 - Specificity)",
    ylab = "True Positive Percentage (Sensitivity)",
    legacy.axes = TRUE)

# AUC or "Area Under the Curve" is a number that ranges from -1 to 1. The closer
# the number is to -1 or 1, the better the binary classifier, with 1 being
# always correct in prediction, and -1 being always wrong (if you're literally
# always wrong though, the model is actually predicting perfectly the opposite,
# which means it's perfect still.) The closer to 0.50, the worse the classifier,
# because you're saying that you'll be correct on classifying a new observation
# as boy or girl 50% of the time, which is no better than guessing.

# The ROC curve wants to look like a nice rounded hill, and to be as far from
# The midline (read, guess line) as possible. Here, the model is only right 55
# percent of the time with classifying, which is better than guessing (0.50),
# but not by much. This is a bad ROC curve.

# While better than guessing, it looks like we can't reliably classify a student
# as girl or boy based upon their blind test scores using simple KNN. We'll 
# need to try something else. And it could very well lead nowhere, but we can
# still try.
