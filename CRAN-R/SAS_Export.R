### Demonstrate exporting of SAS dataset

install.packages("Hmisc", dependencies = TRUE)
library(Hmisc)

data <- sasxport.get("./data/SAS_data.xpt")

# character variables are converted to R factors
data

# Print structure
str(data)

# Print summary
summary(data)
