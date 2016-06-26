### Marimekko Chart

# Install and load packages
install.packages("ggplot2", dependencies = TRUE)
install.packages("reshape2", dependencies = TRUE)
install.packages("plyr", dependencies = TRUE)
install.packages("TDMR", dependencies = TRUE)

library(ggplot2)
library(reshape2)
library(plyr)
library(TDMR)

df <- data.frame(segment = c("A", "B", "C","D"), segpct = c(40, 30, 20, 10), Alpha = c(60,40, 30, 25), Beta = c(25, 30, 30, 25),Gamma = c(10, 20, 20, 25), Delta = c(5,10, 20, 25))

df$xmax <- cumsum(df$segpct)
df$xmin <- df$xmax - df$segpct
df$segpct <- NULL

dfm <- melt(df, id = c("segment", "xmin", "xmax"))

dfm1 <- ddply(dfm, .(segment), transform, ymax = cumsum(value))
dfm1 <- ddply(dfm1, .(segment), transform,ymin = ymax - value)

dfm1$xtext <- with(dfm1, xmin + (xmax - xmin)/2)
dfm1$ytext <- with(dfm1, ymin + (ymax - ymin)/2)

p <- ggplot(dfm1, aes(ymin = ymin, ymax = ymax,xmin = xmin, xmax = xmax, fill = variable))

p1 <- p + geom_rect(colour = I("grey"))
p2 <- p1 + geom_text(aes(x = xtext, y = ytext,label = ifelse(segment == "A", 
                                                             paste(variable," - ", value, "%", sep = ""), 
                                                             paste(value,"%", sep = ""))), size = 3.5)

p3 <- p2 + geom_text(aes(x = xtext, y = 103,label = paste("Seg ", segment)), size = 4)

p3 + theme_bw() + labs(x = NULL, y = NULL, fill = NULL) + Opts(legend.position = "none",
                                           panel.grid.major = theme_line(colour = NA),
                                           panel.grid.minor = theme_line(colour = NA))

last_plot() + scale_fill_brewer(palette = "Set2")
