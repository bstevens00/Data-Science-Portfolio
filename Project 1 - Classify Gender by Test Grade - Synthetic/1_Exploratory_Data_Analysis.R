######################
# Pre-Analysis Notes #
######################

# The synthetic data below was acquired on 06/09/2022, for the purpose of
# practicing story telling with data. As my background is in education and
# mathematics, I decided to find data that would help me to practice skills
# I could use to better understand differences between students, to better
# inform my own teaching and help me reach my students more efficiently. Any
# "conclusions" drawn from this data are fictitious, and should be treated as
# such. This project exists for the sole purpose of practicing the art of story-
# telling with data. The data was downloaded from the following website:
# http://roycekimmons.com/tools/generated_data/exams

# The following Exploratory Data Analysis and all branching files associated
# with classification using this data, are all focused on exploring a simple,
# yet potentially sensitive question, "Can knowing a student's math, reading,
# and writings scores reasonably inform you of their gender?" Or, stated
# another way, "Can we classify students as girl or boy based solely upon their
# scores with any reasonable/useful level of  accuracy?"

# With that said, let's try to classify the gender of some made-up students.

#############################
# Exploratory Data Analysis #
#############################

# import the data
library(readr)
studPerf <- read_csv("https://raw.githubusercontent.com/bstevens00/Data-Science-Portfolio/main/data/StudentsPerformance.csv")

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





######################
# Data Visualization #
######################

## Let's see what the data looks like

# Create tables for the bar plots upcoming.
t1 <- table(studPerf$gender)
t2 <- table(studPerf$`race/ethnicity`)
t3 <- table(studPerf$`parental level of education`)
t4 <- table(studPerf$lunch)
t5 <- table(studPerf$`test preparation course`)


# Visualizing the data, 5 bar plots of discrete data, 3 histograms of numeric.
par(mfrow=c(nrows = 2, ncols = 4))
barplot(t1, main = "Total of Each Gender") # a very close to even spread of both genders were studied
barplot(t2, main = "Students of Specific Ethnicity") # There are many more group C kids than group A
barplot(t3, main = "Highest Parental Education") # The most common outcome is "Some college"
barplot(t4, main = "Lunch Payment Method") # Less students qualified for free/reduced than standard in this
barplot(t5, main = "Practice For Exam") # The sample included a solid amount of both completers and non-
# Histograms of the numeric data
h1 <- hist(studPerf$`math score`, main = "Student Math Scores", xlab = NULL) # the math scores are left skewed
h2 <- hist(studPerf$`reading score`, main = "Student Reading Scores", xlab = NULL) # so are the reading
h3 <- hist(studPerf$`writing score`, main = "Student Writing Scores", xlab = NULL) # and the writing



# Let's check for correlation between the numeric values (Test scores)
cor(studPerf[, 6:8]) # There appears to be an almost perfect correlation
# between reading and writing scores. All three scores are honestly related,
# which stands to reason, as stong academic perfomance in one class usually
# correlates with others.
plot(studPerf[, 6:8]) # Visually, they appear highly correlated as well.


# creating some box plots to compare using caret() package
library(caret) # used for the featurePlot() functionality
featurePlot(x = studPerf[, 6:8],
            y = studPerf$gender,
            plot = "box",
            strip = strip.custom(par.strip.text =  list(cex = .7)),
            scales = list(x = list(relation = "free"),
                          y = list(relation = "free")))

# The same graph can be created, using ggplot2()
library(reshape2) # Reshaping the data so that ggplot2 will play nicely
scores_long <- melt(studPerf[, c(1, 6:8)],
                    value.name = "Scores",
                    variable.name = c("Test Type"))
bps <- ggplot(data = scores_long,
              aes(x = `Test Type`, y = Scores, color = gender)) +
  geom_boxplot()
bps

violins <- ggplot(data = scores_long,
                  aes(x = `Test Type`, y = Scores, fill = gender)) +
  geom_violin()
violins


# And now, let's create the individual density plots of each score by gender
library(ggpubr) # needed for ggarrange(), which is like par(mfrow)

math_dp <- ggplot(data = studPerf, aes(x = `math score`, color = gender, fill = gender)) +
  geom_density(alpha=0.5)
reading_dp <- ggplot(data = studPerf, aes(x = `reading score`, color = gender, fill = gender)) +
  geom_density(alpha=0.5)
writing_dp <- ggplot(data = studPerf, aes(x = `writing score`, color = gender, fill = gender)) +
  geom_density(alpha=0.5)
all_scores_dp <- ggplot(data = scores_long, aes(x = Scores, color = gender, fill = gender)) +
  geom_density(alpha=0.5)


figure <- ggarrange(math_dp, reading_dp, writing_dp, bps,
                    labels = c("", "", "","Comparing Boxplots"),
                    common.legend = TRUE,
                    ncol = 2, nrow = 2)
figure


# Conclusion - based upon initial visualizations, it appears that female
# students have higher overall test scores in reading and writing, and male
# students perform better in math. It may be possible to classify a student's
# gender based solely upon their test scores.

