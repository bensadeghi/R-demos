### Simple Plotting Examples


# Scatter Plots
x <- rnorm(20, sd = 5, mean = 20)
y <- 2.5 * x - 1.0 + rnorm(10, sd = 9, mean = 0)
plot(x, y, xlab = "Independent", ylab = "Dependent", main = "Random Stuff")

x1 <- runif(25, 15, 25)
y1 <- 2.5 * x1 - 1.0 + runif(8, -6, 6)
points(x1, y1, col = 2)

plot(x, y, xlab = "Independent", ylab = "Dependent", main = "Random Stuff")
points(x1, y1, col = 2, pch = 3)
legend(14, 70, c("Original", "New"), col = c(1, 2), pch = c(1, 3))


# Error Bars 
plot(x, y, xlab = "Independent", ylab = "Dependent", main = "Random Stuff")
xHigh <- x
yHigh <- y + abs(rnorm(10, sd = 3.5))
xLow <- x
yLow <- y - abs(rnorm(10, sd = 3.1))
arrows(xHigh, yHigh, xLow, yLow, col = 2, angle = 90, length = 0.1, code = 3)


# Adding Noise (jitter)
numberWhite <- rhyper(400, 4, 5, 3)
numberChipped <- rhyper(400, 2, 7, 3)
par(mfrow = c(1, 2))
plot(numberWhite, numberChipped, xlab = "Number White Marbles Drawn",
       ylab = "Number Chipped Marbles Drawn", main = "Pulling Marbles")
plot(jitter(numberWhite), jitter(numberChipped), xlab = "Number White Marbles Drawn",
       ylab = "Number Chipped Marbles Drawn", main = "Pulling Marbles With Jitter")


# Boxplots
data <- data.frame(
    Stat21 = rnorm(100, mean = 4, sd = 1),
    Stat31 = rnorm(100, mean = 6, sd = 0.5),
    Stat41 = runif(100)*5,
    Stat12 = rnorm(100, mean = 4, sd = 2))
boxplot(data, col = c(2, 3, 4, 5))


# Histogram
hist(numberWhite)


# Mosaic
mosaicplot(table(numberWhite, numberChipped), col=c(2,3,4))


# Multiple Graphs on One Image, including Box Plots, Historgrams and Mosaic Plot
par(mfrow = c(2, 3))
boxplot(numberWhite, main = "first plot")
boxplot(numberChipped, main = "second plot")
plot(jitter(numberWhite), jitter(numberChipped), xlab = "Number White Marbles Drawn",
       ylab = "Number Chipped Marbles Drawn", main = "Pulling Marbles With Jitter")
hist(numberWhite, main = "fourth plot")
hist(numberChipped, main = "fifth plot")
mosaicplot(table(numberWhite, numberChipped), main = "sixth plot")


# Density Plots
layout(matrix(1, nrow = 1))
numberWhite <- rhyper(30, 4, 5, 3)
numberChipped <- rhyper(30, 2, 7, 3)
smoothScatter(numberWhite, numberChipped,
             xlab = "White Marbles", ylab = "Chipped Marbles",main="Drawing Marbles")


# Pairwise Relationships
uData <- rnorm(25)
vData <- rnorm(25, mean = 5)
wData <- uData + 2 * vData + rnorm(20, sd = 0.5)
xData <- -2 * uData + rnorm(20, sd = 0.1)
yData <- 3 * vData + rnorm(20, sd = 2.5)
d <- data.frame(u = uData, v = vData, w = wData, x = xData, y = yData)
pairs(d)


# Shaded Regions
stdDev <- 0.75;
x <- seq(-5, 5, by = 0.01)
y <- dnorm(x, sd = stdDev)
right <- qnorm(0.95, sd = stdDev)
plot(x, y, type = "l", xaxt = "n", ylab = "p",
       xlab = expression(paste('Assumed Distribution of ', bar(x))),
       axes = FALSE, ylim = c(0, max(y) * 1.05), xlim = c(min(x), max(x)),
       frame.plot = FALSE)
axis(1, at = c(-5, right, 0, 5),
       pos = c(0, 0),
       labels = c(expression(' '), expression(bar(x)[cr]), expression(mu[0]), expression(' ')))
axis(2)
xReject <- seq(right, 5, by = 0.01)
yReject <- dnorm(xReject, sd = stdDev)
polygon(c(xReject, xReject[length(xReject)], xReject[1]),
          c(yReject, 0, 0), col = 'red')


# Plotting a Surface
x <- seq(0, 2 * pi, by = pi / 100)
y <- x
xg <- (x * 0 + 1) %*% t(y)
yg <- (x) %*% t(y * 0 + 1)
f <- sin(xg + yg)
persp(x, y, f, theta = -10, phi = 40)


# Heatmap
iris2 = iris
rownames(iris2) = make.names(iris2$Species, unique = T)
iris2$Species <- NULL
iris2 = as.matrix(iris2)
heatmap(iris2)


# Bubble Plot
iris2 <- iris[sample(nrow(iris), 20),]
symbols(iris2$Sepal.Length, iris2$Sepal.Width, circles = iris2$Petal.Length, bg="red")


# TreeMap
install.packages("portfolio", dependencies = TRUE)
library(portfolio)
data <- read.csv("http://datasets.flowingdata.com/post-data.txt")
map.market(id = data$id, area = data$views, group = data$category,
            color = data$comments, main = "FlowingData Map")


# Trellis (Lattice) Chart
install.packages("lattice", dependencies = TRUE)
library(lattice)
my.theme = trellis.par.get()
show.settings()
# or
install.packages("mlmRev", dependencies = TRUE)
data(Chem97, package = "mlmRev")
histogram( ~ gcsescore | factor(score), data = Chem97)
densityplot( ~ gcsescore | factor(score), Chem97,
             groups = gender, plot.points = FALSE, auto.key = TRUE)
qqmath( ~ gcsescore | factor(score), Chem97, groups = gender,
             f.value = ppoints(100), auto.key = TRUE, type = c("p", "g"), aspect = "xy")


# Bullet Graph
install.packages("ggplot2", dependencies = TRUE)
library(ggplot2)
bullet.graph <- function(bg.data) {
    max.bg <- max(bg.data$high)
    mid.bg <- max.bg / 2
    gg <- ggplot(bg.data)
    gg <- gg + geom_bar(aes(measure, high), fill = "goldenrod2", stat = "identity", width = 0.5, alpha = 0.2)
    gg <- gg + geom_bar(aes(measure, mean), fill = "goldenrod3", stat = "identity", width = 0.5, alpha = 0.2)
    gg <- gg + geom_bar(aes(measure, low), fill = "goldenrod4", stat = "identity", width = 0.5, alpha = 0.2)
    gg <- gg + geom_bar(aes(measure, value), fill = "black", stat = "identity", width = 0.2)
    gg <- gg + geom_errorbar(aes(y = target, x = measure, ymin = target, ymax = target), color = "red", width = 0.45)
    gg <- gg + geom_point(aes(measure, target), colour = "red", size = 2.5)
    gg <- gg + scale_y_continuous(breaks = seq(0, max.bg, mid.bg))
    gg <- gg + coord_flip()
    gg <- gg + theme(axis.text.x = element_text(size = 5),
                   axis.title.x = element_blank(),
                   axis.line.y = element_blank(),
                   axis.text.y = element_text(hjust = 1, color = "black"),
                   axis.ticks.y = element_blank(),
                   axis.title.y = element_blank(),
                   legend.position = "none",
                   panel.background = element_blank(),
                   panel.border = element_blank(),
                   panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(),
                   plot.background = element_blank())
    return(gg)
}
incidents.pct <- data.frame(
      measure = c("Total Events (%)", "Security Events (%)", "Filtered (%)", "Tickets (%)"),
      high = c(100, 100, 100, 100),
      mean = c(45, 40, 50, 30),
      low = c(25, 20, 10, 5),
      target = c(55, 40, 45, 35),
      value = c(50, 45, 60, 25))
bullet.graph(incidents.pct)
