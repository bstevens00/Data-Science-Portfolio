# Comparing Countries, Continents, and Communities during COVID

## Spoiler - The Bottom Line

While the United States has had 

The pandemic has had a major influence on all of our lives. This project was born out of my natural instinct to "see for myself". We all have family members who trust the vaccinations, as well as those who seem to find a conspiracy in everything.

## The Goals - Why do this? Why?

I enjoy Magic: the Gathering. It's my favorite game! And in the years I've played the game, I've absorbed some "conventional wisdoms" from conversations with other players, including beliefs like, "Aggressive decks are cheap to build. I wouldn't want to build a control deck on my budget" and "Gas is cheap and Fetchlands are expensive, that's why I play Burn". I want to use data visualization and summary statistics to understand my favorite way to play the game, the "Modern" format. I want to know if players are right about archetype pricing, and if there's any evidence to the conventional wisdom that Aggro decks are cheap and Control decks require a second mortgage. Finally, I want to create a useful price prediction model for the cost of a a Modern deck. This will involve trying out multiple different machine learning algorithms as well as potenially deploying an ensemble model.

## Necessary Magic: the Gathering Terminology and Information for the Reader

There are a few things that the reader will need to understand in order to understand this README.

* "Magic: the Gathering" (MtG) is a collectible, trading card game, with large tournaments in which people compete against one another using unique card strategies.
* A "Deck" is a player's 60 card strategy, and the player uses this deck in 1-on-1 matches to defeat opponents who also have decks of their own unique cards and strategies.
* Some deck strategies are similar *enough* in their goals, such as "stall the game out to win later" (called "Control"), "win as fast as possible" ("Aggro"), or "assemble two different cards that work in combination to win the game instantly" ("Combo") that these strategies fall under an grouping umbrella term, which this project will call "Archetypes".
* There are five "Colors" in the game, White, Blue, Black, Red, and Green ("WUBRG"). Each color has unique mechanisms towards gaining advances in a game, and can be used creatively together to leverage combination strategies. Though unneeded for understanding this analysis, for a more in-depth read on the MtG colors, read [this](https://mtg.fandom.com/wiki/Color) article.
* A deck may only have 4 copies of the same card (unless it's a "Basic Land", but that doesn't matter for this analysis, so just assume it's 4). The 4 card limit will matter when we talk about Fetchlands.
* "Fetchlands" are a specific set of cards that help the player smooth out their resource devopment and play the game more efficiently. There are ten primary lands being refered to when a player says "Fetchlands". Those cards, as well as an additional honorary inclusion are, by name:

1. [Arid Mesa](https://scryfall.com/card/zen/211/arid-mesa)
2. [Bloodstained Mire](https://scryfall.com/card/ktk/230/bloodstained-mire)
3. [Flooded Strand](https://scryfall.com/card/ktk/233/flooded-strand)
