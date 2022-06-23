#############################################################
# Meta Content - Where Am I in this Data Science Portfolio? #
#############################################################

# This is part 1 of 2 of project "1 - Classify Gender by Test Grade - Synthetic"

# The goal of this project is divided into two parts:

# 1.) Demonstrate Understanding of Exploratory Data Analysis (this file)
# 2.) Demonstrate Understanding of Classification Modeling (not this file)

# To see part 2 of 2 of this project, open the following link and choose one
# of the multiple models that one might use in order to classify new data. It's
# kind of like a "choose your own adventure". However, 1j and 1k are special,
# as they merge 1a through 1i together into one big, ensemble model that uses
# the strengths of all the models combined.

# Link: https://github.com/bstevens00/Data-Science-Portfolio/tree/main/Classification

#        . 1a - KNN - Classify Gender by Test Grade - Synthetic
#        . 1b - Simple Tree - Classify Gender by Test Grade - Synthetic
#        . 1c - Logistic Regression - Classify Gender by Test Grade - Synthetic
#        . 1d - Random Forest - Classify Gender by Test Grade - Synthetic
#        . 1e - Naive Bayes - Classify Gender by Test Grade - Synthetic
#        . 1f - Support Vector Machine - Classify Gender by Test Grade - Synthetic
#        . 1g - Linear Discriminant Analysis - Classify Gender by Test Grade - Synthetic
#        . 1h - Quadratic Discriminant Analysis - Classify Gender by Test Grade - Synthetic
#        . 1i - Neural Net - Classify Gender by Test Grade - Synthetic - Copy

#        . 1j - Democratic Ensemble Model - Classify Gender by Test Grade - Synthetic
#        . 1k - 10 Fold Cross Validated Ensemble Model - Classify Gender by Test Grade - Synthetic


# Note that 1a - 1i are similar to each other, each seeking to classify new
# data using their titled method. The data is split into an 80/20 split, where
# each model is trained on 80% of the data and tested on multiple metrics of
# efficiency at the end of their respective files.

# In the files 1j and 1k the methods become far more sophisticated. 10-fold
# Cross Validation is used for each model in 1k. The data is split 90/10, and
# the 1a KNN model is recreated. Then a different 10 percent is left out and a
# new KNN model is created. This happens 10 times, so there are 10 KNN models
# created using 10 distinct (without replacement) hold-out (test) folds. This
# means every single piece of data has 9 attempts to help create a model and 1
# chance to be predicted.

# Importantly, we'll then have a prediction for every single observation using
# KNN alongside the real value observed (1000 predictions), not just 20% of the
# data (200 predictions). This would already be better than using the KNN model
# alone, but we go a step further. After we do this Cross Validation for KNN,
# building 10 distinct models to create 1000 predictions, we do it again for the
# other models in 1b - 1i. That is, we'll have 1000 predictions for each model
# for a total of 9000 predictions or 9 predictions for every observation. Then,
# we settle things as democratically as possible. Each mode gets a single vote
# for each observation, and each observation is classified based upon the
# majority. So, for example, if student 17 is classified as "Boy" by KNN,
# "Girl" by Simple Tree, "Girl" by Logistic Regression, "Boy" by Random Forest...
# etc. until we see 6 votes for "Boy" and 3 votes for "Girl", we'll classify
# the student as "Boy". Then we run the same metrics as before to check the
# efficiency of the model.


















######################
# Pre-Analysis Notes #
######################

# The synthetic data below was acquired on 06/09/2022, for the purpose of
# practicing story telling with data. As my background is in education and
# mathematics, I decided to find data that would help me to practice skills
# I could use to better understand differences between students, to better 
# inform my own teaching and help me reach my students more efficiently. Any 
# "conclusions" drawn from this data are ficticious, and should be treated as 
# such. This project exists for the sole purpose of practicing the art of story-
# telling with data. The data was downloaded from the following website:
# http://roycekimmons.com/tools/generated_data/exams




# The following Exploratory Data Analysis and all branching files associated
# with classification using this data, are all focused on exploring a simple,
# yet potentially sensitive question, "Can knowing a student's math, reading,
# and writings scores reasonably inform you of their gender?" Or, stated
# another way, "Can we classify students as girl or boy based solely upon their
# scores with any reasonable/useful level of  accuracy?"




# With that said, let's try to classify the gender of some synthetic students.




#############################
# Exploratory Data Analysis #
#############################

# import the data
library(readr)
studPerf <- read_csv("https://raw.githubusercontent.com/bstevens00/Data-Science-Portfolio/main/data/StudentsPerformance.csv")

### Exploratory Data Analysis

## Checking to see how many observations and variables there are
dim(studPerf) # there are 1000 observations and 8 variables

## Getting a quick look at the data
head(studPerf) # First 6 observations
tail(studPerf, 4) # Last 4

## See the entire set of data
View(studPerf)

## Checking the structure of the data
str(studPerf) # some data is character, some numeric

# The categorical data needs to be formatted as factor, not character.
studPerf[, 1:5] <- lapply(studPerf[, 1:5], factor)

## Basic Description of the Data
str(studPerf) # adjusted to Factor

# gender, race, lunch, and test prep are nominal, categorical variables
# parent level of education is an ordinal, categorical variable
# math, reading, and writing scores are all discrete, numeric data
# no attributes/predictors are continuous, numeric data


# Changing the order of the ordinal variable, so smallest education is first,
# and greatest education is last
levels(studPerf$`parental level of education`)
ed_ranked <- c("some high school", "high school",
               "some college", "associate's degree",
               "bachelor's degree", "master's degree")
studPerf$`parental level of education` <- 
  factor(studPerf$`parental level of education`,
         levels = ed_ranked)


## Checking for missing data
sum(is.na(studPerf)) # overall no missing (NA) values
sapply(studPerf, function(x) sum(is.na(x))) # No missing (NA) values

## Checking for sparse data (low amounts of specific observation types)
lapply(studPerf[1:5], function(x) table(x)) # none of the data is sparse (< 5)

## Getting an overall summary of the data
summary(studPerf) # Useful summary stats, including box plot info

# A more advanced summary function can be found in the skimr package
library(skimr) # Expands on the functionality of summary() function

# This clean little function below does a lot of neat statistics for us
skim(studPerf)

# It might be of use to see how this data behaves when broken down by gender
library(tidyverse) # using this for the dplyr group_by functionality
studPerf %>%
  group_by(gender) %>% 
  skim()
# We see here that boys are doing considerably worse than girls in all of
# these categories





##################################
# Exploratory Data Visualization #
##################################

## Let's see what the data looks like, now

# Barplots of the above analysis
t1 <- table(studPerf$gender)
barplot(t1) # a very close to even spread of both genders were studied

t2 <- table(studPerf$`race/ethnicity`)
barplot(t2) # There are many more group C kids than group A

t3 <- table(studPerf$`parental level of education`)
barplot(t3) # The most common outcome is "Some college"

t4 <- table(studPerf$lunch)
barplot(t4) # Less students qualified for free/reduced than standard in this

t5 <- table(studPerf$`test preparation course`)
barplot(t5) # The sample included a solid amount of both completers and non-

# Histograms of the numeric data
hist(studPerf$`math score`) # the math scores are left skewed
hist(studPerf$`reading score`) # so are the reading
hist(studPerf$`writing score`) # and the writing

# Let's check for correlation between the numeric values (Test scores)
cor(studPerf[, 6:8]) # There appears to be an almost perfect correlation
# between reading and writing scores. All three scores are honestly related.
plot(studPerf[, 6:8]) # Visually, they appear highly correlated as well.

# creating some box plots to compare
library(caret) # used for the featurePlot() functionality
featurePlot(x = studPerf[, 6:8],
            y = studPerf$gender,
            plot = "box",
            strip = strip.custom(par.strip.text =  list(cex = .7)),
            scales = list(x = list(relation = "free"),
                          y = list(relation = "free")))

# The same graphs, using ggplot2
library(ggplot2)
ggplot(data = studPerf, aes(x = gender, y = `math score`)) +
  geom_boxplot()

library(reshape2) # Reshaping the data so that ggplot2 will play nicely
scores_long <- melt(studPerf[, c(1, 6:8)],
                    value.name = "Scores",
                    variable.name = c("Test Type"))
ggplot(data = scores_long, aes(x = `Test Type`, y = Scores, color = gender)) +
  geom_boxplot()


# Conclusion - based upon initial visualizations, it appears that female
# students have higher overall test scores in reading and writing, and male
# students perform better in math. It may be possible to classify a student's
# gender based solely upon their test scores.

