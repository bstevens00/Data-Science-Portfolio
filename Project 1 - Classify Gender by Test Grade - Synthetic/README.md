# Project 1

## The Goal

Determine if the gender of a student can be predicted based upon their test grades in math, reading, and writing.

As my background is in education, I found data to help me practice classification and data visualization skills
through the lens of an insightful question to better inform my teaching, and help me reach my students more efficiently.

One of the most widely taught concepts in pedagogy is the "3 Types of Learners" - Auditory, Visual, and Kinesthetic. That is, students who learn best by listening, watching, or doing "hands-on", respectively. While all students are individually different, and learn in their own nuanced and individual way, there are non-trivial ways to group students into "like"-learners. One alleged truth I heard years ago was "boys are better at math and girls at reading". While I've personal taught my fair share of anecdotals that don't appear to fit this claim, I thought it would be fun to see if I could find some data to see if I could gain some insight for myself. 

Considering the possibly inflamitory subject matter, a disclaimer is in order. The data used in this project was resampled from real data. So, while the data used resembles the original data, it is itself synthetic. As such, "conclusions" drawn from this data are ficticious, and should - at most - be used as springboards into motivating further questions by myself and the reader, and not as ultimate "truths". This project exists for the sole purpose of practicing the art of story-telling with data.

The synthetic data was downloaded from the following website: http://roycekimmons.com/tools/generated_data/exams on 06/09/2022, for the purpose of practicing story telling with data.

## Navigating this Project

I have included a handy flowchart, "Project_1.drawio.png", to help visualize the path through this project. The rough order of the project goes:

1. Exploratory Data Analysis
	* 1_Exploratory_Data_Analysis.R
2. Individual Model Analyses
	a. 2a_k_nearest_neighbors.R
	b. 2b_simple_classification_tree.R
	c. 2c_logistic_regression.R
	d. 2d_random_forest.R
	e. 2e_naive_bayes.R
	f. 2f_support_vector_machine.R
	g. 2g_linear_discriminant_analysis.R
	h. 2h_quadratic_discriminant_analysis.R
	i. 2i_neural_net.R
3. Simple Ensemble Model
	* 3_simple_ensemble.R
4. Complex Ensemble
	* 4_complex_ensemble.R

## Methods for Models

In step 1, we find summary statistics and visualize the data, including histograms to check test score normality and box plots to visualize differences between genders on scores on the whole.

In step 2, nine models (2a, 2b... 2i) are individually created to classify the gender. The original data had 1000 observations, so a simple 80/20 split is used, with 800 observations used to train the models and the remaining 200 used to test them. The same splits are used in each model.

In step 3, the results of those 200 observations for each of the nine models from step 2 are tallied, and a majority vote is used to determine a more robust classification.

In step 4, cross validation is deployed to increase model stability, artificially increasing the size of the dataset with which we create the model.

## Results

![Univariate Visualizations](https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%201%20-%20Classify%20Gender%20by%20Test%20Grade%20-%20Synthetic/images/1_univariate_visualizations.png "Univariate Visualizations")
