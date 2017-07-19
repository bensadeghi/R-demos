### RxHadoop & RxSpark Contexts
### Build logistic regression model using AirOnTime data

########## Fetch Data ##########
# Define the HDFS file system
hdfsFS <- RxHdfsFileSystem()
# Set the HDFS location of example data
bigDataDirRoot <- "/example/data"
# create a local folder for storaging data temporarily
source <- "/tmp/AirOnTimeCSV2012"
dir.create(source)
# Set directory in bigDataDirRoot to load the data into
inputDir <- file.path(bigDataDirRoot, "AirOnTimeCSV2012")

# Download data to the tmp folder
remoteDir <- "http://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012"
download.file(file.path(remoteDir, "airOT201201.csv"), file.path(source, "airOT201201.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201202.csv"), file.path(source, "airOT201202.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201203.csv"), file.path(source, "airOT201203.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201204.csv"), file.path(source, "airOT201204.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201205.csv"), file.path(source, "airOT201205.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201206.csv"), file.path(source, "airOT201206.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201207.csv"), file.path(source, "airOT201207.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201208.csv"), file.path(source, "airOT201208.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201209.csv"), file.path(source, "airOT201209.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201210.csv"), file.path(source, "airOT201210.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201211.csv"), file.path(source, "airOT201211.csv"), method = "wget", quiet = T)
download.file(file.path(remoteDir, "airOT201212.csv"), file.path(source, "airOT201212.csv"), method = "wget", quiet = T)

# Make the directory
rxHadoopMakeDir(inputDir)
# Copy the data from source to input
rxHadoopCopyFromLocal(source, bigDataDirRoot)
# List files copied onto Hadoop
rxHadoopListFiles(inputDir)


########## Format Data ##########
# Create info list for the airline data
airlineColInfo <- list(
    DAY_OF_WEEK = list(type = "factor"),
    DISTANCE = list(type = "integer"),
    DEP_TIME = list(type = "integer"),
    ARR_DEL15 = list(type = "logical"))

# Get all the column names
varNames <- names(airlineColInfo)


####### Set Hadoop Compute Context #######
myHadoopCluster <- RxHadoopMR(consoleOutput=TRUE)
# Set the compute context
rxSetComputeContext(myHadoopCluster)
# Define the HDFS file system
hdfsFS <- RxHdfsFileSystem()

# Define the text data source in HDFS
airOnTimeData <- RxTextData(inputDir, colInfo = airlineColInfo, varsToKeep = varNames, fileSystem = hdfsFS)

# Define XDF file and import from CSV data in HDFS
filename <- file.path(bigDataDirRoot, "AirOnTimeData")
airOnTimeDataXdf <- RxXdfData(filename, fileSystem = hdfsFS )
rxImport(inData = airOnTimeData, outFile = airOnTimeDataXdf,
         rowsPerRead = 250000, overwrite = TRUE, numRows = -1)

# Compute summary information
adsSummary <- rxSummary(~ARR_DEL15 + DISTANCE + DEP_TIME + DAY_OF_WEEK, data = airOnTimeDataXdf)
adsSummary


########## Build Logistic Regression Model with Hadoop ##########
# Formula to use
formula <- "ARR_DEL15 ~ DISTANCE + DAY_OF_WEEK + DEP_TIME"

# Run a logistic regression and time it
timeHadoop <- system.time(
    modelHadoop <- rxLogit(formula, data = airOnTimeDataXdf)
)

# Display model summary
summary(modelHadoop)


########## Make Predictions with Hadoop ##########
# Make predictions using the logit model
filename <- file.path(bigDataDirRoot, "AirOnTimePredictions")
outputXdf <- RxXdfData(filename, fileSystem = hdfsFS, createCompositeSet = TRUE)
predictions <- rxPredict(modelObject = modelHadoop, data = airOnTimeDataXdf,
			writeModelVars = TRUE, predVarNames = "Score",
			outData = outputXdf, overwrite = TRUE)

# Print results
rxGetInfo(predictions, getVarInfo = TRUE, numRows = 5)


#####################################################
########## Change Compute Context to SPARK ##########
# Define the Spark compute context 
mySparkCluster <- rxSparkConnect(consoleOutput=TRUE)
# Set the compute context 
rxSetComputeContext(mySparkCluster)


########## Build Model with SPARK ##########
# Formula to use
formula <- "ARR_DEL15 ~ DISTANCE + DAY_OF_WEEK + DEP_TIME"

# Run a logistic regression and time it
timeSpark <- system.time(
    modelSpark <- rxLogit(formula, data = airOnTimeDataXdf)
)

# Display model summary
summary(modelSpark)


########## Make Predictions with Spark ##########
# Make predictions using the logit model
filename <- file.path(bigDataDirRoot, "AirOnTimePredictions")
outputXdf <- RxXdfData(filename, fileSystem = hdfsFS, createCompositeSet = TRUE)
predictions <- rxPredict(modelObject = modelSpark, data = airOnTimeDataXdf,
			writeModelVars = TRUE, predVarNames = "Score",
			outData = outputXdf, overwrite = TRUE)

# Print results
rxGetInfo(predictions, getVarInfo = TRUE, numRows = 5)

rxSparkDisconnect()

# Compare model building timings
cbind(timeHadoop, timeSpark)
