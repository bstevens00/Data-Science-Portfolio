## Spoiler - The Bottom Line

Using my Ensemble Model created from nine other models, I can correctly predict the gender of a student based on only their math, reading, and writing scores. Using the data available, boys are better at math and girls at reading and writing.

The ensemble model correctly identifies a student as "girl" or "boy" 95% of the time. Seven of the ten simpler models are accurate more than 90% the time. Multiple models have a separability of 95%. From Logistic Regression and Random Forest to Support Vector Machine and a Neural Network, there is no question the data indicate a clear separation along these predictors.

## The Goals

If the gender of a student can be classified based upon their test grades in math, reading, and writing, use this information to help inform other teachers of gender-based weaknesses and strengths to better reach students better as teachers.

## Navigating this Project

The flowchart below is a visualiztion of project. There were nine different machine learning algorithms deployed to solve the problem. An ensemble model was created out of them, and refined.

![Project 1 Flowchart](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project 1 - Classify Gender by Test Grade - Synthetic/Project_1.drawio.png> "Project 1 Flowchart")

## Exploratory Data Analysis - Let's See What the Data Have to Say

Below we visualize the univariate relationships of the discrete and numeric data. We see that there are a similar number of male and female students, and the data is not sparse. We also see the student scores in math, reading, and writing are relatively normally distributed by test.

![Univariate Visualizations](https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/1_univariate_visualizations.png "Univariate Visualizations")

Next, we see the bivariate correlation between test scores. As is considered old wisdom, students who do well in one topic generally tend to do well in others. That is, a student with a higher math score relative to their peers also maintains higher reading and writing scores. It's also worth noting that reading and writing are visually more correlated, which makes sense, since they're more related to each other on gut instinct.

![Bivariate Correlations](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/1_bivariate_correlations.png> "Bivariate Correlations")

Finally, we start to visualize student scores by test when controlling for gender. Now we really start to see a pattern.

![Test Scores by Gender](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/1_test_scores_by_gender.png> "Test Scores by Gender")

The boys appear to do better on the whole in math and the girls do better in reading and writing.

## Selected Results of the Individual Models

The Area Under the ROC Curve (AUC) provides an aggregate measure of performance across all possible classification thresholds. One way of interpreting AUC is the probability that the model ranks a random positive example more highly than a random negative example.

When the first model is created, k-NN, we see unpromising results. A terrible AUC of 55.8% for the model. This model can distinguish between girls and boys 55% of the time. May as well not even have a model, then.

![k-NN ROC](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/2_knn_roc.png> "k-NN ROC")

When we get to the third model, Logistic Regression, things change, however. An AUC of 95.2% is incredible. There might be something here after all!

![Logistic Regression ROC](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/2_logistic_ROC.png> "Logistic Regression ROC")

Eventually, as discussed in the Spoiler section above, we get the full ensemble model, shown here again for convenience.

![Combined ROC Graphs](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/3_combined_ROC_AUC.png> "Combined ROC Graphs")

We settle on using the more robust ensemble, as it has a similar AUC to the highest achieving individual models, but would make up for the complexity with theoretical consistency on truly new data. However, a few questions remain:

1. Would Cross Validation increase the Confusion Matrix machine learning metrics, such as Sensitivity, Specificity, and Accuracy?
2. Would dropping the less effective individual models from the ensemble model increase classification accuracy?

## Simple Ensemble vs Complex Ensemble (Cross-Validated)

Here are the results of the Confusion Matrices for the Simple and Complex models, as well as a bonus one that answers the second question from above by dropping k-NN and Naive Bayes from the Complex Ensemble Model:

![Ensemble Confusion Matrices](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/Ensemble_Confusion_Matrices.png> "Ensemble Confusion Matrices")

As we can see, the Simple Ensemble Model is the best performing model in almost every category. Despite using Cross Validation, which is often a boon to a model, this time it decreased model efficacy. Sometimes simpler is better!

## Where the Data was Obtained

The data was downloaded from the following website: http://roycekimmons.com/tools/generated_data/exams on June 9th, 2022. The data is synthetic, meaning it was created for the purposes of practicing with projects like this.
