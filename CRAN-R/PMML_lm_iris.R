### PMML model export example

# Install and load the PMML library
install.packages("pmml", dependencies = TRUE)
library(pmml)

# Load the Iris dataset
data(iris)

# Build a simple lm model
iris.lm <- lm(Sepal.Length ~ ., data=iris)

# Convert to PMML
xml <- pmml(iris.lm)

# Save the PMML XML to a file
getwd()
saveXML(xml, file = "lm_iris.xml")
