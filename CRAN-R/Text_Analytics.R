### Text Analytics and Word Cloud of MLK speech

install.packages("tm", dependencies = TRUE)
install.packages("wordcloud", dependencies = TRUE)
install.packages("RColorBrewer", dependencies = TRUE)
library(tm)
library(wordcloud)
library(RColorBrewer)

# Fetch MLK speech text
filepath <- "http://www.sthda.com/sthda/RDoc/example-files/martin-luther-king-i-have-a-dream-speech.txt"
text <- readLines(filepath)
text

# Create a corpus
corpus <- Corpus(VectorSource(text))

# Create document term matrix applying some transformations
tdm <- TermDocumentMatrix(corpus,
   control = list(removePunctuation = TRUE,
   stopwords = stopwords("english"),
   removeNumbers = TRUE, tolower = TRUE))

# Define tdm as matrix
m <- as.matrix(tdm)

# Get word counts in decreasing order
word_freqs <- sort(rowSums(m), decreasing = TRUE)
head(word_freqs)

# Create a data frame with words and their frequencies
dm <- data.frame(word = names(word_freqs), freq = word_freqs)

# Plot wordcloud
wordcloud(dm$word, dm$freq, random.order = FALSE, colors = brewer.pal(8, "Dark2"))
