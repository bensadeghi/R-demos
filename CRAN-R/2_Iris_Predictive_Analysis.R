### Predictive Analysis of Iris Dataset

# Load iris dataset 
data(iris)
head(iris)

# Randomly sample iris data to generate training and testing sets
ind <- sample(2, nrow(iris), replace = TRUE, prob = c(0.7, 0.3))
train_data <- iris[ind == 1,]
test_data <- iris[ind == 2,]

###########################################
# Species classification with decision tree

# Create the decision tree. The tree is attempting to predict Species based upon sepal length, width and petal length and width
install.packages("party", dependencies = TRUE)
library(party)

my_formula <- Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
iris_ctree <- ctree(my_formula, data = train_data)

# Print the tree
print(iris_ctree)

# Plot the tree
plot(iris_ctree)

# Plot a simplified view of the tree
plot(iris_ctree, type = "simple")

# Check the predictions with the training set (confusion matrix)
preds <- predict(iris_ctree)
table(preds, train_data$Species)

# Check the predictions with the test set
preds <- predict(iris_ctree, newdata = test_data)
cm <- table(preds, test_data$Species)
cm

# Compute accuracy of test predictions
sum(diag(cm)) / sum(cm)


#################################################
# Species classification with logistic regression

# Create new dataset, with rows labeled as type virginica or not
new_iris <- iris
new_iris$virginica <- new_iris$Species == "virginica"
new_iris$Species <- NULL

# Generate logistic regression model
my_formula <- virginica ~ .
iris_logit <- glm(my_formula, data = new_iris, family = binomial(logit))

# Print model coefficients
iris_logit

# Print more detailed summary
summary(iris_logit)


#################################################
# Petal.Width prediction with linear regression

# Remove Species column from previous training and testing datasets 
train_data$Species <- NULL
test_data$Species <- NULL

# Generate linear regression model
my_formula <- Petal.Width ~ .
iris_lm <- lm(my_formula, data = train_data)

# Print model coefficients
iris_lm

# Made prediction on test dataset
preds <- predict(iris_lm, newdata = test_data)

# Calculate correlation between test data and predictions
cor(test_data$Petal.Width, preds)

# Get coefficient of determination (R^2)
summary(iris_lm)$r.squared

# Plot actual Petal.Width vs predictions
plot(test_data$Petal.Width, preds)


#######################
# Clusting with k-means

# Remove Species column
new_iris <- iris
new_iris$Species <- NULL

# Cluster into 3 groups
kc <- kmeans(new_iris, 3)
kc

# Compare the Species label with the clustering result
table(iris$Species, kc$cluster)

# Plot the clusters and their centres
plot(new_iris[c("Sepal.Length", "Sepal.Width")], col = kc$cluster)
points(kc$centers[, c("Sepal.Length", "Sepal.Width")], col = 1:3, pch = 8, cex = 2)


#########################
# Hierarchical Clustering

# Downsample iris data
idx <- sample(1:dim(new_iris)[1], 40)
new_iris <- new_iris[idx,]

# Create hierarchical cluster
hc <- hclust(dist(new_iris), method = "ave")

# Plot cluster
plot(hc, hang = -1, labels = iris$Species[idx])

# Cut tree into 3 clusters
rect.hclust(hc, k = 3)
groups <- cutree(hc, k = 3)
