### Linear regression using clouds dataset

# Install HSAUR library and load womensrole dataset
install.packages("HSAUR", dependencies = TRUE)
data("clouds", package="HSAUR")
clouds

# Bloxplots used to show distribution of rainfall in relation to seeding and echo motion
layout(matrix(1:2, nrow = 2))
bxpseeding <- boxplot(rainfall ~ seeding, data = clouds, ylab = "Rainfall", xlab = "Seeding") 
bxpecho <- boxplot(rainfall ~ echomotion, data = clouds, ylab = "Rainfall", xlab = "Echo Motion")

# Plots used to view how rainfall varies by different parameters, including time, cloud cover, sne and prewetness
layout(matrix(1:4, nrow = 2)) 
plot(rainfall ~ time, data = clouds) 
plot(rainfall ~ cloudcover, data = clouds) 
plot(rainfall ~ sne, data = clouds, xlab="S-Ne criterion") 
plot(rainfall ~ prewetness, data = clouds)

# lm function can be used for linear regression in R
# lm function requires a formulae indicating the variable you are trying to predict (rainfall) and the model that
# will be used for the modeling. The model is composed of the dependent variables (factors influencing rainfall)
clouds_formula <- rainfall ~ seeding * (sne + cloudcover + prewetness + echomotion) + time 
clouds_lm <- lm(clouds_formula, data = clouds) 

# Resulting linear regression model can be viewed using summary. Key values are the residuals which are the differences
# between the predicted and actual values (smaller is better).
summary(clouds_lm)

# Can know view the model using a plot. This plot contains rainfall verses sne, and adds lines using predicted values from
# the lm model, with and without seeding
psymb <- as.numeric(clouds$seeding)
layout(matrix(1, nrow = 1))
plot(rainfall ~ sne, data = clouds, pch = psymb,  xlab = "S-Ne criterion") 
abline(lm(rainfall ~ sne, data = clouds,  subset = seeding == "no")) 
abline(lm(rainfall ~ sne, data = clouds,  subset = seeding == "yes"), lty = 2) 
legend("topright", legend = c("No seeding", "Seeding"),  pch = 1:2, lty = 1:2, bty = "n")

# Extracts the residuals and fitted values (calculated predictions)
clouds_resid <- residuals(clouds_lm) 
clouds_fitted <- fitted(clouds_lm)

# Plots the fitted values and residuals
plot(clouds_fitted, clouds_resid, xlab = "Fitted values", 
      ylab = "Residuals", type = "n", 
      ylim = max(abs(clouds_resid)) * c(-1, 1)) 
abline(h = 0, lty = 2) 
text(clouds_fitted, clouds_resid, labels = rownames(clouds))

# Plot the quartiles for the residuals and adds a best fit line. 
qqnorm(clouds_resid, ylab = "Residuals") 
qqline(clouds_resid)

