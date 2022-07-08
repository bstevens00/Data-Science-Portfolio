# Project 2

## The Goals

There are three goals, and three respective files for those goals.

1. Use data visualization and summary statistics to gain unique insight into one of Magic: the Gathering's most played formats, Modern.
	+ filename: 1_Exploratory_Data_Analysis.R
2. Investigate whether some player beliefs about the game are true, such as specific deck Archetypes being more affordable than others. This goal will leverage box plots, Analysis of Variance, and Archetype contrasts using pairwise comparisons.
	+ filename: 2_Differences_in_Archetype_Prices.R
3. Create a price prediction model for the cost of a Magic: the Gathering deck in the Modern format. This involves deploying multiple different machine learning algorithms as well as creating a hybrid/ensemble model, and evaluating the best preditive model using the Root Mean Square Error and R-Squared of on the test data.
	+ filename: 3_Deck_Price_Prediction_Model.R 

## Spoiler - "Please Tell Me the End of the Story"

In the Exploratory data analysis, we learn that Blue and Red cards are the most "splashed" (meaning more decks run *at least one* card of these colors than White, Black, or Green). Black cards are the least splashed. We see that Blue Fetchlands are generally in the more expensive Archetypes, though the data gathered does not offer price breakdown beyond deck name, so it's impossible to tell if Blue Fetchlands being more expensive than their non-Blue counterparts is the sole driver for the price of Archetype expense differences or if its all the cards that aren't Fetchlands that are making the difference. It is likely some combination of the two. This is a further question that would require additional data.

Players are correct about there being a difference between the price of Aggro and Control Archetypes, which is a common claim. However, it's less about there being a difference between Aggro and Control, and more about Aggro just being cheaper than most everything else by a large margin. The only statistically significant differences in prices between Archetypes were Aggro versus Control, Aggro versus Aggro-Control (otherwise known as "Tempo"), and Aggro versus Midrange. Below are boxplots comparing the prices between different Archetypes. We can see it's just cheap to play Aggro, so if you're a player trying to get into the format, that's a good way to start, budget-wise.

![Box Plot Cost by Archetype](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Box_Plot_Cost_by_Archetype.png> "Box Plot Cost by Archetype")

The best price prediction model was the Support Vector Machine (SVM) - not the Ensemble. The SVM had a Root Mean Square Error (RMSE) of 31.85 and an R-Squared (R2) of 0.99, which is incredible. Our cutoffs for acceptable RMSE and R2 scores in a model were RMSE < 131.4 and R2 > 0.6, which SVM satisfied. Overall this was a successful price prediction model. For details on why the RMSE and R2 were chosen, as well as their cutoffs, read the "How to Evaluate the Models" section, close to the end of the README.

## Necessary Magic: the Gathering Terminology and Information for the Reader

There are a few things that the reader will need to understand in order to understand this README.

* "Magic: the Gathering" (MtG) is a collectible, trading card game, with large tournaments in which people compete against one another using unique card strategies.
* A "Deck" is a player's 60 card strategy, and the player uses this deck in 1-on-1 matches to defeat opponents who also have decks of their own unique cards and strategies.
* Some deck strategies are similar *enough* in their goals, such as "stall the game out to win later" (called "Control"), "win as fast as possible" ("Aggro"), or "assemble two different cards that work in combination to win the game instantly" ("Combo") that these strategies fall under an grouping umbrella term, which this project will call "Archetypes".
* There are five "Colors" in the game, White, Blue, Black, Red, and Green ("WUBRG"). Each color has unique mechanisms towards gaining advances in a game, and can be used creatively together to leverage combination strategies. Though unneeded for understanding this analysis, for a more in-depth read on the MtG colors, read [this](https://mtg.fandom.com/wiki/Color) article.
* A deck may only have 4 copies of the same card (unless it's a "Basic Land", but that doesn't matter for this analysis, so just assume it's 4). The 4 card limit will matter when we talk about Fetchlands.
* "Fetchlands" are a specific set of cards that help the player smooth out their resource devopment and play the game more efficiently. There are ten primary lands being refered to when a player says "Fetchlands". Those cards, as well as an additional honorary inclusion are, by name:

1. Arid Mesa
2. Bloodstained Mire
3. Flooded Strand
4. Marsh Flats
5. Misty Rainforest
6. Polluted Delta
7. Scalding Tarn
8. Verdant Catacombs
9. Windswept Heath
10. Wooded Foothills
11. Prismatic Vista (honorary inclusion)

	
## Why these goals? Why do this? Why?

Well, that last question is a little more exestential than I'm prepared to answer, but let's answer those first two questions.

I enjoy Magic: the Gathering. It's my favorite game! And in the years I've played the game, I've absorbed some "conventional wisdoms" from conversations with other players, including beliefs like, "Aggressive decks are cheap to build. I wouldn't want to build a control deck on my budget" and "Gas is cheap and Fetchlands are expensive, that's why I play Burn".

So, I wanted to know. Are Control decks more expensive than Aggro? Can we visualize it? Also, is the difference *statistically significant*, indicating a real difference that is more than anecdotal. Does the popularity of a deck have any significant effect on the price? And, can a deck's price be predicted with any level of accuracy by only knowing the number of each Fetchland present in the deck, the total number of decks submitted of that type in the last year to the database (essentially the popularity of the deck), the colors present in the deck, and the Archetype of the deck?

## Where did this data come from?

Data was collected from www.mtggoldfish.com (MTGG), a popular strategy and data aggregation website for Magic: the Gathering (MTG) on August 6th, 2021 by myself, Brendan Stevens, in the middle of Covid-19 lockdowns, and an immediate need to find something to do.

## Exploratory Data Analysis

### Univariate Analysis
The color that appeared in the most decks overall was Red, followed by Blue. It appears people like their Lightning Bolts and Thought Scours. Black made an appearance in the least amount of the top 60 most played decks. An important detail, however, is a single Red card in the deck would qualify that deck as having Red in it. So this data cannot claim which color is the most commonly played, only that Red and Blue are the two colors most likely to be used "on the splash".

![Most Pervasive Color](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Percent_of_Decks_with_This_Color.png> "Most Pervasive Color")

Below we see which the number of appearances each Archetype has in the top 60 most played decks in the Modern Format. There are many different ways to play midrange. This bar chart doesn't show *how many of each deck*, so it would not be a good visualization for which Archetypes are the most popular, only the most diverse in build options.

![Which Archetypes in Top 60 Decks](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Which_Archetypes_in_Top_60.png> "Which Archetypes in Top 60 Decks")

Now we'll consider Fetchlands. Below is a table showing the prevalence of different Fetchlands in the top 60 most played decks in Modern. In the first row, for example, we see that Bloodstained Mire, a Black/Red Fetchland, is absent from 46 of the top 60 most played decks, zero decks play it as a "1-off", three strategies play two copies of the card, four strategies play it in a set of three, and seven separate strategies out of the 60 most played decks choose to play 4 Bloodstained Mire.

In addition to this, we can see that Windswept Heath is often played in sets of four. Knowing a little trivia, this is likely because it was the only Fetchland from Khans of Tarkir that players could guarantee to get if - rather than purchase a booster pack with random cards - they bought the [Magic Origins: Clash Pack](https://mtg.fandom.com/wiki/Magic_Origins/Clash_pack).

![Fetchlands Count Table](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Fetchland_Counts_Table.PNG> "Fetchlands Count Table")

While it's absolutely worth noting that many of the top decks don't run specific Fetchlands, that fact is misleading. If a deck doesn't run 10/11 of the Fetchlands from above, but still runs 4 of another, that's going to add to the price of the deck. We're interested in the effect a Fetchland has on the price, so let's ignore the "Zero Fetchlands of this Type" column, and visualize the other 4 columns. Especially since that column has numbers that are an order of magnitude higher than the other columns, and would make a bar chart harder to read.

![Fetchlands Count Barchart](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Fetchland_Counts_Barchart.png> "Fetchlands Count Barchart")

As can be seen above, we've broken down the barchart in 3 dimensions. Number of Unique Deck Strategies on the y-axis, Number of Fetchlands on the x-axis, and the colors on the barchart further break down how many decks run each kind of fetchland and in specific allocations.

Interestingly, Most decks that run Fetchlands do so in even multiples, with the most common number of *any* Fetchland in *any* strategy being 4, 2, 3, 1, in that order. Perhaps this is because people tend to like even numbers more than odd?

Next, let's get some overview statistics. Below, we see that for each of the 60 strategies in the database on the MTG Goldfish website, there was an average of 150.72 decks of that type submitted, with a median of 110.5, indicating a right skew, as the popular decks have captured a larger portion of the playerbase's attention and strategy choice. We also see that the minimum number of decks of a particular stategy is 43, so we have a healthy amount of data to work with.

![Big Picture Stats](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Big_Picture_Stats.PNG> "Big Picture Stats")

In addition to this, we see that the mean and median cost of a deck in Modern is ~$900, which gives us a nice number to remember when we're considering the prediction models later. Further and finally, we see that if we were to randomly select a deck from a tournament player, their deck would have an mean of 6.95 and median of 7.00 Fetchlands, indicating that while there are many unique strategies that don't run Fetchlands, the number of players *choosing* those strategies is lower, overall. People are playing decks with Fetchlands.

### Bivariate Analysis

Later, we're going to create a prediction model for the response, Deck Price. However, before doing so, since there are quite a few numeric predictors, we should check the correlation matrix to see if there are any highly correlated variables that might lead to multicollinearity, and if so, perhaps we can collapse these predictors into a subset using something like Principal Component Analysis.

![Correlation Matrix](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Correlation_Matrix.png> "Correlation Matrix")

Here we see lower correlations across the board. For Fetchland-to-Fetchland relationships, a positive correlation means the more of one of the two Fetchlands is played in a strategy, the more the other is as well. We see no high correlations here, but the 0.49 correlation between Misty Rainforest and Prismatic Vista Fetchlands seems suspiciously reasonable, as Landfall strategies are strongest in Green, which both of these Fetchlands search.

More telling, however, is the relationships these predictor variables have with Deck Count. We see that as the number of people playing a strategy goes up, the less likely it is that that strategy plays Misty Rainforest, Flooded Strand, and Scalding Tarn. These are the most expensive Fetchlands, so less people play these strategies, as made clear by the data.

Finally, We see a negative correlation between the number of playing a deck (Deck Count) and the price of playing that deck (Deck Price), further reinforcing the claims from before.

It doesn't appear that there is any real multicollinearity, as none of the results are higher than 0.56, and most are lower than 0.20. Rule of Thumb for Multicollinearity: As a rule of thumb, one might suspect multicollinearity when the correlation between two (predictor) variables is below -0.9 or above +0.9.

### Dimension Reduction

A popular method of reducing the number of predictors to be considered in models or to gain insight into clustering and other bivariate relationships in the data is Principal Component Analysis. [StatQuest](https://www.youtube.com/watch?v=FgakZw6K1QQ) does a fantastic job of explaining this topic.

Since there aren't any signs of multicollinearity (low correlation between the predictors is that sign), Principal Component Analysis may bear no fruit for dimension reduction, as most of the predictors are closer to orthogonal/perpendicular already. But, we can still try, and maybe even provide some insights by finding clusters that tell us more about the our data.

We'll need to scale the values, since Deck Count is orders of magnitude larger than the Fetchland counts.

![Importance of Components](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_PCA.PNG> "Importance of Components")

So what we're seeing above is the importance of the components. Multiple predictor variables combine to make PC1, multiple for PC2, etc. We can see the Proportion of the Variance in the data that is explained by each of these Components. What we want to see is a large first number, close to 0.6 or so, and ideally the first ~3 or so Principal Components accounting for a cumulative proportion of the variance in the high 70% to low 90%. This isn't the case. It looks like dimension reduction using PCA isn't happening.

But we'll visualize this. Before we do that. Here is a picture of a mountain. Not random. I've Googled an image of a moutain and cliffside to help explain what we're looking for with a Scree Plot of the Principal Components.

<img src="https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/Perfect_Scree_Plot_Elbow.jpeg" data-canonical-src="https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/Perfect_Scree_Plot_Elbow.jpeg" width=50% height=50% />

A word on what a "good" Scree Plot looks like. If Principal Component Analysis is useful in the data, then starting on the upper-left corner, the graph will steeply drop like this mountain, hit a *clear* incline change ("Elbow") and then slowly trail off. That "Elbow" is the number of Principal Components we want to keep. Another method for doing this is called the "Kaiser Rule", which states that any Eigenvalue/Variance under 1 should be discarded. This is because an eigenvalue less than 1 means that the PC explains less than a single original variable explained, i.e. it has no dimensional reduction value, as the original variable was better than the new variable. In this picture, we're pretending the horizon is the Eigenvalue of one, or λ = 1.

Now, let's compare a good Scree Plot (mountain above) to our Scree Plot (below).

![Scree Plot](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Scree_Plot.png> "Scree Plot")

It's not the greatest. But we expected that. The best Principal Component cutoff here is the elbow at PC3. And that's not great, because the cumulative proportion of the variance explained by the first three components is only 51.87%.

All is not lost, though. Let's plot the variance in the first and second Principal Components. This kind of a plot is known as a "Biplot". And it can sometimes tell us about interesting relationships or clusters in the data.

![Biplot](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Biplot.png> "Biplot")

When two vectors are close, forming a small angle, the two variables they represent are positively correlated. This plot shows 3 distinct clusters affecting the creating/affecting the first two Principal Components. First, the number of Flooded Strand, Polluted Delta, and Scalding Tarn. These are 3 of the 4 Blue lands, the primary color of the Control Archetype. Next, the group with Bloodstained Mire, Arid Mesa, and Marsh Flats. These lands are all Black, Red, and White. These are the colors most associated with Aggro strategies. This is very interesting. Finally, the last group are the Green lands, which is the color most associated with Midrange strategies, which play slower than Aggro, faster than Control, sitting in the middle of the Archetypes, speedwise. It'll be interesting to see if the Midrange decks also sit in the middle, price wise! We may have found a new question. "Does the time it takes for your deck to win the game positively correlate with the price of the deck?"

As a last exercise with the Exploratory Data Analysis, let's visualize the clusters of this biplot.

![Biplot with 95% Confidence Ellipses](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Biplot_95_Confidence_Ellipses.png> "Biplot with 95% Confidence Ellipses")

While a little noisy, this graph confirms the sentiment "Aggro = Red" and "Control = Blue", as we can see the "Aggro" ellipse is clustered around the Red Fetchlands, and the "Control" ellipse around the 3 Blue Fetchlands in the Southwest corner of the graph. Actually, part of the Control ellipse contains the Misty Rainforest and Prismatic Vista vectors, which also happen to be the only other 2 lands in the picture than help the player in their endeavors to produce Blue mana!

So, while we won't be able to reduce the number of numeric predictors using PCA, it can't be stated that it wasn't without insight.

## Analysis of Variance

### The Assumptions

As we saw in the second bar chart at the beginning of the Exploratory Data Analysis, of the 60 most played decks in Modern, only one of them holds the unique Archetype of "Aggro-Combo". Since there aren't enough examples of this kind of Archetype to work with, we'll drop this deck from our list of 60. Moving forward with 59 unique decks, let's visualize the price to play each Archetype, in general. This would be interesting to know for any new player interested in joining the format, so they might have a general idea of how much they'll need to spend to get through the barrier of entry for their style of play.

Here is a box plot showing the relationship between Archetypes and the Cost of a Deck in that Archtype, with the Control and Aggro strategies colored in yellow, as they're of particular interest to us. Again note that the Aggro-Combo Archetype is missing from this visualization, as it wouldn't have enough different decks to create a distribution (it would literally be a vertical line and look rather odd).

![Box Plot Aggro vs Control](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Box_Plot_Cost_by_Archetype_Control_vs_Aggro.png> "Box Plot Aggro vs Control")

Alternatively, using Density Plots...

![Density Curve Cost by Archetype](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Density_Curve_Cost_by_Archetype.png> "Density Curve Cost by Archetype")

We see above that at least 75% of Aggro decks are priced lower than $600 USD, whereas the top 75% of Control decks are above $900 USD. It's pretty apparent that there's a difference between these Archetype prices. The question is, is it a statistically significant difference. To find out, we'll need to do an Analysis of Variance (ANOVA) after checking the assumptions and then find the Contrasts between the mean price of each the Archetype pairs.

The ANOVA test makes the following assumptions about the data:

1. Independence of the observations. Each subject should belong to only one group. There is no relationship between the observations in each group. Having repeated measures for the same participants is not allowed.
2. No significant outliers in any cell of the design
3. Normality. the data for each design cell should be approximately normally distributed.
4. Homogeneity of variances. The variance of the outcome variable should be equal in every cell of the design.

We'll begin with Assumption 1 and work our way through.

### ANOVA Assumption 1 - Independence of the observations.

This assumption is verifying that none of the data from one observation is affected by another.

None of the data for the decks included were changed or otherwise altered due to the order in which they were entered or anything odd. Each deck was user submitted, and no users were changing their decklists due to other decks in the system or otherwise. Each observation was entirely independent. Also, no deck (observation) belongs to more than one Archetype (subgroup in which we're comparing Contrasts).

### ANOVA Assumption 2 - Check for Outliers in any of the Archetypes

Based on the Boxplot from before, which uses Tukey's Fences to determine whether something is an outlier, we have at least 4 outliers. The question is,
are any of them extreme? That is, are any of them further than 3 times the Interquartile Range away from the middle 50% of the Archetype? If so, we might consider dropping them from the model and noting that we did so.

Below are relevant summary statistics that could have been included in the Exploratory Analysis, but are best left for consideration now. We see the average Control deck is almost twice the price of the average Aggro one. No surprise.

![Additional Summary Statistics](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Additional_Summary_Statistics.PNG> "Additional Summary Statistics")

But we need to keep this in mind while we're checking for outliers. We'll use [Tukey's Fences](https://www.youtube.com/watch?v=zY1WFMAA-ec) to determine the outliers. Below, we see that there are four, Mono-Red Aggro, Mill, Goblins, and Gifts Storm.

![Outliers in Price by Archetype](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Outliers_of_Price_in_Archetypes.PNG> "Outliers in Price by Archetype")

Of the four, three aren't extreme, so we'll ignore them. However, the Goblins deck is an extreme outlier. It's much more expensive than the average Aggro deck at $957 on average.

We could drop it, but we'll keep it. Why? Because that deck is going to increase the average price of Aggro decks in comparison to the other decks, which are all higher than Aggro in price. If, when including a deck that's inflating the price of the Archetype, we still find a statistically significant difference between the cost of Aggro decks and others, then we're certain that Aggro decks are cheaper than the other Archetypes by comparison. Because Aggro can't even compete in price when you let them cheat by including the Goblins deck in its price average!

### ANOVA Assumption 3 - Normality of the Residuals

The normality assumption can be checked by using one of the following two approaches:

1. Analyzing the ANOVA model residuals to check the normality for all groups together. This approach is easier and it’s very handy when you have many
groups or if there are few data points per group.
2. Check normality for each group separately. This approach might be used when you have only a few groups and many data points per group.

Let's do both methods, just to cover our bases.

We'll check the distribution of the Histogram of Residuals.

![Histogram of Anova Residuals](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Histogram_of_Anova_Residuals_Looks_Normal.png> "Histogram of Anova Residuals")

As we see by the overlaid normal curve, in blue, this curve appears normal enough. It's not perfect, but if you squint your left eye and believe with all your heart, it'll do.

In addition to this, we should check the Quantile-Quantile Plot to see if the errors/residuals we observed match what we would have expected, had these errors truly come from a normal distribution.

![QQ Plot](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_QQ_Test_of_Normality_of_Residuals.png> "QQ Plot")

It looks like the residuals line up with what we would have expected.

Another way to check for Normality is the Shapiro-Wilk Test. The Shapiro-Wilk test makes the following hypotheses:
- H0: The null hypothesis is that the data comes from a normal distribution
- H1: The alternative hypothesis is that the data does not come from a normal distribution.

If we get a p-value less than 0.05, we'll reject the null hypothesis.

![Shapiro-Wilk Test](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Shapiro_Wilk_Test_of_Normality.PNG> "Shapiro-Wilk Test")

We fail to reject the null hypothesis. Again, seems normal.

The other way to test normality is to do it in each of the individual Archetypes, instead of across all of them as a whole. We can do this with the same methods as above. Here are the individual Shapiro-Wilk Test results for each of the individual Archetypes.

![Shapiro-Wilk Test by Archetype](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Shapiro_Wilk_Test_of_Normality_by_Archetype.PNG> "Shapiro-Wilk Test by Archetype")

All normal. And here are the individual QQ Plots when we separate the decks by Archetype.

![Individual QQ Plots](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Individual_QQ_Plots.png> "Individual QQ Plots")

We see the same outliers from before in Control and Aggro decks, which we can ignore, but every other value falls inside of the grey 95% Confidence Region, so they're all normal.

### Assumption 4 - Homogeneity of Variance

The Anova model assumes the variance in deck price by archetype is significantly equal to the variance in deck price of the whole group, without archetype consideration. This assumption can be verified by plotting the fitted values against the residuals for the model as well as using Levene's Test.

The plot.

![Homogeneity of the Variance](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Homogeneity_of_Variance.png> "Homogeneity of the Variance")

As we see, each of the vertical lines of dots climbs about as high and descends about as low from the red line (where the residual is zero). This means that the variance is homogenous. It's not perfect, but we're not looking for perfect, we're looking for "close enough".

The other test is Levene's Test.
- H0: The null hypothesis is that the archetype variances are the same as the overall group variances
- H1: The alternative is that there is at least one archetype that has a significantly different variance than the rest of the group.

![Levene's Test](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Levenes_Test_for_ANOVA_Between_Deck_Prices_Results.PNG> "Levene's Test")

Fail to reject. Group variances are overall the same (homogenous).

If you have strong evidence that your data do in fact come from a normal, or nearly normal, distribution, then Bartlett's test has better performance than Levene's Test. I don't know for sure, so just in case, Bartlett's test is below. It has the same null and alternative hypotheses as Levene's Test.

![Bartlett's Test](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Bartletts_Test_for_ANOVA_Between_Deck_Prices_Results.PNG> "Bartlett's Test")

Looks good.

Each of the ANOVA model assumptions have been met, so we may proceed with the Contrasts!

### Analysis of Variance - Searching for Statistically Significant Differences Between Archetypes

Now we can create the model, and look at the Anova Table. The Analysis of Variance too has a Null and Alternative Hypothesis.
- H0: The null hypothesis is that there is no difference between the average prices of decks based on archetype.
- H1: The alternative is that there is a difference between at least two of the archetypes, though we'd need to do further testing to see where those differences lie, even if we intuitively expect that that difference lies between Aggro and Control based upon our preconceived notions and the side-by-side box plot visualization above.

If the p-value is lower than 0.05, we reject the null hypothesis, and we may examine the Contrasts.

![ANOVA Results](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_ANOVA_Between_Deck_Prices_Results.PNG> "Anova Results")

And sure enough, just as we expected, there exists at least one statistically significant difference between Archetypes. Let's go see where those differences lie.

### The Contrasts

The following table shows the Contrasts between the Archetypes. Simply put, we find the average price of a deck in each Archetype, as in the literal mean. After this, we match every mean deck price with the others until every Archetype's mean price has been paired with all the others. Since there are 6 Archetypes, there should be 5+4+3+2+1= 15 Contrasts. Here they are, below.

![Contrasts](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/2_Contrasts.PNG> "Contrasts")

Comparing the average prices of each deck (the contrasts) by their archetype, we can see that only three confidence intervals include zero at a 95% level of confidence. They are Aggro vs Control, Aggro vs (Control-Combo), and Aggro vs Midrange. The 95% level of confidence means that if this data were gathered again, and the same analysis was ran again, a total of ninety-nine more times (a total of 100 times), that we expect 95 of 100 of these confidence intervals to include the true value of the difference in Archetypes being compared.

In other words, there's a 5% chance we're wrong when we say that the price difference between Aggro vs Control, Aggro vs Control-Combo, and Aggro vs Midrange is non-zero. It could be, but it's very likely not. 95% sure.

Basically, Aggro decks are less expensive than Control decks, statistically - not anecdotally - speaking.

We have an answer to Question 2. After viewing the box plots of Archetype vs price, we saw reason to consider there to be differences between the average prices of each deck based upon Archetype. After creating the contrasts, it's not really that Control decks are more expensive than Aggro decks, it's that *everything* is more expensive than Aggro decks.

Aggro players after reading this with their smug nono-Aggro-playing friends:

![Archetype Meme](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/archetype_meme.jpg> "Archetype Meme")

## The Prediction Model - How Much for a Modern Deck?!

### The Final Goal

We're going to try and create a price prediction model for a deck in the Modern Magic: the Gathering format.

### The Predictors - What We Assume to be Useful

Note that we've previously checked the correlation between the continuous predictors using a Pearson's Correlation Coefficient in the EDA for each pairwise comparison, and there were no signs of multicollinearity. There was, however, signs of some predictors having strong correlation with the Price of a Deck.

The following variables will be considered for price prediction:

1. What is the Archetype? We already have evidence of statistically significant differences between Aggro prices and other decks from our Analysis of Variance and interpretation of subsequent Contrasts.
2. Which and how many Fetchlands does the deck run? During the Principal Component Analysis, there were three distinct Fetchland clusters affecting the variation in deck prices:
	+ The Blue Fetchland cluster
	+ Green lands
	+ Mardu lands (Red, White, and Black)
3. What colors are played in the deck? This question is based off of informed speculation, as anecdotal experience has led me to believe that certain colors are more expensive to play overall (Blue and Black > Green > White and Red in price).
4. How many decks of each strategy are reported? We saw that the deck count was negatively correlated with the price when doing the correlation analysis in the EDA, and it would both make sense that more people playing a deck indicates that its cheaper to buy into, but contradictingly more people playing a deck would increase demand of those cards. So an interesting include to the model!

### Variable Selection - Yes, but which of the predictors is actually worth including?

Let's consider a Variable Importance screening mechanism. Many algorithms do this, but we'll use 10-Fold Cross Validation to get a feel for the "right" predictors. Below is a visualization of that result.

![Variable Importance](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/3_variable_importance.png> "Variable Importance")

As we can see above, there's a clear importance in the Archetype feature, as 4 of the top 6 features are levels from that feature out of 22 possible features from which to select. Another trend is there 3 distinct groups of importance. The first is whether the Archetype is Control Combo. The next in importance is the Archetype is whether the deck plays Blue (Floode Strand, Misty Rainforest, Scalding Tarn). Finally, It appears that the presence of Black in a deck is important for predicting price. The last group are the mediocre predictors or worse, which is everything from Arid Mesa down.

### Training and Test Data

We will split the data into a classic 80/20 split, with training holding most of the data. For a deeper, more robust analysis, Cross Validation could be applied to increase predictive power and stability of the model.

### The Models

There are many different machine learning algorithms applicable to our situation. We need a supervised, regession (numeric reponse) model. The following models will be considered. Since we have a nominal predictor with more than two levels, we're not going to use k-NN or Neural Nets. But, we can still use the following models:

1. Multiple Linear Regression
	+ This includes the many methods for model selection, such as Forward, Backward, and Exhaustive model searches, which utilize the R-Squared, Adjusted R-Squared, Mallow's Cp, and AIC metrics for determining best fit.
2. Ridge Regression
3. Lasso Regression
4. Elastic Net (Ridge and Lasso Combined)
5. Simple Regression Tree (Pruned)
6. Random Forest
7. Support Vector Machine
8. Ensemble Model (An attempt at a stronger model that combines the strengths of the others)

### How to Evaluate the Models

This is a prediction problem, so we're interested in how the model behaves on the testing data, not the training. The first is the domain of predictive analytics and the second of explanatory modeling. We want the second.

Unlike Classification problems, there is no equivalent to a confusion matrix. When doing explanatory modeling, a popular method for testing model fit is the R-Squared, which ranges from 0-1. This has a different meaning when applied to the test data.

R-Squared Rule of Thumb for test data: High R2 is > 0.6. This ensures the model fits the data relatively well. You expect some loss in R-Squared when moving from the training to the test data.

We will also consider the Root Mean Squared Error (RMSE), which has gained popularity as the de facto score with which predictive/regression models are measured against one another.

RMSE assumes that error are unbiased and follow a normal distribution. Here are the key points to consider on RMSE:

1. The power of 'square root'  empowers this metric to show large number deviations.
2. The 'squared' nature of this metric helps to deliver more robust results which prevents cancelling the positive and negative error values. In other words, this metric aptly displays the plausible magnitude of error term.
3. It avoids the use of absolute error values which is highly undesirable in mathematical calculations.
4. When we have more samples, reconstructing the error distribution using RMSE is considered to be more reliable.
5. RMSE is highly affected by outlier values. Hence, make sure you've removed outliers from your data set prior to using this metric.
6. As compared to mean absolute error, RMSE gives higher weightage and punishes large errors.

The Root Mean Square Error is similar to the Standard Deviation. But instead of being calculated with respect to a single mean with a bunch of points dispersed around it, the RMSE is using the prediction line as the mean, and slowly moving along it and seeing how far the values are off of it on average.

RMSE Rule of Thumb for test data: Lower the better. The test set RMSE should be less than 10% of the range in the numeric response variable.

### The Results - JUST TELL ME ALREADY!

Below are the RMSE and R-Squared results of the models. Remember, the lower, the better.

![RMSE and R-Squared Results](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/3_rmse_r2_results.PNG> "RMSE and R-Squared Results")

Wow. It's clear that SVM is the best single model. It has the lowerst RMSE and the highest R-Squared by a mile. In addtion to this, when we create an Ensemble, we want to mix the best models together to get a stronger performance. None of the models come close to SVM, so that's not going to be much use in terms of predictive power.

Here are the price predictions for the 12 hold out test decks. Note how much closer SVM is than the Ensemble model, which averages the prediction prices of the three best models for each observation.

![Top 3 Model Predictions](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/3_top_3_model_preds.PNG> "Top 3 Model Predictions")

Using this SVM as our "best model", we can predict the price of a random deck from our orignal data to illustrate the effectiveness of the winning model.

The Support Vector Machine model predicts that the cost of deck 26, "Hardened Scales", will be 492.75 USD, when in reality, the deck averages a price of 526 USD. This prediction is only off by about 35 USD. That's incredible, considering the price of decks in for format range from 262 to 1576 USD.


![](<> "")
