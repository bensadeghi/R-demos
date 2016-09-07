### Data Manipulation Examples using rxDataStep

# Set to local parallel compute context and disable progress reporting
rxSetComputeContext(RxLocalParallel())
rxOptions(reportProgress = 0)

# Define data directories
output.path <- getwd()
sample.data.dir <- rxOptions()[["sampleDataDir"]]

# Set path to input file, and print first 5 rows
mortgagesIn <- file.path(sample.data.dir, "mortDefaultSmall.xdf")
rxGetInfo(mortgagesIn, numRows = 5)
# Set path to output xdf file
mortgagesOut <- file.path(output.path, "mortDefaultSmall.xdf")

# Perform simple transformation, adding new field experiencedWorker, and write results to output file
rxDataStep(inData = mortgagesIn,
           outFile = mortgagesOut,
           transforms = list(experiencedWorker = yearsEmploy >= 5),
           overwrite = TRUE)
# Fetch variable info
rxGetInfo(data = mortgagesOut, getVarInfo = TRUE)

# Plot histogram of experiencedWorker field
rxHistogram( ~ experiencedWorker, data = mortgagesOut)

# Create new data file, keeping yearsEmploy field and adding experiencedWorker field
subSet <- file.path(output.path, "subSetMortgagesOut.xdf")
rxDataStep(inData = mortgagesIn, 
           outFile = subSet,
           varsToKeep = "yearsEmploy",
           transforms = list(experiencedWorker = yearsEmploy >= 5), 
           append = "none",
           overwrite = TRUE)
# Fetch variable info
rxGetVarInfo(subSet)

# Get the min and max credit scores
minScore <- rxGetVarInfo(mortgagesIn)[["creditScore"]][["low"]]
maxScore <- rxGetVarInfo(mortgagesIn)[["creditScore"]][["high"]]

# Define transform function to normalize
simply_normalize <- function(lst) {
    lst[["normCreditScore"]] <- (lst[["creditScore"]] - minCreditScore) / (maxCreditScore - minCreditScore)
    lst[["moreThanHalf"]] <- lst[["normCreditScore"]] > 0.5
    return(lst)
}

# Use the normalization transform function to append two new fields 
rxDataStep(inData = mortgagesIn,
           outFile = mortgagesOut,
           transformFunc = simply_normalize,
           transformObjects = list(minCreditScore = minScore, maxCreditScore = maxScore),
           overwrite = TRUE)
# Fetch variable info
rxGetVarInfo(data = mortgagesOut)

# Print statistical summary of new fields
rxSummary( ~ normCreditScore + moreThanHalf, data = mortgagesOut)

# Histogram of normCreditScore field
rxHistogram( ~ normCreditScore,
            data = mortgagesOut, 
            xnNumTicks = 10)
