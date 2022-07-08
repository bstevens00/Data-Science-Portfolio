# Project 1

## The Goal

Determine if the gender of a student can be predicted based upon their test grades in math, reading, and writing.

As my background is in education, I was interested in finding data to help me practice classification and data visualization skills
through the lens of an insightful question to better inform my teaching, and help me reach my students more efficiently.

One of the most widely taught concepts in pedagogy is the "3 Types of Learners" - Auditory, Visual, and Kinesthetic. That is, students who learn best by listening, watching, or doing "hands-on", respectively. While all students are individually different, and learn in their own nuanced and individual way, there are non-trivial ways to group students into "like"-learners. One claim I heard years ago was "boys are better at math and girls at reading". While I've personal taught my fair share of anecdotals that don't fit this hot take, I thought it would be fun to see if I could find some data and gather some insight myself. 

Considering the possibly inflamitory subject matter, a disclaimer is in order. It is my understanding that the data used in this project was *resampled* from *real* student data. So, while the data used *resembles* real student test data (relatively similar summary statistics, including means, medians, ranges, and standard deviations for the student test score distributions), the data used here remains, itself, synthetic. Synthetic adjacent. My using this data was intentional, as I wanted to get the feel of *real* student data, but didn't have the right or the want to publish real student data here. As such, and again due to the possibly inflamatory nature of a question that might be unfortunately boiled down by some parties as being "sexist", "conclusions" drawn from this data are ficticious, and should - at most - be used as springboards into motivating further questions by myself and the reader, and not as ultimate "truths". This project exists for the sole purpose of practicing the art of story-telling with data.

## Where the Data was Obtained

The synthetic data was downloaded from the following website: http://roycekimmons.com/tools/generated_data/exams on June 9th, 2022, for the purpose of practicing story telling with data.

## Spoiler - "Please Tell Me the End of the Story"

Yes. We can predict/classify the gender of a student knowing only their math, reading, and writing scores. According to the criterion from Hosmer & Lemeshow (2013) in Applied logistic regression, p.177:

"So, what area under the ROC curve describes good discrimination? Unfortunately there is no "magic" number, only general guidelines. In general... use the following rule of thumb:

* 0.5 = This suggests no discrimination, so we might as well flip a coin.
* 0.5-0.7 = We consider this poor discrimination, not much better than a coin toss.
* 0.7-0.8 = Acceptable discrimination
* 0.8-0.9= Excellent discrimination
* \>0.9 = Outstanding discrimination"

Here are ROC graphs for the nine single models and the simple ensemble model, which combined their individual results together.

![Combined ROC Graphs](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/3_combined_ROC_AUC.png> "Combined ROC Graphs")

Here are the results, interpreted:

* 1 model rated poor, k-NN
* 2 models rated excellent, Simple Classification Tree and Naive Bayes
* 7 models rated outstanding, Logistic Regression, Random Forest, Support Vector Machine, Linear Discriminant Analysis, Quadratic Discriminant Analysis, Neural Net, and the Simple Ensemble

Technically, the Simple Ensemble performs slightly worse than a few individual models in AUC. However, what we lose in AUC (<1%) we trade for model stability, ensuring the variance in performance on future data falls close in line with these "test" data.

We also find that the overall model performs well with Confusion Matrix metrics, such as Sensitivity, Specificity, and Accuracy, which are all scores that range from 0 to 1, and are all stronger when closer to 1.

![Simple Ensemble Confusion Matrix and Metrics](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/3_simple_ensemble_confusion_matrix.PNG> "Simple Ensemble Confusion Matrix and Metrics")

## Navigating this Project

I have included a handy flowchart, "Project_1.drawio.png", to help visualize the path through this project. The rough order of the project goes:

1. Exploratory Data Analysis
	* 1_Exploratory_Data_Analysis.R
2. Individual Model Analyses
	* 2a_k_nearest_neighbors.R
	* 2b_simple_classification_tree.R
	* 2c_logistic_regression.R
	* 2d_random_forest.R
	* 2e_naive_bayes.R
	* 2f_support_vector_machine.R
	* 2g_linear_discriminant_analysis.R
	* 2h_quadratic_discriminant_analysis.R
	* 2i_neural_net.R
3. Simple Ensemble Model
	* 3_simple_ensemble.R
4. Complex Ensemble
	* 4_complex_ensemble.R

![Project 1 Flowchart](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project 1 - Classify Gender by Test Grade - Synthetic/Project_1.drawio.png> "Project 1 Flowchart")

## Methods for Models

In step 1, we find summary statistics and visualize the data, including histograms to check test score normality and box plots to visualize differences between genders on scores on the whole.

In step 2, nine models (2a, 2b... 2i) are individually created to classify the gender. The original data had 1000 observations, so a simple 80/20 split is used, with 800 observations used to train the models and the remaining 200 used to test them. The same splits are used in each model.

In step 3, the results of those 200 observations for each of the nine models from step 2 are tallied, and a majority vote is used to determine a more robust classification. This is done using the mode of each column of the full, combined results table. We literally let every one of the nine models cast a single vote, "male/female" for every one of the 200 test observations, and we take the most voted choice for each observation. 

In step 4, cross validation is deployed to increase model stability, artificially increasing the size of the dataset with which we create the model. Then we do everything else the same, except we have nine models giving 1000 predictions.

## Exploratory Data Analysis

Below we visualize the univariate relationships of the discrete and numeric data. We see that there are a similar number of male and female students, and the data is not sparse. We also see the student scores in math, reading, and writing are relatively normally distributed by test.

![Univariate Visualizations](https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/1_univariate_visualizations.png "Univariate Visualizations")

Next, we see the bivariate correlation between test scores. As is considered old wisdom, students who do well in one topic generally tend to do well in others. That is, a student with a higher math score relative to their peers also maintains higher reading and writing scores. It's also worth noting that reading and writing are visually more correlated, which makes sense, since they're more related to each other on gut instinct.

![Bivariate Correlations](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/1_bivariate_correlations.png> "Bivariate Correlations")

Finally, we start to visualize student scores by test when controlling for gender. Now we really start to see a pattern.

![Test Scores by Gender](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/1_test_scores_by_gender.png> "Test Scores by Gender")

The boys appear to do better on the whole in math and the girls do better in reading and writing.

## Selected Results of the Individual Models

When the first model is created, k-NN, we see unpromising results. A terrible AUC of 55.8% for the model. This model can distinguish between girls and boys 55% of the time. May as well not even have a model, then.

![k-NN ROC](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/2_knn_roc.png> "k-NN ROC")

When we get to the third model, Logistic Regression, things change, however. An AUC of 95.2% is incredible. There might be something here after all!

![Logistic Regression ROC](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/2_logistic_ROC.png> "Logistic Regression ROC")

Eventually, as discussed in the Spoiler section above, we get the full ensemble model, shown here again for convenience.

![Combined ROC Graphs](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/3_combined_ROC_AUC.png> "Combined ROC Graphs")

We settle on using the more robust ensemble, as it has a similar AUC to the highest achieving individual models. However, a few questions remain.

1. Would Cross Validation increase the Confusion Matrix machine learning metrics, such as Sensitivity, Specificity, and Accuracy?
2. Would dropping the less effective individual models from the ensemble model increase classification accuracy?

## Simple Ensemble vs Complex Ensemble (Cross-Validated)

Here are the results of the Confusion Matrices for the Simple and Complex models, as well as a bonus one that answers the second question from above by dropping k-NN and Naive Bayes from the Complex Ensemble Model:

![Ensemble Confusion Matrices](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/Ensemble_Confusion_Matrices.png> "Ensemble Confusion Matrices")

As we can see, the Simple Ensemble Model is the best performing model in almost every category. Despite using Cross Validation, which is often a boon to a model, this time it decreased model efficacy. Sometimes simpler is better!

