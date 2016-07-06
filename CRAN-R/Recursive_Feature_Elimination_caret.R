### Recursive Feature Elimination via caret

install.packages(c("caret", "mlbench"), dependencies = TRUE)

library(caret)
library(mlbench)

# Generate synthetic data using friedman1 formula
# With 5 real variables, and 5 noise
rows <- 100
sim <- mlbench.friedman1(rows, sd = 1)
colnames(sim$x) <- c(paste("real", 1:5, sep = ""),
                     paste("fake", 1:5, sep = ""))

# Add 40 more fake (random) data variables
# Of the 50 predictors, there are 45 pure noise variables: 5 are uniform on [0, 1]
# and 40 are random univariate standard normals.
cols <- 40
fake <- matrix(rnorm(rows * cols), nrow = rows)
colnames(fake) <- paste("fake", 5 + (1:ncol(fake)), sep = "")
x <- cbind(sim$x, fake)
y <- sim$y

# Print first row of features
head(x, 1)

# Center and scale the predictors
normalization <- preProcess(x)
x <- predict(normalization, x)
x <- as.data.frame(x)

# Define number of variables to be used in fitting over the runs 
subsets <- c(1:5, 10, 15, 20, 25)

# Set recursive feature elimination parameters
# Fit to a linear model (lmFuncs), use 10-fold CV (repeatedcv), and repeat 3 times
ctrl <- rfeControl(functions = lmFuncs,
                   method = "repeatedcv",
                   repeats = 3,
                   verbose = FALSE)

# Run RFE on dataset, across the given feature space subsets
lmProfile <- rfe(x, y,
                 sizes = subsets,
                 rfeControl = ctrl)

# Print RFE results
lmProfile

# Print most important features
predictors(lmProfile)

# Plot error vs. number of variables
plot(lmProfile, type = c("g", "o"))
