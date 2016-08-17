### Exploration of the Iris Dataset

#########################
# Preliminary exploration

# Load Iris dataset
data(iris)

# Print first 6 rows
head(iris)

# Print basis statistics
summary(iris)


#############################
# Exploring a single variable

# Print first 10 Sepal Length
iris$Sepal.Length[1:10]

# Calculate quantile of Sepal.Length
quantile(iris$Sepal.Length)

# Variance of Sepal.Length
var(iris$Sepal.Length)

# Histogram of Sepal.Length
hist(iris$Sepal.Length)

# Density Distribution of Sepal.Length
plot(density(iris$Sepal.Length))

# Count by category
table(iris$Species)

# Pie Chart of counts
pie(table(iris$Species))

# Bar Chart of counts
barplot(table(iris$Species))


############################
# Exploring Multiple Variables

# Correlation of two fields
cor(iris$Sepal.Length, iris$Petal.Length)

# Correlation of all numerical fields
cor(iris[, 1:4])

# Covariance of all numerical fields
cov(iris[, 1:4])

# Statistics of Sepal.Length by species
aggregate(Sepal.Length ~ Species, summary, data = iris)

# Statistic (mean) of fields by species
aggregate(. ~ Species, data = iris, mean)

# Box plot of Sepal.Length distribution by species
boxplot(Sepal.Length ~ Species, data = iris)

# Scatter plot of Sepal.Length vs Sepal.Width by species
with(iris, plot(Sepal.Length, Sepal.Width, col = Species, pch = as.numeric(Species)))

# Matrix of scatter plots by Species
plot(iris, col = iris$Species)

# 3D Scatter plot
install.packages("scatterplot3d", dependencies = TRUE)
library(scatterplot3d)

scatterplot3d(iris$Petal.Width, iris$Sepal.Length, iris$Sepal.Width)

# Heatmap of similarity between different flowers
distMatrix <- as.matrix(dist(iris[, 1:4]))
heatmap(distMatrix)

# More complex graphics
install.packages("ggplot2", dependencies = TRUE)
library(ggplot2)

qplot(Sepal.Length, Sepal.Width, data = iris, facets = Species ~ .)
