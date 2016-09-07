### Data Exploration Examples 

# Set to local parallel compute context and disable progress reporting
rxSetComputeContext(RxLocalParallel())
rxOptions(reportProgress = 0)

# Get help on rxOptions
?rxOptions
# And see available options
names(rxOptions())

# Check out available sample datasets
sample.data.dir <- rxOptions()$sampleDataDir
dir(sample.data.dir)

# Load Dow Jones dataset, and get basic info 
dow.jones <- file.path(sample.data.dir, "DJIAdaily.xdf") 
rxGetInfo(dow.jones)

# Get info on dataset variables
rxGetInfo(dow.jones, getVarInfo = TRUE)

# Print first 5 rows
rxGetInfo(dow.jones, numRows = 5)

# Assign the rxGetInfo output to a new variable
var.info <- rxGetVarInfo(dow.jones)
var.info

# Fetch its class and structure
class(var.info)
str(var.info)

# Fetch mores structure info
names(var.info)
class(var.info[[1]])
var.info[["Open"]]
class(var.info[["Open"]])

# Drill down futher into the structure by names 
names(var.info[["Open"]])
var.info[["Open"]][["storage"]]
names(var.info[["DayOfWeek"]])
var.info[["DayOfWeek"]][["levels"]]

# Get summary statistics on the Open field
rxSummary(formula = ~Open, data = dow.jones)

# Get summary statistics on several fields
rxSummary(formula = ~Open + High + Low + Close,
          data = dow.jones)

# Get summary statistics on all the fields
rxSummary(formula = ~.,
          data = dow.jones)

# Calculate quantiles of the Open field
rxQuantile(varName = "Open",
           data = dow.jones)

# Plot histogram on Open field
rxHistogram(formula = ~Open,
            data = dow.jones, 
            xNumTicks = 10)

# Plot barchart for factor data DayOfWeek
rxHistogram(formula = ~ DayOfWeek, 
            data = dow.jones)  

# Facet multiple histograms: Open field grouped by DayofWeek
rxHistogram(formula = ~ Open | DayOfWeek, 
            data = dow.jones, 
            xNumTicks = 10) 

# Plot weighted histogram
rxHistogram(formula = ~ Open, 
            data = dow.jones, 
            fweights = "Volume", 
            xNumTicks = 10)

# Display line plot (time series data)
rxLinePlot(formula = Open ~ DaysSince1928,
           data = dow.jones)

# Display line plot of log of data
rxLinePlot(formula = log(Open) ~ DaysSince1928,
           data = dow.jones)

# Create cross tablutation results (counts) for DayOfWeek
rxCrossTabs(formula = ~DayOfWeek,
            data = dow.jones)

# Create new field, ClosedHigher
dow.jones <- rxDataStep(inData = dow.jones,
                        transforms = list(ClosedHigher = Close > Open))

# Print first 5 rows
rxGetInfo(dow.jones, numRows = 5)

# Create contingency table (counts), grouping by DayOfWeek and ClosedHigher
rxCube(formula = ~DayOfWeek : F(ClosedHigher),
            data = dow.jones)
