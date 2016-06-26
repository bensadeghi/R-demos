### Statistical Tests

### One Sample t-Test ###
# It is a parametric test used to test if the mean of a sample from a normal distribution could reasonably be a specific value

set.seed(100)
x <- rnorm(50, mean = 10, sd = 0.5)
t.test(x, mu = 10)

# In above case, the p - Value is not less than significance level of 0.05,
# therefore the null hypothesis that the mean = 10 cannot be rejected.
# Also note that the 95 % confidence interval range includes the value 10 within its range.
# So, it is ok to say the mean of ‘x’ is 10, especially since ‘x’ is assumed to be normally distributed.
# In case, a normal distribution is not assumed, use wilcoxon signed rank test shown in next section.



### Wilcoxon Signed Rank Test ###
# To test the mean of a sample when normal distribution is not assumed.
# Wilcoxon signed rank test can be an alternative to t - Test,
# especially when the data sample is not assumed to follow a normal distribution.
# It is a non - parametric method used to test if an estimate is different from its true value.

numeric_vector <- c(20, 29, 24, 19, 20, 22, 28, 23, 19, 19)
wilcox.test(numeric_vector, mu = 20, conf.int = TRUE)

# If p - Value < 0.05, reject the null hypothesis and accept the alternate mentioned in your R code ’s output.
# Type example(wilcox.test) in R console for more illustration.



### Shapiro Test ###
# To test if a sample follows a normal distribution.

set.seed(100)
normaly_disb <- rnorm(100, mean = 5, sd = 1)
shapiro.test(normaly_disb)

# If p - Value is less than the significance level of 0.05,
# the null - hypothesis that it is normally distributed can be rejected, which is the case here.



### Fisher’s F-Test ###
# Fisher ’s F test can be used to check if two samples have same variance.

x <- rnorm(50)
y <- runif(50)
var.test(x, y)



### Correlation ###
# To test the linear relationship of two continuous variables

cor.test(x, y)

# If the p Value is less than 0.05, we reject the null hypothesis that the true correlation is zero (i.e. they are independent).
# So in this case, we reject the null hypothesis and conclude that dist is dependent on speed.



### Chi Squared Test ###
# Chi squared test in R can be used to test if two categorical variables are dependent, by means of a contingency table.

library(MASS)
tbl = table(survey$Smoke, survey$Exer)
tbl                              # the contingency table
chisq.test(tbl)

chisq.test(tbl, correct = FALSE) # Yates continuity correction not applied
# or
summary(tbl)                     # performs a chi-squared test.

# If the p - Value is less that 0.05, we fail to reject the null hypothesis that the x and y are independent.
