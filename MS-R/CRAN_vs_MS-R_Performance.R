### Some Performance Comparisons Between CRAN-R and MS-R Functions
### Using Fraud Data and UCI Adult Income Census Data 

### Example 1
### Fraud Data - Logistic Regression
# Fetch CSV data from sample data directory
ccFraudCsv <- file.path(rxGetOption("sampleDataDir"), "ccFraudSmall.csv")

# Create column meta-data list for the fraud data
col_classes <- c(
                custID = "integer",
                gender = "integer",
                state = "integer",
                cardholder = "integer",
                balance = "integer",
                numTrans = "integer",
                numIntlTrans = "integer",
                creditLine = "integer",
                fraudRisk = "integer")

# Point to the CSV and provide the meta-data
inTextData <- RxTextData(file = ccFraudCsv, colClasses = col_classes)

# Create new boolean field, specifing if number of international transactions exceed local ones
fraudDF <- rxDataStep(inData = inTextData,
                      transforms = list(moreIntlTrans = numIntlTrans > numTrans))

# Print first 10 rows
rxGetInfo(fraudDF, getVarInfo = TRUE, numRows = 10)

# Print statistical summary of new data set
rxSummary( ~ ., fraudDF)

# Plot histogram of creditLine, grouped by card-holder status
rxHistogram( ~ creditLine | cardholder, data = fraudDF, histType = "Percent")

# Create and time logistic regression models using rxLogit() and glm()
time_rxLogit <- system.time(rxLogit(fraudRisk ~ gender + balance + moreIntlTrans, data = fraudDF))
time_glm <- system.time(glm(fraudRisk ~ gender + balance + moreIntlTrans, data = fraudDF, family = binomial(link = 'logit')))
# Compare timings
cbind(time_rxLogit, time_glm)

# Replicate and increase the size of the data by a factor of 100
bigFraudDF <- do.call(rbind, lapply(1:100, function(i) fraudDF))
# Compare dimensions of datasets
dim(fraudDF)
dim(bigFraudDF)

# Calculate and time summaries of big data set
time_rxSummary <- system.time(rxSummary( ~ ., bigFraudDF))
time_summary   <- system.time(summary(bigFraudDF))
# Comparing timings
cbind(time_rxSummary, time_summary)

# Create and time logistic regression models on the big dataset
time_rxLogit <- system.time(rxLogit(fraudRisk ~ gender + balance + moreIntlTrans, data = bigFraudDF))
time_glm <- system.time(glm(fraudRisk ~ gender + balance + moreIntlTrans, data = bigFraudDF, family = binomial(link = 'logit')))
# Compare timings
cbind(time_rxLogit, time_glm)



### Example 2
### UCI-MLR Adult Income Census Data - Decision Tree
# Fetch 'adult' dataset
censusDF <- read.table("http://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data", sep=",", header=F,
        col.names=c("age", "type_employer", "fnlwgt", "education", "education_num","marital", "occupation", "relationship",
        "race", "sex","capital_gain", "capital_loss", "hr_per_week", "country", "income"), fill=F, strip.white=T)

# Remove unhelpful fields, fnlwgt and country
censusDF$fnlwgt <- NULL
censusDF$country <- NULL

# Cast string fields to factors
censusDF <- rxImport(censusDF, stringsAsFactors = TRUE)

# Print first 10 rows
rxGetInfo(censusDF, getVarInfo = TRUE, numRows = 10)

# Load rpart and party (decision tree) packages
library(rpart)
library(party)

# Create classification formula using all the fields
cols <- names(censusDF)
cols <- paste(cols[ - length(cols)], collapse = "+")
censusFormula <- formula(paste("income ~", cols))
print(censusFormula)

# Build and time decision trees
time_rxDTree <- system.time(rxDTree(censusFormula, data = censusDF))
time_rpart   <- system.time(rpart(censusFormula, data = censusDF))
time_ctree   <- system.time(ctree(censusFormula, data = censusDF))
# Compare timings
cbind(time_rxDTree, time_rpart, time_ctree)

# Replicate and increase the size of the data by a factor of 10
bigCensusDF <- do.call(rbind, lapply(1:10, function(i) censusDF))

# Build and time decision trees using big data set
time_rxDTree <- system.time(rxDTree(censusFormula, data = bigCensusDF))
time_rpart   <- system.time(rpart(censusFormula, data = bigCensusDF))
time_ctree   <- system.time(ctree(censusFormula, data = bigCensusDF))   # might run out of memory
# Compare timings
cbind(time_rxDTree, time_rpart)
