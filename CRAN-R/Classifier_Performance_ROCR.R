### Visualizing the Performance of Scoring Classiﬁers via ROCR

# Install and load ROCR package
install.packages("ROCR", dependencies = TRUE)

library("ROCR")

# Fetch hiv data
# Predictions made by 10-fold CV - SVM classifier
data(ROCR.hiv)
pp <- ROCR.hiv$hiv.svm$predictions
ll <- ROCR.hiv$hiv.svm$labels

# Create ROCR prediction object
pred <- prediction(pp, ll)

# Set plot figure as 2x2 grid
par(mfrow = c(2, 2))

# Plot ROC Curve
perf <- performance(pred, "tpr", "fpr")
plot(perf, avg = "threshold", colorize = T, lwd = 3,
     main = "ROC Curve")

# Plot Precision/Recall
perf <- performance(pred, "prec", "rec")
plot(perf, avg = "threshold", colorize = T, lwd = 3,
     main = "Precision/Recall")

# Plot Sensitivity/Specificity
perf <- performance(pred, "sens", "spec")
plot(perf, avg = "threshold", colorize = T, lwd = 3,
     main = "Sensitivity/Specificity")

# Plot Lift Curve
perf <- performance(pred, "lift", "rpp")
plot(perf, avg = "threshold", colorize = T, lwd = 3,
     main = "Lift Curve")

# Calculate Area Under ROC Curve (AUC) for the 10 folds
perf <- performance(pred, "auc")
print(perf@y.values)
