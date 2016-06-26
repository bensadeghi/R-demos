### Collaborative Filtering Examples

# Install and load recommenderlab package
install.packages("recommenderlab", dependencies = TRUE)
library("recommenderlab")

#  Create a small artiﬁcial data set as a matrix
m <- matrix(sample(c(as.numeric(0:5), NA), 50,
            replace = TRUE, prob = c(rep(.4 / 6, 6), .6)),
            ncol = 10, dimnames = list(user = paste("u", 1:5, sep = ''),
            item = paste("i", 1:10, sep = '')))
m

# Convert matrix into a realRatingMatrix object which stores the data in sparse format
# Fetch the ratings back
ratings <- as(m, "realRatingMatrix")
ratings@data

# Create histogram of ratings
hist(getRatings(ratings))

# Visually inspect the ratings
image(ratings, main = "Normalized Ratings")


# Create a recommender using ratings from users 1:4
rec <- Recommender(ratings[1:4], method = "POPULAR")
rec

# Obtain model from the recommender
names(getModel(rec))
getModel(rec)$topN

# Make 2 item recommendations for user 5
recommendations <- predict(rec, ratings[5], n = 2)
as(recommendations, "list")

# Make item rating predictions for user 5
recom <- predict(rec, ratings[5], type = "ratings")
as(recom, "matrix")
