# This is a branch or continuation of the Exploratory Data Analysis of the 
# StudentsPerformance.csv data. It is a possible and natural last step after
# considering all of the solo models. You may begin here, but all visualizations
# of the data will be absent. For a fuller view of this data, view the file below:




###############################################
# Reading in the data in the format last seen #
###############################################

# First need to format it as we did in the previous example.
library(readr) # to import the data
studPerf <- read_csv("data/StudentsPerformance.csv")

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




#######################################################################
# Complex Ensemble Using 10-Fold Cross Validation and Democratic Vote #
#######################################################################

library(class) # for KNN algorithm
library(rpart) # Used for building classification and regression trees
# logistic regression is native to R
library(randomForest) # For Random Forest algorithm
library(e1071) # for Naive Bayes and SVM
library(MASS) # needed for LDA and QDA
library(neuralnet) # needed for Neural Net model

# Here, we'll take it a step further. We'll rebuild the models from the ground
# up by doing 10-Fold Cross Validation, which will result in each model having
# 1000 predictions, rather than 200. We'll compare the results of these models
# again, and the majority vote will be the new classification.

# A popular metric for comparing different models is the Accuracy. It simply
# measures the percentage of correct predictions that a machine learning model
# has made. Accuracy is a bad metric in the case of imbalanced data, but here
# we have a similar amount of boys and girls (response variables), so we'll
# use it as it is easiest to interpret.





################################################
# Partition the Data into Training and Testing #
################################################

# For reproducibility, this allows the upcoming randomly generated numbers to
# be locked in when re-running this demonstration.
set.seed(6)

library(caret) # for Cross Validation, creating folds, and Confusion Matrix.

# Create the Folds
folds <- createFolds(y = 1:dim(studPerf)[1], k = 10) # needs the obs rows and how many folds
# folds # Ten randomly generated splits of the data, with no replacement/repeats.




#######################
# Creating the Models #
#######################

# We're going to want to find the AUC of all of these models, so let's bring
# in that functionality with the MLmetrics package.
library(MLmetrics)



# K-NEAREST NEIGHBORS
# Knn is a lazy classifier. It doesn't creates a fit to predict later, as in
# case of other classifiers like logistic regression, tree based algorithms
# etc. It fits and evaluates at the same time. When you are done with tuning
# of performance parameters, feed the optimized parameters to knn along with
# new test cases.

accuracy_knn <- list()
#confusion_knn <- list()
preds_knn <- list()
observed <- list()

for(i in 1:10) {  # for each fold, do the following...

  # Note that in KNN, the data needs to be normalized first, so the function below
  # includes an additional few lines that normalize the original data for this
  # specific algorithm.
  norm <- function(x) {(x-min(x))/(max(x)-min(x))} # normalizing function
  studPerf_norm <- as.data.frame(lapply(studPerf[, 6:8], norm))
  studPerf_norm <- cbind(studPerf_norm, Classification = studPerf$gender) # dataframe now normalized
  
  
  # create the training and test set
  train <- setdiff(1:nrow(studPerf), folds[[i]]) # see folds[[1]] to understand
  test <- folds[[i]] # the test data is going to be the fold left out
  

  # Create the model (for knn this is the same as creating the preds too)
  mod <- knn(train = studPerf_norm[train, 1:3],
             test = studPerf_norm[test, 1:3],
             cl = studPerf_norm[train, 4], # this is "classification", not "cluster"
             k = 3) # here is the model, using 3 nearest neighbors
  
  preds_class <- mod # the mod output is literally the predictions
  preds_knn[[i]] <- preds_class
  
  accuracy_knn[[i]] <- Accuracy(y_pred = preds_class,
                                y_true = studPerf[test, ]$gender)# store those results in the previously created list
  
  # confusion_knn[[1]] <- confusionMatrix(preds_class, studPerf[test, ]$gender)
  
  
  
  # This line is not part of the KNN model. It's here to make sure that the
  # real observations exist in a list of 1000 in the SAME ORDER as the
  # predictions are for all the models. This is just here for the "OBS" column
  # in the final dataframe that will compare all the models in the ensemble.
  observed[[i]] <- studPerf[test, ]$gender
}

# Here are the predictions on all 1000 observations using the KNN method.
#preds_knn

# Here are the accuracies of the 10 KNN models. This wont be shown like this
# until later, but it's a good idea to know what's going on here.
#accuracy_knn







# SIMPLE CLASSIFICATION TREE
accuracy_ctree <- list()
preds_ctree <- list()

for(i in 1:10) {  # for each fold, do the following
  train <- setdiff(1:nrow(studPerf), folds[[i]]) # see folds[[1]] to understand
  test <- folds[[i]] # the test data is going to be the fold left out
  
  mod <- rpart(gender ~ mathScore + readingScore + writingScore,
               data = studPerf[train,]) # here is the model
  probs <- predict(mod, studPerf[test,], type = 'prob')[,2] # only interested in the prob of male
  
  preds_class <- list()
  for(j in 1:length(probs)){
    if(probs[j] > .5){
      preds_class[[j]] <- "male"
    } else {
      preds_class[[j]] <- "female"
    }
  }
  
  preds_class <- factor(unlist(preds_class))
  preds_ctree[[i]] <- preds_class
  
  accuracy_ctree[[i]] <- Accuracy(y_pred = preds_class,
                                  y_true = studPerf[test, ]$gender)
}







# LOGISTIC REGRESSION
accuracy_logistic <- list()
preds_logistic <- list()

for(i in 1:10) {
  train <- setdiff(1:nrow(studPerf), folds[[i]])
  test <- folds[[i]]
  
  mod <- glm(gender ~ mathScore + readingScore + writingScore,
             data = studPerf[train,], family = "binomial")
  probs <- predict(mod, studPerf[test,], type = "response")
  
  preds_class <- list()
  for(j in 1:length(probs)){
    if(probs[j] > .5){
      preds_class[[j]] <- "male"
    } else {
      preds_class[[j]] <- "female"
    }
  }
  
  preds_class <- factor(unlist(preds_class))
  preds_logistic[[i]] <- preds_class
  
  accuracy_logistic[[i]] <- Accuracy(y_pred = preds_class,
                                     y_true = studPerf[test, ]$gender)
}





# RANDOM FOREST
accuracy_rForest <- list()
preds_rForest <- list()

for(i in 1:10) {
  train <- setdiff(1:nrow(studPerf), folds[[i]])
  test <- folds[[i]]
  
  mod <- randomForest(gender ~ mathScore + readingScore + writingScore,
                      data = studPerf[train,])
  probs <- predict(mod, studPerf[test,], type = 'prob')[,2]
  
  preds_class <- list()
  for(j in 1:length(probs)){
    if(probs[j] > .5){
      preds_class[[j]] <- "male"
    } else {
      preds_class[[j]] <- "female"
    }
  }
  
  preds_class <- factor(unlist(preds_class))
  preds_rForest[[i]] <- preds_class

  accuracy_rForest[[i]] <- Accuracy(y_pred = preds_class,
                                    y_true = studPerf[test, ]$gender)
}





# NAIVE BAYES
accuracy_nBayes <- list()
preds_nBayes <- list()

for(i in 1:10) {
  train <- setdiff(1:nrow(studPerf), folds[[i]])
  test <- folds[[i]]
  
  mod <- naiveBayes(gender ~ mathScore + readingScore + writingScore,
                    data = studPerf[train,])
  probs <- predict(mod, studPerf[test,], type = 'raw')[,2]
  
  preds_class <- list()
  for(j in 1:length(probs)){
    if(probs[j] > .5){
      preds_class[[j]] <- "male"
    } else {
      preds_class[[j]] <- "female"
    }
  }
  
  preds_class <- factor(unlist(preds_class))
  preds_nBayes[[i]] <- preds_class
  
  accuracy_nBayes[[i]] <- Accuracy(y_pred = preds_class,
                                   y_true = studPerf[test, ]$gender)
}





# SUPPORT VECTOR MACHINE
accuracy_svm <- list()
preds_svm <- list()

for(i in 1:10) {
  train <- setdiff(1:nrow(studPerf), folds[[i]])
  test <- folds[[i]]
  
  mod <- svm(gender ~ mathScore + readingScore + writingScore,
             data = studPerf[train,],
             kernel = "radial",
             cost = 10,
             type = "C")
  
  preds_class <- predict(mod, studPerf[test,])
  preds_svm[[i]] <- preds_class
  
  accuracy_svm[[i]] <- Accuracy(y_pred = preds_class,
                                y_true = studPerf[test, ]$gender)
}





# LINEAR DISCRIMINANT ANALYSIS
# LDA, like KNN, needs the data to be standardized (centered and scaled), so
# we'll be using that code again below.

accuracy_lda <- list()
preds_lda <- list()

for(i in 1:10) {
  norm <- function(x) {(x-min(x))/(max(x)-min(x))}
  studPerf_norm <- as.data.frame(lapply(studPerf[, 6:8], norm))
  studPerf_norm <- cbind(studPerf_norm, "gender" = studPerf$gender)
  
  train <- setdiff(1:nrow(studPerf), folds[[i]])
  test <- folds[[i]]
  
  mod <- lda(gender ~ mathScore + readingScore + writingScore,
             data = studPerf_norm[train,])
  
  preds_class <- predict(mod, studPerf_norm[test,])
  preds_lda[[i]] <- preds_class$class
  
  accuracy_lda[[i]] <- Accuracy(y_pred = preds_class$class,
                                y_true = studPerf[test, ]$gender)
}




# QUADRATIC DISCRIMINANT ANALYSIS
# The same rules will apply here. Predictors need to be scaled.

accuracy_qda <- list()
preds_qda <- list()

for(i in 1:10) {
  norm <- function(x) {(x-min(x))/(max(x)-min(x))}
  studPerf_norm <- as.data.frame(lapply(studPerf[, 6:8], norm))
  studPerf_norm <- cbind(studPerf_norm, "gender" = studPerf$gender)
  
  train <- setdiff(1:nrow(studPerf), folds[[i]])
  test <- folds[[i]]
  
  mod <- qda(gender ~ mathScore + readingScore + writingScore,
             data = studPerf_norm[train,])
  
  preds_class <- predict(mod, studPerf_norm[test,])
  preds_qda[[i]] <- preds_class$class
  
  accuracy_qda[[i]] <- Accuracy(y_pred = preds_class$class,
                                y_true = studPerf[test, ]$gender)
}





# NEURAL NET
accuracy_nnet <- list()
preds_nnet <- list()

for(i in 1:10) {
  norm <- function(x) {(x-min(x))/(max(x)-min(x))}
  studPerf_norm <- as.data.frame(lapply(studPerf[, 6:8], norm))
  studPerf_norm <- cbind(studPerf_norm, "gender" = studPerf$gender)
  
  train <- setdiff(1:nrow(studPerf), folds[[i]])
  test <- folds[[i]]
  
  mod <- neuralnet(gender ~ mathScore + readingScore + writingScore,
                   data = studPerf_norm[train,])
  probs <- predict(mod, studPerf[test,])[,2]
  
  preds_class <- list()
  for(j in 1:length(probs)){
    if(probs[j] > .5){
      preds_class[[j]] <- "male"
    } else {
      preds_class[[j]] <- "female"
    }
  }
  
  preds_class <- factor(unlist(preds_class))
  preds_nnet[[i]] <- preds_class
  
  accuracy_nnet[[i]] <- Accuracy(y_pred = preds_class,
                                 y_true = studPerf[test, ]$gender)
}


#######################################################
# Evaluating the Model using Machine Learning Metrics #
#######################################################

# SVM entries have attributes, we'll strip them off
preds_svm <- unlist(preds_svm)
names(preds_svm) <- NULL

# We'll start by putting the results of these models together in a dataframe.
complex_ensemble <- data.frame(
  "KNN" = unlist(preds_knn),
  "cTree" = unlist(preds_ctree),
  "LogR" = unlist(preds_logistic),
  "RForest" = unlist(preds_rForest),
  "nBayes" = unlist(preds_nBayes),
  "SVM" = preds_svm,
  "LDA" = unlist(preds_lda),
  "QDA" = unlist(preds_qda),
  "NNet" = unlist(preds_nnet)
)




# Borrowing some code from the previous ensemble model...

# Here we'll define a Mode function, which will take the most occurring number
# in a vector.
Mode <- function(x) {
  unique_x <- unique(x)
  return(unique_x[which.max(tabulate(match(x, unique_x)))])
}
# Example : let x <- c(2, 3, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10)
# Then: Mode(x) = '10'


# Now we want find this mode across each row of the table, and each row mode
# will be the majority vote for that observation.

rowModes <- function(x) {
  return(apply(x, 1, Mode))
}

# These are the predictions of the ensemble model (democratic vote for each
# of the students observed, using all 9 models).
rowModes(complex_ensemble)
ensemble_prediction <- rowModes(complex_ensemble)

# We want to add this ensemble prediction and the actual genders to the table
# now, so that we can compare.
complex_ensemble <- cbind(complex_ensemble,
                          "Ensemble" = as.factor(ensemble_prediction),
                          "Observed" = unlist(observed))



# Let's see how the model does
library(caret) # All-in-one Confusion Matrix and list of metrics
confusionMatrix(complex_ensemble$Ensemble, complex_ensemble$Observed)

# Surprisingly, this complex, Cross Validated model has an accuracy of 87%, as
# well as lower scores in every metric except Negative Predictive Value when
# compared to the simpler ensemble model. Sometimes a simpler model is the
# better one!

# However, just out of curiosity, and before we wrap up, let's see how well
# the Cross Validated model ensemble would have behaved without the presence
# of KNN and Naive Bayes, our weaker AUC-generating models. KNN had an AUC less
# than 60%, which was not much better than guessing. Naive Bayes was in the 80
# to 90% range, and was the second lowest, but we need to drop two models so
# we have 7 voting models from the 9, because with 8 we could tie.

complex_en_drop2 <- complex_ensemble[, -c(1, 5, 10, 11)]
ensemble_prediction2 <- rowModes(complex_en_drop2)

# Add the new democratic vote from the remaining 7 models as well as the real
# observations...

complex_en_drop2 <- cbind(complex_en_drop2,
                          "Ensemble" = as.factor(ensemble_prediction2),
                          "Observed" = unlist(observed))

# Drumroll...
confusionMatrix(complex_en_drop2$Ensemble, complex_en_drop2$Observed)



#########################################
# Meta Content - Where to go from here? #
#########################################

# That's the end of the Classification model demonstration. A bit of an anti-
# climax, 