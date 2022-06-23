In statistics, the k-nearest neighbors algorithm (KNN) is a non-parametric, supervised learning method focused used in both classification and prediction. Here, it is used for classification.

Let's consider a fun example, so that we know what we're doing here. Note this example is being used to illustrate how the algorithm works, and the project, unfortunately, has nothing to do with witches and wizards.

We have 1000 kids going into Hogwarts, and they need to be sorted into one of four houses: Gryffindor, Hufflepuff, Ravenclaw, or Slytherin. We've misplaced the Sorting Hat, so we're forced to rely on the inferior, yet promising field of "Machine Learning" to sort (classify) these kids into one of the four previously mentioned houses.

With the support of the Headmaster (principal of the school), we're allowed to gather information on all the students in the school to meet our goal. For every student, we note their genders, parents' level of education, parents' NEWT scores (ACT/SAT), as well as many other metrics for each student, including the house they've been sorted into. We gather all the same information from the first-year students, except which house they've been sorted into, as we don't know that information yet, and that's our goal.

We use this information sort each kid into the "correct" house.

How does KNN do this? How the does algorithm work?

Suppose we have a first-year student named "Sara Cross" waiting to be sorted.

All of her information is fed into the sorting algorithm. We've told it give us the 5 upper classmen with the closest student profiles to Sara Cross. A list of 5 students are returned. 1 of those students are Slytherin. 1 is Hufflepuff, and 3 are Ravenclaw. Since the majority (60%) of the students that have similar profiles to Sara have been sorted into Ravenclaw in the past, our KNN algorithm sorts Sara into Ravenclaw too.

That's the gist of it. There's more details as far as how the model works, including Euclidean and Mahalanobis/Staistical Distances, making sure K is odd, choosing the right K, scaling the predictors so some aren't more influential over her sorting than others, etc., but those are details.