### Importing Data - Methods for importing text, CSV, SAS, SPSS data

rxSetComputeContext(RxLocalParallel())

# Check data source directory
readPath <- rxGetOption("sampleDataDir")
print(readPath)
# Check data files
list.files(rxGetOption("sampleDataDir"))

# Importing Delimited Text Data
infile <- file.path(readPath, "claims.txt")
claimsDF <- rxImport(infile)
rxGetInfo(claimsDF, getVarInfo = TRUE)

# Importing Text Data and Rewriting in XDF Format
claimsDS <- rxImport(inData = infile, outFile = "claims.xdf")
rxGetInfo(claimsDS, getVarInfo = TRUE)

# Importing CSV Data and Rewriting in XDF Format
inFile <- file.path(readPath, "AirlineDemoSmall.csv")
airData <- rxImport(inData = inFile, outFile = "airExample.xdf",
    stringsAsFactors = TRUE, missingValueString = "M",
    rowsPerRead = 200000, overwrite = TRUE)
rxGetInfo(airData, getVarInfo = TRUE)

# Importing Fixed Format STS Data
inFile <- file.path(readPath, "claims.sts")
claimsFF <- rxImport(inData = inFile, outFile = "claimsFF.xdf")
rxGetInfo(claimsFF, getVarInfo = TRUE)

# Importing Fixed Format DAT Data
inFileNS <- file.path(readPath, "claims.dat")
outFileNS <- "claimsNS.xdf"
colInfo = list("rownum" = list(start = 1, width = 3, type = "integer"),
             "age" = list(start = 4, width = 5, type = "factor"),
             "car.age" = list(start = 9, width = 3, type = "factor"),
             "type" = list(start = 12, width = 1, type = "factor"),
             "cost" = list(start = 13, width = 6, type = "numeric"),
             "number" = list(start = 19, width = 3, type = "numeric"))
claimsNS <- rxImport(inFileNS, outFile = outFileNS, colInfo = colInfo)
rxGetInfo(claimsNS, getVarInfo = TRUE)

# Importing SAS Data
inFileSAS <- file.path(readPath, "claims.sas7bdat")
xdfFileSAS <- "claimsSAS.xdf"
claimsSAS <- rxImport(inData = inFileSAS, outFile = xdfFileSAS)
rxGetInfo(claimsSAS, getVarInfo = TRUE)

# Importing SPSS Data
inFileSpss <- file.path(readPath, "claims.sav")
xdfFileSpss <- "claimsSpss.xdf"
claimsSpss <- rxImport(inData = inFileSpss, outFile = xdfFileSpss)
rxGetInfo(claimsSpss, getVarInfo = TRUE)

# Specifying Additional Variable Information
inFileAddVars <- file.path(readPath, "claims.txt")
outfileTypeRelabeled <- "claimsTypeRelabeled.xdf"
colInfoList <- list("type" = list(type = "factor", levels = c("A",
    "B", "C", "D"), newLevels = c("Subcompact", "Compact", "Mid-size",
    "Full-size"), description = "Body Type"))
claimsNew <- rxImport(inFileAddVars, outFile = outfileTypeRelabeled,
    colInfo = colInfoList)
rxGetInfo(claimsNew, getVarInfo = TRUE)

# Transforming Data on Import
inFile <- file.path(readPath, "claims.txt")
outfile <- "claimsXform.xdf"
claimsDS <- rxImport(inFile, outFile = outfile,
    transforms = list(logcost = log(cost)))
rxGetInfo(claimsDS, getVarInfo = TRUE)

# Reading Data from an XDF File into a Data Frame
inFile <- file.path(readPath, "CensusWorkers.xdf")
myCensusDF <- rxDataStep(inData = inFile,
  rowSelection = state == "Washington" & age > 40,
  varsToKeep = c("age", "perwt", "sex"))
str(myCensusDF)
