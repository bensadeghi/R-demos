### RxHadoop & RxSpark Contexts
### Build decision forest model to predict mortgage defaults

####### Fetch Data #######
# Download data to the tmp folder
remoteDir <- "http://packages.revolutionanalytics.com/datasets"
download.file(file.path(remoteDir, "mortDefault.tar.gz"), "/tmp/mortDefault.tar.gz", method = "wget")
# Decompress files
Sys.setenv(TAR = "/bin/tar")
untar("/tmp/mortDefault.tar.gz", exdir = "/tmp", compressed = "gzip")

# Set the HDFS (WASB) location of example data
bigDataDirRoot <- "/example/data"
# Set directory in bigDataDirRoot to load the data into
inputDir <- file.path(bigDataDirRoot, "mortDefault") 

# Make the directory
rxHadoopMakeDir(inputDir)
# Copy the data from source to input
source <- "/tmp/mortDefault"
rxHadoopCopyFromLocal(source, bigDataDirRoot)
# List files copied onto Hadoop
rxHadoopListFiles(inputDir)


####### Format Data #######
# Create info list for the mortgage data
mortage_ColInfo <- list(
    creditScore = list(type = "integer"),
    houseAge = list(type = "integer"),
    yearsEmploy = list(type = "integer"),
    ccDebt = list(type = "integer"),
    default = list(type = "logical"))

# Get all the column names
varNames <- names(mortage_ColInfo)


####### Set Hadoop Compute Context #######
myHadoopCluster <- RxHadoopMR(consoleOutput=TRUE)
# Set the compute context 
rxSetComputeContext(myHadoopCluster)
# Define the HDFS file system
hdfsFS <- RxHdfsFileSystem()

# Define the text data source in HDFS
mortgageDataTxt <- RxTextData(inputDir, colInfo = mortage_ColInfo, varsToKeep = varNames, fileSystem = hdfsFS)

# Define XDF file and import from CSV data in HDFS
filename <- file.path(bigDataDirRoot, "MortgageData")
mortgageDataXdf <- RxXdfData(filename, fileSystem = hdfsFS )
rxImport(inData = mortgageDataTxt, outFile = mortgageDataXdf,
         rowsPerRead = 250000, overwrite = TRUE, numRows = -1)

# Compute summary information
mdSummary <- rxSummary(~ ., data = mortgageDataXdf)
mdSummary


####### Build Decision Forest Model with Hadoop M/R #######
# Use all fields to predict default
myFormula <- "default ~ creditScore + houseAge + yearsEmploy + ccDebt" 

# Build model using above formula and time it
timeHadoop <- system.time(
    hadoopModel <- rxDForest(myFormula, data = mortgageDataXdf,
                             nTree = 2, maxDepth = 2)
)

# Print trees of forest model
hadoopModel$forest


####### Make Predictions with Hadoop #######
filename <- file.path(bigDataDirRoot, "MortgagePredictions")
outputXdf <- RxXdfData(filename, fileSystem = hdfsFS, createCompositeSet = TRUE)
predictions <- rxPredict(modelObject = hadoopModel, data = mortgageDataXdf, 
     writeModelVars = TRUE, predVarNames = "Score",
     outData = outputXdf, overwrite = TRUE)

rxGetInfo(predictions, getVarInfo = TRUE, numRows = 5)


##############################################
####### Change Compute Conext to Spark #######
# Define the Spark compute context 
mySparkCluster <- rxSparkConnect(consoleOutput=TRUE)
# Set the compute context 
rxSetComputeContext(mySparkCluster)


####### Build Model with Spark #######
# Use all fields to predict default
myFormula <- "default ~ creditScore + houseAge + yearsEmploy + ccDebt" 

# Build model using above formula and time it
timeSpark <- system.time(
    sparkModel <- rxDForest(myFormula, data = mortgageDataXdf,
                            nTree = 2, maxDepth = 2)
)

# Print trees of forest model
sparkModel$forest


####### Make Predictions with Spark #######
filename <- file.path(bigDataDirRoot, "MortgagePredictions")
outputXdf <- RxXdfData(filename, fileSystem = hdfsFS, createCompositeSet = TRUE)
predictions <- rxPredict(modelObject = sparkModel, data = mortgageDataXdf, 
     writeModelVars = TRUE, predVarNames = "Score",
     outData = outputXdf, overwrite = TRUE)

rxGetInfo(predictions, getVarInfo = TRUE, numRows = 5)

rxSparkDisconnect()

# Compare model building timings
cbind(timeHadoop, timeSpark)
