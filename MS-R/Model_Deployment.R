##             MODEL DEPLOYMENT EXAMPLE                 ##

##########################################################
#         Load mrsdeploy package on R Server             #
##########################################################

library(mrsdeploy)

##########################################################
#       Create & Test a Logistic Regression Model        #
##########################################################

# Use logistic regression equation of vehicle transmission 
# in the data set mtcars to estimate the probability of 
# a vehicle being fitted with a manual transmission (am)
# based on horsepower (hp) and weight (wt)

head(mtcars)

# Create generalized linear model with `mtcars` dataset
carsModel <- glm(formula = am ~ hp + wt, data = mtcars, family = binomial)

# Produce a prediction function that can use the model
manualTransmission <- function(hp, wt) {
  newdata <- data.frame(hp = hp, wt = wt)
  predict(carsModel, newdata, type = "response")
}

# test function locally by printing results
manualTransmission(120, 2.8) # 0.6418125

##########################################################
#            Log into Microsoft R Server                 #
##########################################################

# Remote Login, a prompt will show up to input user and pwd information
endpoint <- "http://localhost:12800"
remoteLogin(endpoint, session = FALSE, diff = FALSE)

##########################################################
#             Publish Model as a Service                 #
##########################################################

# Publish as service using `publishService()` function from 
# `mrsdeploy` package. Name service "mtService" and provide
# unique version number. Assign service to the variable `api`

deleteService("mtService",v = "v1.0.0")

api <- publishService(
  "mtService",
  code = manualTransmission,
  model = carsModel,
  inputs = list(hp = "numeric", wt = "numeric"),
  outputs = list(answer = "numeric"),
  v = "v1.0.0"
)

##########################################################
#                 Consume Service in R                   #
##########################################################

# Print capabilities that define the service holdings: service 
# name, version, descriptions, inputs, outputs, and the 
# name of the function to be consumed
api$capabilities()

# Print public functions, ie inputs / outputs
api$print()

# Consume service by calling function, `manualTransmission`
# contained in this service
result <- api$manualTransmission(120, 2.8)

# Print response output named `answer`
result$output("answer") # 0.6418125 
