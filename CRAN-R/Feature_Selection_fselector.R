### Feature Selection via FSelector

install.packages("FSelector", dependencies = TRUE)

library(FSelector)

# Load Iris dataset
data(iris)
# Define formula to use
myFormula <- Species ~ .


# Calculate feature importance using Chi-squared Filter
importance <- chi.squared(myFormula, iris)
print(importance)

# Using Entropy-Based Filter
importance <- information.gain(myFormula, iris)
print(importance)

# Using Gain Ratio
importance <- gain.ratio(myFormula, iris)
print(importance)

# Using Symmetrical Uncertainty
importance <- symmetrical.uncertainty(myFormula, iris)
print(importance)

# Using OneR Algorithm
importance <- oneR(myFormula, iris)
print(importance)

# Using Random Forest Filter
importance <- random.forest.importance(myFormula, iris, importance.type = 1)
print(importance)


# Select top 2 features based on importance, and generate new formula
subset <- cutoff.k(importance, 2)
newFormula <- as.simple.formula(subset, "Species")
print(newFormula)
