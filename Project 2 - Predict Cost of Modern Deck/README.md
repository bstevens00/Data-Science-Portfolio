# Project 2

## The Goal

Create a price prediction model for the cost of a Magic: the Gathering deck in the Modern format. Gain insight about the format as a whole through data visualization and summary statistics. See if some of the player beliefs about the game are true, such as specific deck Archetypes being more affordable than others.

## Spoiler - "Please Tell Me the End of the Story"



## How do I navigate this project?

Here are the three main goals in the project, and the .R file that tackles the question.

1. Summarize and visualize the data, seeking interesting relationships, such as the most played color in the format.
	+ File: 1_Exploratory_Data_Analysis.R
2. Look for evidence that deck prices significantly differ based upon the archetype being played.
	+ File: 2_Differences_in_Archetype_Prices.R
3. Create an accurate deck price prediction model based on the the number of a specific Fetchlands being played and the deck's Archetype.
	+ File: 3_modern_deck_prices.R.

## Simplified and Necessary Terminology and Understandings for the Reader

There are a few things that the reader will need to understand in order to understand this README.

* "Magic: the Gathering" is a collectible, trading card game, with huge tournaments in which people compete against one another using unique card strategies
* A "Deck" is a player's 60 card strategy, and the player uses this deck in 1-on-1 matches to defeat opponents who also have decks of their own cards
* Some decks are similar enough in their overarching strategies, like "stall the game out to win later", "win as fast as possible", or "assemble two different cards that work in combination to win the game instantly" that they're categorized into "Archetypes"
* A deck may only have 4 copies of the same card (unless it's a "Basic Land", but that doesn't matter for this analysis, just assume it's 4)
	
## Why these goals? Why do this?

I enjoy Magic: the Gathering. It's my favorite game! And in the years I've played the game, I've absorbed some "conventional wisdoms" from conversations with other players, including beliefs like, "Aggressive decks are cheap to build. I wouldn't want to build a control deck on my budget" and "Gas is cheap and Fetchlands are expensive, that's why I play Burn".

So, I wanted to know. Are Control decks more expensive than Aggro (Aggressive)? Can we visualize it? Also, is the difference *statistically significant*, indicating a real difference that is more than anecdotal, it's an actual reality. Does the popularity of a deck have any significant effect on the price? And, can a deck's price be predicted with any level of accuracy by only knowing the number of each Fetchland present in the deck, the total number of decks submitted of that type in the last year to the database (essentially the popularity of the deck) and the Archetype of the deck?

## Where did this data come from?

Data was collected from www.mtggoldfish.com (MTGG), a popular strategy and data aggregation website for Magic: the Gathering (MTG) on 8.6.2021 by myself, Brendan Stevens.

## Exploratory Data Analysis

![Most Pervasive Color](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Percent_of_Decks_with_This_Color.png> "Most Pervasive Color")



![Big Picture Stats](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Big_Picture_Stats.PNG> "Big Picture Stats")

![Correlation Matrix](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Correlation_Matrix.png> "Correlation Matrix")

![Fetchlands Count Barchart](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Fetchland_Counts_Barchart.png> "Fetchlands Count Barchart")

![Fetchlands Count Table](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Fetchland_Counts_Table.PNG> "Fetchlands Count Table")

![Fetchlands Count Table with Marginal Totals](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Fetchland_Counts_Table_with_Marginal_Totals.PNG> "Fetchlands Count Table with Marginal Totals")

![Principal Component Analysis](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Principal_Component_Analysis.png> "Principal Component Analysis")

![Which Archetypes in Top 60 Decks](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Which_Archetypes_in_Top_60.png> "Which Archetypes in Top 60 Decks")

![Perfect Scree Plot Example](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/Perfect_Scree_Plot_Elbow.jpeg | width="300" height="300" /> "Perfect Scree Plot Example")

![Scree Plot](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Scree_Plot.png> "Scree Plot")

![Biplot](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Biplot.png> "Biplot")

![Biplot with 95% Confidence Ellipses](<https://github.com/bstevens00/Data-Science-Portfolio/blob/main/Project%202%20-%20Predict%20Cost%20of%20Modern%20Deck/images/1_Biplot_95_Confidence_Ellipses.png> "Biplot with 95% Confidence Ellipses")
