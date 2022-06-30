####################
# Library/Packages #
####################

library(readr) # to import the data
library(skimr) # to view the summary statistics in a better way than summary()
library(reshape2) # to reform the data in a way that ggplot2 likes it
library(tidyverse) # for tibble() and ggplot2
library(corrplot) # for nice correlation plot

library(devtools) # needed for install_github() function
#install_github("vqv/ggbiplot") # needed for ggbiplot
library(ggbiplot)



#######################
# Data Pre-Processing #
#######################

# Import the data and take a look.
mmeta <- read_csv("https://raw.githubusercontent.com/bstevens00/Data-Science-Portfolio/main/data/project_2_modern_meta_8.6.2021.csv")
# View(mmeta)

# Quick glance at a few observations and the features of that data
head(mmeta)
tail(mmeta)

# Check the summary of the data, getting a feel for the spread across quartiles.
summary(mmeta)

# Some decks are popular enough to have specific names, such as "Living Death"
# or "Heliod Company". But sometimes there isn't a specific card or combination
# of cards that people associate with a deck. So, sometimes MTGG has to assign
# a name to that deck. For that reason, occasionally, two or more decks are
# clustered as different types, yet given the same name. We don't want two of
# our observations to be the same name. Let's check to see if we have any.
deck_type_tally <- as.data.frame(table(mmeta$Deck_Name))

deck_type_tally # Here are the deck names that appear in the data. There are a
# few deck lists that are given the same name, despite having very different
# lists of cards. Let's fix this.


# Which deck names were repeated by the website?
deck_type_tally$Var1[deck_type_tally$Freq > 1]
# For this data, there are two deck names or observations, "Niv to Light" and
# "Jeskai Control", which are repeated twice each. Looking back at those decks
# on MTGG, the decks were both reasonably named, but were different enough to
# not be clustered. So, I'm going to consider both of the decks unique from each
# other and rename the second most common of the two in both cases. The second
# iteration of "Niv to Light" will be "Niv to Light 2" and the second "Jeskai
# Control" will be "Jeskai Control 2".

# Here we rename the decks.
mmeta[34, 1] <- "Niv to Light 2"
mmeta[59, 1] <- "Jeskai Control 2"

# Finished with this object
rm(deck_type_tally)

# Showing that there are no missing values in any cell in the dataset
sum(is.na(mmeta))


# Generating summary statistics of the data
summary(mmeta)
skim(mmeta) # a personal preference as a better option than base summary()

# There are 60 unique decks names observed. 23 features collected on the data,
# including the name of the deck. Based on the output, 2 of the attributes are
# categorical, and 21 are numeric. This is not the case though. The five
# columns: White, Blue, Black, Red, and Green are dummy variables used to
# indicate the color identity of a deck.

# That is to say, if a deck needs a specific color of mana in order to cast a
# spell, then a 1 is given. However, if a card such as "Manamorphose", which has
# a hybrid Red/Green symbol in its mana cost, is present in the decklist, but
# the deck is entirely playable without access to Green mana, then I have
# assigned a "0" for "No, deck does not play Green cards".

# I have manually entered this information for all decks, as part of my interest
# in this analysis will be to determine the relative popularity or prevalence of
# colors in the format, relative to one another. But, it will also be
# interesting to see if the color of a deck can also help predict the price of
# a deck. A question for which many MTG players already believe they hold
# an answer!

# Switching the colors to categorical (dichotomous/binary) predictors
mmeta[, 2:7] <- lapply(mmeta[, 2:7], FUN = factor)

# checking to see if they've been correctly converted to categorical
str(mmeta)
# They have, as they have the "Factor" classification.


# The number of fetchlands in a deck ranges from 0 to 4, because by the rules, a
# deck may only have up to 4 of the same card in it. The difference between
# having 0 fetchlands and 1 is the same as between having 1 fetchland and 2, so
# this it will be considered a continuous predictor for the model creation in 
# Question 3, file name: 3_differences_in_archetype_prices.R.

# The histograms given in the skim() function for the data are not useful for
# the categorical data. We'll use bar charts for those in the Exploratory Data
# Analysis section after this one.

# The most played deck had 560 decks submitted. The least played deck that was
# included in this manual extraction of data had 43 decks submitted.





######################################################
# Step 3: Visualization in Exploratory Data Analysis #
######################################################

# It would be interesting to see which colors were the most popular. As this
# is a generally competitive format, popularity of a color could be an
# indirect measure of relative power of each color in Modern. Let's create a
# Bar chart to show the proportion of decks in the format for which at least
# one card of each color is present.

# Need to reshape the data into long form
by_color <- reshape2::melt(data = mmeta[, c(1, 3:7)],
                           id.vars = "Deck_Name",
                           variable.name = "Color",
                           value.name = "Is_Present")

# Here is the frequency/contingency table showing how many decks do and don't
# run each color. We're only interested in the first column, as those that don't
# are implicitly contained in that statistic.
table(by_color$Color, by_color$Is_Present)/60

rm(by_color) # finished with this object

# Creating a new dataframe with this data
deck_proportions <- tribble(
  ~Color, ~Percent_of_Decks,
  "White", 48.33,
  "Blue", 55.00,
  "Black", 38.33,
  "Red", 60.00,
  "Green", 48.33
)

# ggplot2's default is to display categorical variables in alphabetical order,
# In MTG, the color order is WUBRG, or White, Blue, Black, Red, Green. This is
# how Magic players would expect this information displayed. So let's reorder
# the levels of this dataframe to meet this expectation.
deck_proportions$Color <- factor(deck_proportions$Color,
                                 levels = c("White",
                                            "Blue",
                                            "Black",
                                            "Red",
                                            "Green"))

# Plotting the data, and making sure all the bars are the proper color.
ggplot(data = deck_proportions,
       mapping = aes(x = Color,
                     y = Percent_of_Decks,
                     fill = Color,
                     color = Color)) +
  geom_bar(stat = "identity") +
  scale_fill_manual("Color", values = c("White" = "White",
                                        "Blue" = "Blue",
                                        "Black" = "Black",
                                        "Red" = "Red",
                                        "Green" = "Dark Green")) +
  scale_color_manual("Color", values = c("White" = "Black",
                                         "Blue" = "Black",
                                         "Black" = "Black",
                                         "Red" = "Black",
                                         "Green" = "Black")) +
  labs(title = "Percent of Decks in Meta with at Least One Card of this Color",
       subtitle = str_wrap('"At least one" means a card has the mana symbol in its mana value. For the Top 60 Most Submitted Decklists', 68)) +
  xlab("Color") +
  ylab("Percent of Decks with at Least One Card of Titled Color") +
  theme(legend.position = "none")

rm(deck_proportions) # finished with this object

# We've answered Question 1.
# As can be seen here, Blue and Red spells make their way into more decks than
# White, Black, or Green spells.

# It is important to state, however, that this in no way makes a distinction
# between a deck running a single Blue card or many. A more in-depth analysis
# of the meta would also calculate how many total cards of each color are played
# in each deck on average.

# This graph only shows that decks run Blue and Red "on the splash" or "as a
# support color" more than the other colors, at the very least.


#--
# How many decks of each archetype are there?
#--

# Let's tabulate how many of each archetype are present
table(mmeta$Archetype)
# Looks like we have only 1 "Aggro-Combo" deck and 2 "Control-Aggro" decks.
# Let's make a barchart of this, so it's easier to see.
archetype_frequency <- as.data.frame(table(mmeta$Archetype))
colnames(archetype_frequency) <- c("Archetype", "Frequency")

ggplot(data = archetype_frequency, mapping = aes(x = Archetype,
                                                 y = Frequency)) +
  geom_bar(stat = "identity") +
  labs(title = "Into Which Archtypes Do the Top 60 Most Played Decks Fit?")

# This will be important to note later, when doing an Analysis of Variance 
# or other method between the different archetypes and their effects on the
# price of a deck is being analyzed. We don't have enough "Aggro-Combo" decks
# to work with to do an ANOVA test.

# At that point, we'll leave these two archetypes out of that analysis, as they
# only make up a small amount of decks a player might play. Alternatively,
# an option could be to collapse these two archetypes into other archetypes.
# But that feels disingenuous, as I know that there is a distinct difference
# between these archetypes and all the others.


#--
# How about the Fetchlands?
#--

# Need to reshape the data into long form
by_fetchland <- reshape2::melt(data = mmeta[, c(1, 11:21)],
                           id.vars = "Deck_Name",
                           variable.name = "Fetchland",
                           value.name = "Total")

# Here is the frequency/contingency table showing the Fetchland name versus
# how many of that Fetchland are being ran. The numbers in the table are how
# many deck names have this the particular combination. For example, 52 decks
# are running 0 Arid Mesas, and 3 decks are running 2 Bloodstained Mires.
table(by_fetchland$Fetchland, by_fetchland$Total)

# Let's add the margins to this
addmargins(table(by_fetchland$Fetchland, by_fetchland$Total))

# One of the things that is interesting to see here is the number of decks
# running 4 Windswept Heath and number running 2 Wooded Foothills. These are
# from the Khans of Tarkiir block, and until the recent release of Modern
# Horizons II which sought to increase the availability of the "enemy
# Fetchlands", these fetchlands were the relatively budget Fetchland options.

fetchland_by_count <- as.data.frame(table(by_fetchland$Fetchland,
                                          by_fetchland$Total))
colnames(fetchland_by_count) <- c("Fetchlands", "Count", "Frequency")
# fetchland_by_count

# The number of decks running zero of any type of fetchland is an order of
# magnitude higher than one, two, three, or four fetchlands. Of course, not
# every Fetchland is functional in every deck, so there's no chance players 
# would consider running them.

# Let's try and visualize the fetchland distribution
ggplot(data = fetchland_by_count, mapping = aes(x = Count,
                                                y = Frequency)) +
  geom_bar(stat = "identity")

# We can see that most decks run Fetchlands in even combinations. That is,
# for example, 0 Bloodstained Mire, 2, or 4. It seems incredibly uncommon for
# a decklist to run one of a Fetchland, and slightly more common to run 3.

# Now let's ignore Zero Fetchland column for a moment. That is, let's ignore
# decks not running Fetchlands.

fetchlands_in_decks <- fetchland_by_count[-c(1:11),]

# Let's try and visualize the "has Fetchlands" decks to get an idea of which
# fetchlands seem to show up in groups more often, and which are more commonly
# played as one-ofs or two-ofs.
ggplot(data = fetchlands_in_decks, mapping = aes(x = Count,
                                                y = Frequency,
                                                fill = Fetchlands)) +
  geom_bar(stat = "identity") +
  labs(title = "How Many Fetchlands of Each Type Do Decks Run?") +
  xlab("Copies of Fetchland in Deck") +
  ylab("Number of Decks") +
  scale_fill_discrete(name = "Fetchland Name",
                     labels = c("Arid Mesa",
                                "Bloodstained Mire",
                                "Flooded Strand",
                                "Marsh Flats",
                                "Misty Rainforest",
                                "Polluted Delta",
                                "Prismatic Vista",
                                "Verdant Catacombs",
                                "Scalding Tarn",
                                "Windswept Heath",
                                "Wooded Foothills"))

# Let's consider Wooded Foothills for a moment. The most common number of
# Wooded Foothills for decks (that run Fetchlands) to run is 2. This leads to
# many interesting conversations. First, does this mean that Gruul (Red-Green)
# decks are less popular in the format? If a deck was truly Gruul, would it not
# run 4 of them? After all, Gruul decks are usually faster-paced and don't care
# about the life loss associated with Fetchland/Shockland use, caring far more
# about their lands entering untapped, which Fetchlands permit. However, it
# could just as well be the case that Gruul decks are running Copperline Gorge,
# Which might not thin the deck out like a Fetchland does, but is a reasonable
# substitute.

# While there are likely too many moving parts to analyze this graph any
# further, it is nonetheless interesting to see that very few decks run Arid
# Mesa as a playset (4-of), how the most common way to run Misty Rainforest is
# as a playset, and how very few decks seem to be running Marsh Flats at all.

rm(by_fetchland,
   fetchland_by_count,
   fetchlands_in_decks) # finished with these objects


#--
# Selected Univariate Summary Statistics of the numeric variables
#--

sum_stats <- data.frame(mean=round(sapply(mmeta[, c(9, 22, 23)], mean, na.rm = T), 2), 
                        median=round(sapply(mmeta[, c(9, 22, 23)], median, na.rm = T), 2),
                        min=round(sapply(mmeta[, c(9, 22, 23)], min, na.rm = T), 2), 
                        max=round(sapply(mmeta[, c(9, 22, 23)], max, na.rm = T), 2), 
                        sd=round(sapply(mmeta[, c(9, 22, 23)], sd, na.rm = T), 2))

rownames(sum_stats) <- c("Number of Decks",
                         "Total Fetchlands in Deck",
                         "Price to Purchase Deck in Paper")

colnames(sum_stats) <- c("Mean", "Median", "Minimum", "Maximum", "Standard Deviation")

sum_stats

# Here we see that the mean and median Fetchland counts are the same, and the
# mean and median deck prices are the same. The mean deck count is much higher
# than the median, indicating right skewed data, which makes sense, because
# there are going to be a very small subset of decks that are played a lot, as
# they are the "decks to beat", commonly called "tier 1 decks".











#--
# Bivariate Analysis Using Pearson's Correlation Coefficient (numeric vars)
#--

# In Question 3, we're going to create a prediction model for the response,
# Deck Price. However, before doing so, since there are quite a few numeric
# predictors, we should check the correlation matrix to see if there are any
# highly correlated variables that might lead to multicollinearity, and if so, 
# perhaps we can collapse these predictors into a subset using something like
# Principal Component Analysis.

# As the amount of colors in a deck is a directly dependent sum from the other
# color columns, this information is redundant and can be left out of the
# correlation analysis and eventual prediction model safely. This is also true
# of the Total Fetchlands column, which is the sum (linear combination) of the
# 11 columns before it.

# We will leave out the Proportion_of_Metagame column, as it holds the same
# information as the Deck Count column, only on a different scale.

# The Deck Count (amount of decks of that type aggregated) may appear to be
# unrelated to the response, as after all, what does the amount of decks of a
# specific Archetype have to do with the cost of a deck? However, upon further
# consideration, it's reasonable to assume that the more people are playing a
# deck, the more the demand on the cards in that decklist will rise, and so the
# higher the Deck Count, the higher the prices of the average card in that deck.
# This is speculative, but a reason to include it later as a potential feature.

# create the correlation matrix
cor_matrix <- cor(mmeta[, c(9, 11:21, 23)])

# visualize it
corrplot(cor_matrix, method = "number")

# The highest correlations with Deck Price are the number of Misty Rainforests,
# Flooded Strands, and Scalding Tarns in the decks. That's very interesting,
# as these are the Blue Fetchlands, and Blue is the color most associated with
# Control Archetypes.

# Also note the moderate negative correlation between the cost of a deck and
# how many of those decks are being played. As one would expect, the more
# expensive a deck, the less people play it.

# It doesn't appear that there is any real multicollinearity, as
# none of the results are higher than 0.56, and most are lower than 0.20.
# Rule of Thumb for Multicollinearity: As a rule of thumb, one might suspect
# multicollinearity when the correlation between two (predictor) variables is
# below -0.9 or above +0.9.




#######################
# Dimension Reduction #
#######################

# No multicollinearity means a higher chance that doing a Principal Component
# Analysis will bear weak fruit in the form of dimension reduction, as most
# of the predictors are closer to orthogonal/perpendicular already. But, we can
# still try, and maybe even provide some insights by finding clusters of deck
# prices or specific features, such as a specific Fetchland, that tell us a lot
# about the price of a deck.

# We'll need to scale the values, since Deck Count is orders of magnitude larger
# than the Fetchland counts. The Fetchlands are all on the same scale, but they
# need to play well with the Deck Count.

# Creating the principal components
pcs <- prcomp(x = mmeta[, c(9, 11:21)], scale. = TRUE)

summary(pcs)

# There are a lot of Rules of Thumb for deciding the number of Principal
# Components to keep: The Elbow Method, Kaiser Rule, and Proportion of Variance
# cutoffs.

# Let's consider the Elbow Method First, because it's visual.

# This is done with a Scree Plot
plot(pcs)
plot(pcs, type = "l")

# The same plot using ggplot2
# compute total variance

# Squaring the sdev component gets you the eigenvalues.
variance <- pcs$sdev^2
variance

# Dividing by the sum of the eigenvalues gives the proportion of the variance,
# because you're dividing eigenvalue by total eigenvalues.
prop_of_variance <- pcs$sdev^2 / sum(pcs$sdev^2)
prop_of_variance

var_explained_df <- data.frame(PC = factor(paste0("PC", 1:10)),
                               Variance_Explained = variance[1:10])

# Plotting a nice looking Scree Plot
ggplot(data = var_explained_df,
       mapping = aes(x = PC,
                     y = Variance_Explained,
                     group = 1)) +
  geom_point(size = 4) +
  geom_line() +
  geom_hline(yintercept = 1, linetype = "dashed", color = "red") +
  # Have to specify the order of the factors, because ggplot randomly puts PC10 after PC1... 
  scale_x_discrete(limits = c("PC1", "PC2", "PC3",
                              "PC4", "PC5", "PC6",
                              "PC7", "PC8", "PC9",
                              "PC10")) +
  labs(title = "Scree plot: Principal Components Larger than Kaiser Rule (?? > 1)",
       subtitle = 'Note the lack of an obvious "Elbow". Closest is PC3.') +
  xlab("Principal Components") +
  ylab("Eigenvalue")


# Using the Kaiser rule, any Eigenvalue/Variance under 1 should be discarded.
# This is because an eigenvalue less than 1 means that the PC explains less
# than a single original variable explained, i.e. it has no dimensional
# reduction value, as the original variable was better than the new variable.

# For this example, that means we would keep the first 4 Principal Components.

# Generally, a great sign that multiple continuous covariates can be collapsed
# into a smaller subset of principal components is a steep drop and then a
# leveling out or less steep remainder of the curve going right. The principal
# component associated with that drop is usually noted as the location of the
# "Elbow", after which the inclusion of further principal components are not
# nearly as valuable, as they don't contribute a high eigenvalue and
# consequently contribute a smaller amount to the proportion of the variance
# in the data.

# The best "Elbows" are 3 and then maybe 6 and 7, but though they're the best
# choices, they're still not good. Also, we've already weeded out anything
# below the red line. So, we're left with PC3. The "hill" is still reasonably
# steep after PC3. We wanted to see a much steeper drop and then a subtle
# horizontal decline afterward, and that's not what we're seeing here. Also,
# even though it's the "best" option, the first 3 Principal Components only
# account for 51.87% of the variance, which isn't good, as we're looking for
# something closer to 80+%.

# Even though the Principal Component Analysis is a bust insofar as dimension
# reduction is concerned. We may be able to gain real insight from the biplot,
# to see if there are any stand out relationships in the first two Principal
# Components.

# Using Base R
biplot(pcs)

# Using the ggbiplot() function
ggbiplot(pcs) +
  labs(title = "Biplot: First two Principal Components",
       subtitle = str_wrap("Predictors are standardized, because Deck Count is
                           included. While Fetchland counts are on the same
                           scale, Deck Count is an order of magnitude larger
                           than the Fetchland numbers. It would ruin the
                           analysis if not scaled.", 115))

# note that the axes are have the added "standardized" because
# we standardized the columns with the "scale. = TRUE" option, which was

# A comparison between the most influenctial principal components

# When two vectors are close, forming a small angle, the two variables they
# represent are positively correlated. This plot shows 3 distinct clusters
# affecting the creating/affecting the first two Principal Components. First,
# the number of Flooded Strand, Polluted Delta, and Scalding Tarn. These are
# 3 of the 4 Blue lands, the primary color of the Control Archetype. Next, the
# group with Bloodstained Mire, Arid Mesa, and Marsh Flats. These lands are all
# Black, Red, and White. These are the colors most associated with Aggro
# strategies. This is very interesting. Finally, the last group are the
# Green lands, which is the color most associated with Midrange strategies,
# which play slower than Aggro, faster than Control, sitting in the middle
# of the Archetypes, speedwise. It'll be interesting to see if the Midrange
# decks also sit in the middle, price wise! We may have found a new question.
# "Does the time it takes for your deck to win the game positively correlate
# with the price of the deck?" Haha.

# A nice looking Biplot
ggbiplot(pcs,
         var.scale = 1,
         groups = mmeta$Archetype,
         ellipse = TRUE,
         circle = TRUE) +
  labs(title = "Biplot: First two Principal Components",
       subtitle = "Ellipses are 95% Confidence") +
  theme(legend.direction = 'vertical', legend.position = 'right')


# While a little noisy, this graph confirms the sentiment "Aggro = Red" and
# "Control = Blue", as we can see the "Aggro" ellipse is clustered around
# the Red Fetchlands, and the "Control" ellipse around the 3 Blue Fetchlands
# in the Southwest corner of the graph. Actually, part of the Control ellipse
# contains the Misty Rainforest and Prismatic Vista vectors, which also happen
# to be the only other 2 lands in the picture than help the player in their
# endeavors to produce Blue mana!

# So, while we won't be able to reduce the number of numeric predictors using
# PCA, it can't be stated that it wasn't without insight.

# An alternative way to plot the same biplot and ellipses, using the ggplot2
# package.
mmeta <- cbind(mmeta, pcs$x[, 1:2]) # attaching the pcs to the dataset
ggplot(data = mmeta,
       mapping = aes(x = PC1,
                     y = PC2,
                     col = Archetype,
                     fill = Archetype)) +
  stat_ellipse(geom = "polygon", col = "black", alpha = 0.10) +
  geom_point(shape = 21, col = "black")

# Unfortunately, it doesn't appear that any of the archetypes are separated
# into different clusters along these two principal components. Which isn't
# too surprising, given the low proportion of variance in these two components.


