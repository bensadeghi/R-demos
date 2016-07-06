### Model Evaluation via caret

# Install and load caret and klaR (NB) packages
install.packages(c("caret", "klaR"), dependencies = TRUE)
library(caret)
library(klaR)

# load the iris dataset
data(iris)

##### Data Splitting #####
# Define an 80%/20% train/test split of the dataset
split = 0.80
trainIndex <- createDataPartition(iris$Species, p = split, list = FALSE)
data_train <- iris[trainIndex,]
data_test <- iris[ - trainIndex,]

# Train a naive bayes model
model <- NaiveBayes(Species ~ ., data = data_train)

# Make predictions
x_test <- data_test[, 1:4]
y_test <- data_test[, 5]
predictions <- predict(model, x_test)

# Summarize results with a confusion matrix
confusionMatrix(predictions$class, y_test)


##### Bootstrap Resampling #####
# Define training control, using 10 bootstrapped samples
train_control <- trainControl(method = "boot", number = 10)

# Train the model
model <- train(Species ~ ., data = iris,
               trControl = train_control, method = "nb")
# Summarize results
print(model)


##### K-Fold Cross Validation #####
# Define training control, using 10-fold CV
train_control <- trainControl(method = "cv", number = 10)

# Train the model
model <- train(Species ~ ., data = iris,
               trControl = train_control, method = "nb")
# Summarize results
print(model)


##### Leave One Group Out Cross Validation #####
# Define training control
train_control <- trainControl(method = "LGOCV")

# Train the model
model <- train(Species ~ ., data = iris,
               trControl = train_control, method = "nb")
# Summarize results
print(model)
