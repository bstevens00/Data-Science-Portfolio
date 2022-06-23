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

#######################################################
# Classification Model - Simple and Complex Ensembles #
#######################################################

# An Ensemble model can come in many forms. But at its root, it is a model that
# combines multiple models. How it combines them is in the details, but that's
# the basic idea.

# In models 1a - 1i, we deployed 9 distinct classifier algorithms/models, each
# of which made its own predictions. Here, we will recollect those results,
# combine them into a dataframe/table, and then create a final classifier that
# simply classifies each observation based upon the majority vote of "boy" or
# "girl" for each observation.





##################################################
# Simple Ensemble (Democratic Voting using Mode) #
##################################################

# Lines 61 - 91 show how I originally assembled the predictions from the other
# models/files into one ensemble dataframe. The lines have been commented out,
# as I have included the premade .csv file in the data folder of the github=
# repository. You may skip to line 93.

#####
# # Import the .csv classifications from all the single models
# library(readr)
# knn_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1a - KNN - Classify Gender by Test Grade - Synthetic/output/knn_prediction.csv")
# ctree_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1b - Simple Tree - Classify Gender by Test Grade - Synthetic/output/ctree_prediction.csv")
# logistic_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1c - Logistic Regression - Classify Gender by Test Grade - Synthetic/output/logistic_prediction.csv")
# rforest_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1d - Random Forest - Classify Gender by Test Grade - Synthetic/output/rforest_prediction.csv")
# nBayes_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1e - Naive Bayes - Classify Gender by Test Grade - Synthetic/output/nBayes_prediction.csv")
# SVM_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1f - Support Vector Machine - Classify Gender by Test Grade - Synthetic/output/SVM_prediction.csv")
# LDA_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1g - Linear Discriminant Analysis - Classify Gender by Test Grade - Synthetic/output/LDA_prediction.csv")
# QDA_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1h - Quadratic Discriminant Analysis - Classify Gender by Test Grade - Synthetic/output/QDA_prediction.csv")
# nnet_prediction <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1i - Neural Net - Classify Gender by Test Grade - Synthetic/output/nnet_prediction.csv")
# 
# # create a table of all predictions for the 200 predictions across all 9 models.
# simple_ensemble <- data.frame(
#   "KNN" = knn_prediction$KNN,
#   "cTree" = ctree_prediction$ctree,
#   "LogR" = logistic_prediction$logistic,
#   "RForest" = rforest_prediction$rforest,
#   "nBayes" = nBayes_prediction$nBayes,
#   "SVM" = SVM_prediction$SVM,
#   "LDA" = LDA_prediction$LDA,
#   "QDA" = QDA_prediction$QDA,
#   "NNet" = nnet_prediction$nnet,
#   "Observed" = knn_prediction$Observed
# )
# 
# write.csv(simple_ensemble,
#           "output\\1j_simple_ensemble_preds.csv",
#           row.names = FALSE)
#####

# Here is the dataframe containing all the classifications for each observation
# from each of the single models from 1a-1i.
simple_ensemble <- read_csv("https://raw.githubusercontent.com/bstevens00/Data-Science-Portfolio/main/data/1j_simple_ensemble_preds.csv")
simple_ensemble

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
rowModes(simple_ensemble)
ensemble_prediction <- rowModes(simple_ensemble)

# We want to add this ensemble prediction and the actual genders to the table
# now, so that we can compare.
simple_ensemble <- cbind(simple_ensemble,
                         "Ensemble" = ensemble_prediction)





# As before, skip lines 130-160, they're not needed for the reader.
#####
# In addition to this information, we'll also store the probabilities from each
# of the models, and find their average. We'll use this later for the ROC curve.

# knn_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1a - KNN - Classify Gender by Test Grade - Synthetic/output/knn_probs.csv")
# ctree_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1b - Simple Tree - Classify Gender by Test Grade - Synthetic/output/ctree_probs.csv")
# logistic_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1c - Logistic Regression - Classify Gender by Test Grade - Synthetic/output/logistic_probs.csv")
# rforest_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1d - Random Forest - Classify Gender by Test Grade - Synthetic/output/rforest_probs.csv")
# nBayes_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1e - Naive Bayes - Classify Gender by Test Grade - Synthetic/output/nBayes_probs.csv")
# svm_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1f - Support Vector Machine - Classify Gender by Test Grade - Synthetic/output/svm_probs.csv")
# lda_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1g - Linear Discriminant Analysis - Classify Gender by Test Grade - Synthetic/output/lda_probs.csv")
# qda_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1h - Quadratic Discriminant Analysis - Classify Gender by Test Grade - Synthetic/output/qda_probs.csv")
# nnet_probs <- read_csv("~/Data Science Learning/Data Science Portfolio/Classification/1i - Neural Net - Classify Gender by Test Grade - Synthetic/output/nnet_probs.csv")
# 
# 
# simple_ensemble_probs <- data.frame(
#   "KNN" = knn_probs$KNN,
#   "cTree" = ctree_probs$ctree,
#   "LogR" = logistic_probs$logistic,
#   "RForest" = rforest_probs$rforest,
#   "nBayes" = nBayes_probs$nBayes,
#   "SVM" = svm_probs$SVM,
#   "LDA" = lda_probs$LDA,
#   "QDA" = qda_probs$QDA,
#   "NNet" = nnet_probs$NNet
# )
# 
# write.csv(simple_ensemble_probs,
#           "output\\1j_simple_ensemble_probs.csv",
#           row.names = FALSE)
#####

# Here are the associated probabilities for each of the observations by model.
simple_ensemble_probs <- read_csv("https://raw.githubusercontent.com/bstevens00/Data-Science-Portfolio/main/data/1j_simple_ensemble_probs.csv")

# Here is the average probability of classification for each observation.
rowMeans(simple_ensemble_probs)
ensemble_probabilities <- rowMeans(simple_ensemble_probs)

# We want to add the average probabilities to the table, so we can compare the
# and also use these probablities for the ROC curve and compare the different
# models soon.

simple_ensemble_probs <- cbind(simple_ensemble_probs,
                               "Ensemble" = ensemble_probabilities)
simple_ensemble_probs


##############################################################
# Evaluating the SIMPLE Model using Machine Learning Metrics #
##############################################################

# Let's convert all of the columns to factor (categorical).
simple_ensemble <- lapply(simple_ensemble, factor)

# Let's see how the model does
library(caret) # All-in-one Confusion Matrix and list of metrics
confusionMatrix(simple_ensemble$Ensemble, simple_ensemble$Observed)

# If your Accuracy value is between 70% and 80%, you've got a good model.
# If between 80% and 90%, you have an excellent model.
# If between 90% and 100%, it's a probably a case of overfitting.
# This seems to be a good model! Accuracy = 89%





# Now, let's analyze the sensitivity and specificity tradeoff using a Receiver
# Operating Characteristic curve, or ROC curve, as well as the Area Under the
# Curve, or AUC. The purpose of this curve is to find the "sweet spot(s)" where
# the model gets the best Sensitivity and Specificity combined, rather than 
# sacrificing too much of one for little gains of the other.
library(pROC)

par(pty = "s") # this just makes the plot of the roc curve square.
roc_curve <- roc(response = simple_ensemble$Observed, # the actual scores
                 predictor = ensemble_probabilities, # the associated probs
                 plot = TRUE,
                 auc = TRUE,
                 print.auc = TRUE,
                 percent = TRUE,
                 main = "ROC for Ensemble Model",
                 xlab = "False Positive Percentage (1 - Specificity)",
                 ylab = "True Positive Percentage (Sensitivity)",
                 legacy.axes = TRUE)
roc_curve # An AUC of 94.9% means we can predict the classification 94.9% of
# the time, which is much better than guessing, and indicates a real difference
# between the two genders.




##############################################
# Comparing the ROCs of the Different Models #
##############################################

# Let's see what this ROC curve looks like when compared to all the other ones.

# First up, KNN
roc(response = simple_ensemble$Observed, # the actual scores
    predictor = ensemble_probabilities, # the associated probs
    plot = TRUE,
    auc = TRUE,
    percent = TRUE,
    print.auc = TRUE,
    lwd = 4,
    col = "blue",
    main = "ROC for Ensemble vs KNN",
    xlab = "False Positive Percentage (1 - Specificity)",
    ylab = "True Positive Percentage (Sensitivity)",
    legacy.axes = TRUE)
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$KNN, # KNN probs
         add = TRUE, # add the KNN ROC to the existing ensemble ROC
         percent = 100, # scale it all by 100 as well
         print.auc = TRUE, # print the AUC to the graph
         print.auc.y = 45, # move it down so it doesn't display over prev AUC
         col = "green") 
legend("bottomright",
       legend = c("Ensemble Model", "KNN"),
       col = c("blue", "green"),
       lwd = 4) # Note that without this lwd argument, they lines won't appear


# Now a simple Classifcation Tree
roc(response = simple_ensemble$Observed, # the actual scores
    predictor = ensemble_probabilities, # the associated probs
    plot = TRUE,
    auc = TRUE,
    percent = TRUE,
    print.auc = TRUE,
    lwd = 4,
    col = "blue",
    main = "ROC for Ensemble vs Classification Tree",
    xlab = "False Positive Percentage (1 - Specificity)",
    ylab = "True Positive Percentage (Sensitivity)",
    legacy.axes = TRUE)
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$cTree, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.y = 45,
         col = "aquamarine4") 
legend("bottomright",
       legend = c("Ensemble Model", "Classification Tree"),
       col = c("blue", "aquamarine4"),
       lwd = 4)

# Now, rather than do all of them separately, here they are all on the same
# graph. Note the legend.
par(pty = "s")
roc(response = simple_ensemble$Observed, # the actual scores
    predictor = ensemble_probabilities, # the associated probs
    plot = TRUE,
    auc = TRUE,
    percent = TRUE,
    print.auc = TRUE,
    lwd = 4,
    col = "blue",
    print.auc.x = 22,
    print.auc.y = 80,
    main = "ROC for Ensemble vs Individual Models",
    xlab = "False Positive Percentage (1 - Specificity)",
    ylab = "True Positive Percentage (Sensitivity)",
    legacy.axes = TRUE,)
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$KNN, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 75,
         col = "green")
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$cTree, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 70,
         col = "aquamarine4")
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$LogR, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 65,
         col = "blueviolet") 
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$RForest, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 60,
         col = "brown1") 
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$nBayes, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 55,
         col = "burlywood") 
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$SVM, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 50,
         col = "cadetblue1") 
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$LDA, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 45,
         col = "darkgreen") 
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$QDA, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 40,
         col = "goldenrod1") 
plot.roc(x = simple_ensemble$Observed,
         predictor = simple_ensemble_probs$NNet, 
         add = TRUE, 
         percent = 100,
         print.auc = TRUE,
         print.auc.x = 22,
         print.auc.y = 35,
         col = "darkorange2") 
legend("bottomright",
       legend = c("Ensemble Model",
                  "KNN",
                  "Classification Tree",
                  "Logistic Regression",
                  "Random Forest",
                  "Naive Bayes",
                  "Support Vector Machine",
                  "Linear Discriminant Analysis",
                  "Quadratic Discriminant Analysis",
                  "Neural Net"),
       col = c("blue",
               "green",
               "aquamarine4",
               "blueviolet",
               "brown1",
               "burlywood",
               "cadetblue1",
               "darkgreen",
               "goldenrod1",
               "darkorange2"),
       lwd = 4,
       cex = 0.5)




# The Ensemble Curve in Blue is in a 3-way tie for 2nd place in terms of the
# ROC curve, only beat by Support Vector Machine. Now, if we were to go further
# with this analysis, we could drop the poorly performing models from the
# ensemble. And in fairness, with an AUC of 55.8%, dropping KNN seems like a
# great decision. A case could also be made for dropping the two that have
# AUCs below 90%, Classification Tree and Naive Bayes. That would be a
# reasonable next step. However we will end here, as the goal of this exercise
# was to create an Ensemble model through a simple vote and display those
# results. Those goals have been reached.




# But, one wonders if we can do better using Cross Validation...




#########################################
# Meta Content - Where to go from here? #
#########################################

# At this point, the final file remains. Go to file ik to see how it ends!