### Path Analysis using satisfaction dataset

# Install and load plspm library
install.packages("plspm", dependencies = TRUE)
library(plspm)

# load dataset satisfaction
data(satisfaction)

# Path matrix - defines the dependencies between the different categories
# IMAG - image, EXPE - experience, QUAL - Quality, VAL - Value, SAT - satisfaction, LOY - loyalty
IMAG <- c(0,0,0,0,0,0)
EXPE <- c(1,0,0,0,0,0)
QUAL <- c(0,1,0,0,0,0)
VAL  <- c(0,1,1,0,0,0)
SAT  <- c(1,1,1,1,0,0)
LOY  <- c(1,0,0,0,1,0)
sat_path = rbind(IMAG, EXPE, QUAL, VAL, SAT, LOY)

# Plot diagram of path matrix - shows the linkages/dependencies between the categories
innerplot(sat_path)

# Blocks of outer model - indicates which values in the satisfaction data set correspond to each category
sat_blocks = list(1:5, 6:10, 11:15, 16:19, 20:23, 24:27)

# Vector of modes (reflective indicators)
sat_mod = rep("A", 6)

# Apply plspm
# satisfaction is the data set (scores for each category)
# sat_path is the path matrix (pathways)
# sat_blocks indicates which values in the data set relate to each category
# modes indicates the type of measurement for each category - here A means reflective
# scaled indicates whether the data values should be normalized (0 equals mean)
satpls = plspm(satisfaction, sat_path, sat_blocks, modes = sat_mod, scaled = FALSE)

# Plot diagram of the inner model showing the weights for each dependency
innerplot(satpls)

# Plot loadings - shows the correlations between the categories and their variables in the data set. Larger
# value equates to stronger correlation; meaning it is more closely related
outerplot(satpls, what = "loadings")

# Plot outer weights - shows the weights between the categories and their variables in the data set.
# Larger weights indicates the variable has more impact on the category.
outerplot(satpls, what = "weights")
