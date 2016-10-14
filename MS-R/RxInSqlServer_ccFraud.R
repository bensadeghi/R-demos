### Overview of MS-R in SQL Server 2016, using a credit card fraud dataset

# database connection string:
sqlConnString <- "Driver=SQL Server; Server=???.???.???.???; Database=master; Uid=?????; Pwd=?????"
sqlRowsPerRead = 5000


### Example 1 - Using SQL Server Tables
# specify the column types
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

# path to a CSV file
ccFraudCsv <- file.path(rxGetOption("sampleDataDir"), "ccFraudSmall.csv")
# path to SQL Server table
sqlFraudDS <- RxSqlServerData(
            connectionString = sqlConnString,
            table = "ccFraudSmall",
            rowsPerRead = sqlRowsPerRead)

# point to CSV file with some meta-data
inTextData <- RxTextData(file = ccFraudCsv, colClasses = col_classes)

# import the CSV file into a SQL Server table
rxDataStep(inData = inTextData, outFile = sqlFraudDS, overwrite = TRUE)

# Print first 5 rows
rxGetInfo(data = sqlFraudDS, getVarInfo = TRUE, numRows = 5)

# get summary statistics of the dataset
rxSummary( ~ ., sqlFraudDS)

# build a model using the training dataset
model <- rxLogit(fraudRisk ~ gender + balance + numIntlTrans, sqlFraudDS)
summary(model)



# perform the same steps with the scoring/testing dataset
ccScoreCsv <- file.path(rxGetOption("sampleDataDir"), "ccFraudScoreSmall.csv")
sqlScoreDS <- RxSqlServerData(connectionString = sqlConnString, table = "ccFraudScoreSmall", rowsPerRead = sqlRowsPerRead)
inTextData <- RxTextData(file = ccScoreCsv, colClasses = col_classes[-length(col_classes)])
rxDataStep(inData = inTextData, outFile = sqlScoreDS, overwrite = TRUE)
rxDataStep(inData = sqlScoreDS, outFile = sqlScoreDS,
            transforms = list(moreIntlTrans = numIntlTrans > numTrans), overwrite = TRUE)

# predict fraud risk using scoring dataset
predictions <- rxPredict(modelObject = model, data = sqlScoreDS,
            writeModelVars = TRUE, predVarNames = "Score",
            outData = "fraudScore.xdf", overwrite = TRUE)
# print results
rxGetInfo(predictions, getVarInfo = TRUE, numRows = 5)




### Example 2 - Using SQL Server Compute Context
# we now set the compute context to SQL Server
# this will make the computations happen in SQL Server

# define SQL Server compute context parameters
sqlShareDir <- paste("C:\\AllShare", Sys.getenv("USERNAME"), sep = "")
dir.create(sqlShareDir, recursive = TRUE)
sqlWait <- TRUE
sqlConsoleOutput <- FALSE

sqlCompute <- RxInSqlServer(
            connectionString = sqlConnString,
            shareDir = sqlShareDir,
            wait = sqlWait,
            consoleOutput = sqlConsoleOutput)

# set compute context to SqlServer
rxSetComputeContext(sqlCompute)
rxGetComputeContext()

# use data in SQL Server table
sqlFraudDS <- RxSqlServerData(
            connectionString = sqlConnString,
            table = "ccFraudSmall",
            rowsPerRead = sqlRowsPerRead)

# create a histogram
rxHistogram( ~ creditLine | gender, data = sqlFraudDS, histType = "Percent")

# create a linear model
linModObj <- rxLinMod(balance ~ gender + creditLine, data = sqlFraudDS)
summary(linModObj)

# create a logistic regression model
logitObj <- rxLogit(fraudRisk ~ state + gender + cardholder + balance + numTrans + numIntlTrans + creditLine, 
                    data = sqlFraudDS, dropFirst = TRUE)
summary(logitObj)



# time to score the data with the model we built
sqlScoreDS <- RxSqlServerData(
            connectionString = sqlConnString,
            table = "ccFraudScoreSmall",
            rowsPerRead = sqlRowsPerRead)

sqlServerOutDS <- RxSqlServerData(
            connectionString = sqlConnString,
            table = "ccScoreOutput",
            rowsPerRead = sqlRowsPerRead)


if (rxSqlServerTableExists("ccScoreOutput"))
            rxSqlServerDropTable("ccScoreOutput")

rxPredict(modelObject = logitObj,
            data = sqlScoreDS,
            outData = sqlScoreDS,
            predVarNames = "ccFraudLogitScore",
            type = "link",
            writeModelVars = TRUE,
            overwrite = TRUE)

# print summary of score results
rxSummary( ~ ., data = sqlServerOutDS)



# SQL Server queries
sqlMinMax <- RxSqlServerData(
            sqlQuery = paste("SELECT MIN(ccFraudLogitScore) AS minVal,",
                             "MAX(ccFraudLogitScore) AS maxVal FROM ccScoreOutput"),
            connectionString = sqlConnString)

minMaxVals <- rxImport(sqlMinMax)
minMaxVals <- as.vector(unlist(minMaxVals))

sqlOutScoreDS <- RxSqlServerData(sqlQuery = "SELECT ccFraudLogitScore FROM ccScoreOutput",
            connectionString = sqlConnString,
            rowsPerRead = sqlRowsPerRead,
            colInfo = list(ccFraudLogitScore = list(
            low = floor(minMaxVals[1]),
            high = ceiling(minMaxVals[2]))))

# plot historgram of scores
rxHistogram( ~ ccFraudLogitScore, data = sqlOutScoreDS)
