library(readr) # to import the data
library(tidyverse) # for tibble() and ggplot2
library(car) # needed for Levene's Test
library(emmeans) # used for finding contrasts between the deck archetypes
library(ggpubr) # needed for ggarrange(), which is like par(mfrow) and ggqqplot
library(rstatix) # identify_outliers() function



#######################
# Data Pre-Processing #
#######################

# Import the data.
mmeta <- read_csv("https://raw.githubusercontent.com/bstevens00/Data-Science-Portfolio/main/data/project_2_modern_meta_8.6.2021.csv")

# Let's convert the Archetype of a deck into a factor for the model.
mmeta$Archetype <- factor(mmeta$Archetype)

# First, let's get the data into a form that can be analyzed by the Anova
# function. Melt the data into long form.
by_archetype <- arrange(mmeta, Archetype) %>%
  dplyr::select(Deck_Name, Archetype, Deck_Price_USD)
# Mass has a function called select, make sure to use the dplyr one here.


#View(by_archetype)
# There is only one Aggro-Combo deck, Hammer Time. We'll drop it. We just don't
# have the representation for these two archetypes to analyze them with box
# plots and an Analysis of Variance.

by_archetype <- filter(by_archetype, Archetype %in% c("Aggro",
                                                      "Aggro-Control",
                                                      "Combo",
                                                      "Control",
                                                      "Control-Combo",
                                                      "Midrange"))





##########################################################
# Attempting to Visualize Differences in Archetype Price #
##########################################################

# Visualize the differences between the deck prices by archetype.

ggplot(data = by_archetype, aes(x = `Deck_Price_USD`,
                                color = Archetype)) +
  geom_density(alpha=0.5,  size = 1) +
  labs(title = "The Cost Barrier to Entry for Each Archetype in Modern in USD") +
  xlab("Deck Price in USD") +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 20),
                     limits = c(200, 1700))

# Box plot
ggplot(data= by_archetype,
       mapping = aes(x = Deck_Price_USD,
                     y = Archetype)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "The Cost Barrier to Entry for Each Archetype in Modern in USD") +
  xlab("Deck Price in USD") +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 20),
                     limits = c(200, 1700))


# Paying special attention to the question of Aggro vs Control price
ggplot(data = by_archetype,
       mapping = aes(x = Deck_Price_USD,
                     y = Archetype,
                     fill = factor(ifelse(Archetype == "Aggro" | Archetype == "Control", "Highlighted", "Normal")))) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "The Cost Barrier to Entry for Each Archetype in Modern in USD",
       subtitle = "Paying special attention to the question of Aggro vs Control price.") +
  xlab("Deck Price in USD") +
  scale_x_continuous(breaks = scales::pretty_breaks(n = 20),
                     limits = c(200, 1700)) +
  scale_fill_manual(values=c("yellow", "grey"))

# scale_x_continuous is giving us more x-axis ticks and changing the x-axis window

# We can see that Aggro decks do appear to be cheaper overall, and
# Control decks have some of the overall highest deck prices. This lines up
# with the player held consensus that control decks are the most expensive
# deck types to play in the format overall. The only reason Midrange is beating
# Control on the range is a specific deck, called "Jund", which comes in
# at around ~1600 USD, depending on your source. In our data, it's $1576.

# Now that we have reason to believe that there might be a difference in the
# prices between the Archetypes, let's check that statistically, using the
# One-Way Analysis of Variance model.



##############################
# Checking Model Assumptions #
##############################

# The ANOVA test makes the following assumptions about the data:

# 1. Independence of the observations. Each subject should belong to only one
# group. There is no relationship between the observations in each group.
# Having repeated measures for the same participants is not allowed.
# 2. No significant outliers in any cell of the design
# 3. Normality. the data for each design cell should be approximately normally
# distributed.
# 4. Homogeneity of variances. The variance of the outcome variable should be
# equal in every cell of the design.


# Before we create an ANOVA model, we need to check if the data conform to
# the assumptions of ANOVA.


# 1. Independence of the observations.
# None of the data for the decks included were changed or otherwise altered due
# to the order in which they were entered or anything odd. Each deck was user
# submitted, and no users were changing their decklists due to other decks in
# the system or otherwise. Each observation was entirely independent. Also, no
# deck (observation) belongs to more than one Archetype (subgroup in which we're
# comparing Contrasts).


# 2. Check for Outliers in any of the Archetypes
# Based on the Boxplot from before, which uses Tukey's Fences to determine
# whether something is an outlier, we have at least 4 outliers. The question is,
# are any of them extreme? That is, are any of them further than 3 times the
# IQR away from the middle 50% of the Archetype? If so, we might consider
# dropping them from the model and noting that we did so.

#-----
# This could have been in the Exploratory Data Analysis, but I just thought to
# include it here for the Boxplot and conversation
by_archetype %>%
  group_by(Archetype) %>%
  get_summary_stats(Deck_Price_USD, type = "mean_sd")
#-----


# Anyway, back to where we were...
by_archetype %>%
  group_by(Archetype) %>%
  identify_outliers(Deck_Price_USD)




# There appear to be 4 outliers. 3 of them aren't extreme, so we'll ignore them.
# However, the Goblins deck is an extreme outlier. It's much more expensive
# than the average Aggro deck at $957 on average.

# We could drop it, but we'll keep it. Why? Because that deck is going to
# increase the average price of Aggro decks in comparison to the other decks,
# which we see as higher in price. If, when including a deck that's inflating
# the price of the Archetype, we still find a statistically significant
# difference between the cost of Aggro decks and others, then we're certain
# that Aggro decks are cheaper than the other Archetypes by comparison. Because
# Aggro can't even compete in price when you let them cheat by including the
# Goblins deck in its price average!

# 3. Normality of the Residuals

# The normality assumption can be checked by using one of the following two
# approaches:

# 1. Analyzing the ANOVA model residuals to check the normality for all groups
# together. This approach is easier and it's very handy when you have many
# groups or if there are few data points per group.
# 2. Check normality for each group separately. This approach might be used
# when you have only a few groups and many data points per group.

# Let's do both methods, just to cover our bases.

mdl <- lm(Deck_Price_USD ~ Archetype, data = by_archetype)
aov_mdl <- aov(mdl)

# Analyszing the ANOVA model residuals for all groups together.
res <- aov_mdl$residuals
hist(res, breaks = 12) # not pretty, but relatively normal
qqnorm(res)
qqline(res) # Definitely looks good here, the residuals follow the theoretical
# values they would, assuming they came from the normal distribution.

res2 <- as.data.frame(res)
# Let's Recreate this in ggplot2, since it looks nice
ggplot(data = res2, mapping = aes(x = res)) +
  geom_histogram(aes(y = ..density..)) +
  labs(title = "Histogram of the ANOVA Residuals",
       subtitle = "Assumption 1 of ANOVA states the residuals should be normally distributed, which they are.") +
  xlab("Residuals") +
  ylab("Frequency") +
  stat_function(fun = dnorm,
                args = list(mean = mean(res2$res),
                            sd = sd(res2$res)),
                col = "blue",
                size = 2)

ggplot(data = res2, mapping = aes(sample = res)) +
  geom_qq() +
  geom_qq_line() +
  labs(title = "QQ Plot for Test of Normality",
       subtitle = "The Observed residuals appear to match up with the Theoretical ones.") +
  xlab("Theoretical Quantiles") +
  ylab("Observed Quantiles")

# Alternatively, the ggqqplot() function in ggpubr can do this too, which has
# the added benefit of 95% confidence intervals around the qqline.
ggqqplot(residuals(aov_mdl)) +
  labs(title = "QQ Plot for Test of Normality",
       subtitle = "The Observed residuals appear to match up with the Theoretical ones.") +
  xlab("Theoretical Quantiles") +
  ylab("Observed Quantiles")



# The Shapiro-Wilk test makes the following hypotheses:
# The null hypothesis is that the data comes from a normal distribution
# The alternative hypothesis is that the data does not come from a normal
# distribution.
shapiro.test(res2$res) # fail to reject, it's normally distributed
# or using the rstatix package
shapiro_test(residuals(aov_mdl))

# Either way, Normality Assumption is good.




# However, let's look at it the other way. Let's check for the normality for
# each group separately.

by_archetype %>%
  group_by(Archetype) %>%
  shapiro_test(Deck_Price_USD)

ggqqplot(by_archetype, "Deck_Price_USD", facet.by = "Archetype")

# Most of the sample data follows the theoretical, but we see 3 outliers in
# Aggro and one in control. We've already discussed these in the previous
# assumption as being something we'll ignore, as they won't affect things
# negatively.

# So that's the second way to test the Normality Assumption, and it seems fine.





# 4. Homogeneity of Variance. The Anova model assumes the variance in deck
# price by archetype is significantly equal to the variance in deck price of
# the whole group, without archetype consideration.

# This assumption can be verified by plotting the fitted values against the
# residuals for the model as well as using Levene's Test.

plot(aov_mdl, 1) # This is the plot, but let's make it nice!
str(aov_mdl)

df_resid_fitted <- data.frame(Residuals = aov_mdl$residuals,
                              Fitted = aov_mdl$fitted.values)

ggplot(data = df_resid_fitted, mapping = aes(x = Fitted, y = Residuals)) +
  geom_point() +
  geom_smooth(method="loess", color="red", se = FALSE) + 
  geom_hline(yintercept = 0, linetype=2, color="darkgrey") +
  xlab("Fitted Values") +
  labs(title = "Plotting the Residuals of the Fitted Values",
       subtitle = "Checking the Vertical Spreads of the dots to see they're similar. If yes, we have homogeneity, if not, heterogeneity. Looks like homogeneity.")

# Wow, the Loess Curve is perfect, and it passes the eye test, there is no
# "coning" or weird change in how much variance there is. Seems fine.

# Levene's Test
# The null hypothesis is that the archetype variances are the same as the
# overall group variances

# The alternative is that there is at least one archetype that has a
# significantly different variance than the rest of the group.

leveneTest(aov_mdl)
# We fail to reject with a p-value of 0.3958. We can assume that the variances
# in deck price at the archetype level are the same as the overall group.

# If you have strong evidence that your data do in fact come from a normal, or
# nearly normal, distribution, then Bartlett's test has better performance than
# Levene's Test. I don't know for sure, so just in case, Bartlett's test:
bartlett.test(Deck_Price_USD ~ Archetype, data = by_archetype)
# Same outcome

# The variances are equal. This was mostly important to check due to the fact
# this was not a controlled experiment in which there were exactly the same
# number of each archetype. If they were the same, we could have skipped this
# assumption in practice, as Anova is robust enough in those cases.

# Either way...
# This data more than adequately meets the assumptions for the Anova model. 




#################
# The Contrasts #
#################

# Now that the 3 Anova assumptions have been considered, let's see if there
# appears to be a price difference between archetypes visually, before even
# doing the anova testing.

# Returning to the anova model create before, this is the result of the
# summary.
summary(aov_mdl)

# The null hypothesis for the Anova model here is that there is no difference
# between the average prices of decks based on archetype.

# The alternative is that there is a difference between at least two of the
# archetypes, though we'd need to do further testing to see where those
# differences lie, even if we intuitively expect that that difference lies
# between Aggro and Control based upon our preconceived notions and the
# side-by-side box plot visualization above.

# Here we see that the observed F statistic between the Mean Squared of the
# Archetypes is more than 5 times greater than that of the Residuals. This
# produces a P-Value that is much less than an alpha = 0.05 threshold. There
# appears to be a statistically significant difference between the average
# prices of at least one pair of Archetypes.


# The question then remains. Where is that difference? And between which
# archetypes? Given our earlier box plot comparison, it's reasonable to assume
# that the difference is between Aggro and something else, considering how
# inexpensive the Aggro decks were, overall. But let's check.

archetype_means <- emmeans(mdl, ~ Archetype) # Archetype is the treatment
# the part of the right of the arrow just calculates the means deck prices
# of each deck Archetype.


# Here we create the contrasts, which is a fancy name for the difference between
# the mean deck prices of one deck archetype and another, or a group of deck
# archetypes and another.
summary(contrast(archetype_means, method="pairwise", adjust="tukey"),
        infer=c(T,T), level=0.95, side="two-sided")

# Comparing the average prices of each deck (the contrasts) by their archetype,
# we can see that only three confidence intervals include zero at a 95% level of
# confidence. They are Aggro vs Control, Aggro vs (Control-Combo), and Aggro vs
# Midrange. The 95% level of confidence means that if this data were gathered
# again, and the same analysis was ran again, a total of ninety-nine more times
# (a total of 100 times), that we expect 95 of 100 of these confidence intervals
# to include the true value of the difference in Archetypes being compared.

# For example, referring to the output above, the estimated difference in price
# between the average Aggro deck and average Control deck is -$512.60. Because
# Aggro is the first one listed in the comparison, this means that the average
# Control deck is estimated to be $512.60 more expensive than the average Aggro
# deck. The confidence interval for this cost differential is (-$886, -$139).
# We expect that if we did this analysis 100 times over, 95 of those times would
# include the true value of the differnece in their price. By saying that the
# true value is in this range, we are accepting that there is a 5% chance that
# we have an interval without the true value. And I can live with that.

# In other words, there's a 5% chance we're wrong when we say that the price
# difference between Aggro vs Control, Aggro vs Control-Combo, and Aggro vs
# Midrange is non-zero. It could be, but it's very likely not. 95% sure.

# Basically, Aggro decks are less expensive than Control decks, statistically -
# not anecdotally - speaking.

# We have an answer to Question 2. After viewing the box plots of Archetype vs
# price, we saw reason to consider there to be differences between the average
# prices of each deck based upon Archetype.  After creating the contrasts, it's
# not really that Control decks are more expensive than Aggro decks, it's that
# *everything* is more expensive than Aggro decks.

