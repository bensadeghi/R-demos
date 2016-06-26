### Logistic regression. Used to predict the probability of a variable taking the values 0 or 1 (true, false)
#read in a dataset that survey results of agree/disagree to the questions, with details of the gender and 
#education of the responders. We'll use logistic regression to attempt to predict responses based upon gender
#and eduction

# Install HSAUR library and load womensrole dataset
install.packages("HSAUR", dependencies = TRUE)
data("womensrole", package="HSAUR")
womensrole

#Create a function to plot the predicted results with a best fit curve
myplot <- function(role.fitted) 
{ 
  f <- womensrole$sex == "Female"
  plot(womensrole$education, role.fitted, type = "n",
       ylab = "Probability of agreeing",
       xlab = "Education", ylim = c(0,1))
  lines(womensrole$education[!f], role.fitted[!f], lty = 1) 
  lines(womensrole$education[f], role.fitted[f], lty = 2) 
  lgtxt <- c("Fitted (Males)", "Fitted (Females)") 
  legend("topright", lgtxt, lty = 1:2, bty = "n") 
  y <- womensrole$agree / (womensrole$agree + + womensrole$disagree) 
  text(womensrole$education, y, ifelse(f, "\\VE", "\\MA"), 
       family = "HersheySerif", cex = 1.25) 
}

# Create a model to be used by the logistic regression function; here it is a combination of gender plus education 
fm1 <- cbind(agree, disagree) ~ sex + education 

# Create the logistic model
survey_glm_1 <- glm(fm1, data = womensrole,  family = binomial())

# Generate predictions using the logistic regression model
role.fitted1 <- predict(survey_glm_1, type = "response") 
summary(survey_glm_1)

# Plot the predicted values
myplot(role.fitted1)

# Create another function to create a second logistic regression model; this time gender multiplied by education
fm2 <- cbind(agree,disagree) ~ sex * education 

# Create the logistic model
survey_glm_2 <- glm(fm2, data = womensrole, family = binomial())

# Generate predictions using the logistic regression model
role.fitted2 <- predict(survey_glm_2, type = "response") 
summary(survey_glm_2)

# Plot the predicted values
myplot(role.fitted2)
