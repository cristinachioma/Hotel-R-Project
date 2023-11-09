# Installation of packages
packages <- c("tm", "stringr")
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load packages
lapply(packages, require, character.only = TRUE)

# Load data
HotelReviews <- read.csv("HotelReviews.csv", stringsAsFactors = FALSE)

# Summary and structure
View(HotelReviews)
summary(HotelReviews)
str(HotelReviews)

# Visualization of rating
barplot(table(HotelReviews$reviews.rating), 
        main = "reviews.rating", xlab = "Rating", ylab = "Count", col = "blue")

# Geographical Distribution of rating
plot(HotelReviews$city, HotelReviews$reviews.rating, 
     main = "Scatter Plot of Review Score vs. Price", xlab = "Price", ylab = "Review Score")

# Group by review rating and count occurrences of "Good" and "Bad"
rating_counts <- HotelReviews %>%
  group_by(reviews.rating) %>%
  summarize(Good_Count = sum(sapply(reviews.title, function(doc) str_count(doc, "good"))),
            Bad_Count = sum(sapply(reviews.title, function(doc) str_count(doc, "bad"))))

# Checking Missing values
is.na(HotelReviews)

# Omit the missing values from the data and rename the new data to HotelReviews
HotelReviews <- na.omit(HotelReviews)
library(ggplot2)

# Create a histogram for reviews ratings
hist(HotelReviews$reviews.rating, main = "Distribution of Ratings", xlab = "Rating")

## Time Series Analysis
# Convert "reviews.date" to Date format
HotelReviews$reviews.date <- as.Date(HotelReviews$reviews.date)

# Line chart of ratings over time
ggplot(HotelReviews, aes(x = reviews.date, y = reviews.rating)) +
  geom_line(color = "purple") +
  labs(title = "Ratings Over Time", x = "Date", y = "Rating")

## Correlation Analysis
# Calculate correlations between numeric variables
correlation_matrix <- cor(HotelReviews[, c("reviews.rating", "latitude", "longitude")])

# Outlier Detection
# Box plot of ratings
ggplot(HotelReviews, aes(y = reviews.rating)) +
  geom_boxplot(fill = "orange") +
  labs(title = "Box Plot of Ratings")

# Relationship between latitude and longitude
ggplot(data = HotelReviews, aes(x = longitude, y = latitude)) +
  geom_point(color="blue")+
  ggtitle("Relationship between latitude and longitude")+
  theme_bw()

## Handling Outliers: Method of Inter Quratile ranges
ratings <- HotelReviews$reviews.rating
Q1 <- quantile(ratings, 0.25)
Q3 <- quantile(ratings, 0.75)
IQR <- Q3 - Q1
lower_limit <- Q1 - 1.5 * IQR
upper_limit <- Q3 + 1.5 * IQR
outliers <- ratings[ratings < lower_limit | ratings > upper_limit]; outliers

# Create a scatterplot of ratings
plot(HotelReviews$reviews.rating, main="Scatterplot of Ratings")

# Add points for the outliers (and plot with a color "red" if there is any outlier)
outliers <- ratings[ratings < lower_limit | ratings > upper_limit]
points(outliers, col="red", pch=19)

## Correlation Analysis
# Calculate correlations between numeric variables
correlation_matrix <- cor(HotelReviews[, c("reviews.rating", "latitude", "longitude")]);correlation_matrix
# Linear regression for the reviews rating on a basis of latitudes and longitudes
model <- lm(reviews.rating ~ latitude + longitude, data = HotelReviews_data)
summary(model)

# Sort and identify the top 10 words
top_10_words <- head(sort(word_freq, decreasing = TRUE), 10)
print(top_10_words)

# Count the occurrences of "Good" in the "reviews.title" column
word_to_count <- "good"  # Convert to lowercase to match the text
count_good <- sapply(corpus, function(doc) str_count(doc, word_to_count))
total_good_count <- sum(count_good)

# Print the total count
cat("Total occurrences of 'Good':", total_good_count, "\n")

# Ensure 'reviews.rating' is treated as a factor for proper ordering
rating_counts$reviews.rating <- factor(rating_counts$reviews.rating, levels = 1:5)

# Print the counts
print(rating_counts)

# Create a bar chart
library(ggplot2)
ggplot(rating_counts, aes(x = Good_Count, y = reviews.rating)) +
  geom_bar(stat = "identity", fill = "blue") +
  labs(title = "Occurrences of 'Good' by Review Rating",
       x = "Number of 'Good' Occurrences",
       y = "Review Rating")

# Create a document-term matrix
dtm <- DocumentTermMatrix(corpus)

# Get word frequencies
word_freq <- row_sums(as.matrix(dtm))

# Ensure 'reviews.rating' is treated as a factor for proper ordering
rating_counts$reviews.rating <- factor(rating_counts$reviews.rating, levels = 1:5)

# Print the counts
print(rating_counts)

# Group by review rating and count occurrences of "Bad" only
rating_counts <- HotelReviews %>%
  group_by(reviews.rating) %>%
  summarize(Bad_Count = sum(sapply(reviews.title, function(doc) str_count(doc, "bad"))))

# Create a bar chart for "Bad" occurrences
library(ggplot2)

ggplot(rating_counts, aes(x = Bad_Count, y = reviews.rating)) +
  geom_bar(stat = "identity", fill = "red") +
  labs(title = "Occurrences of 'Bad' by Review Rating",
       x = "Number of 'Bad' Occurrences",
       y = "Review Rating")

set.seed(1234)
ind <- sample(2, nrow(HotelReviews), replace = TRUE, prob = c(0.7, 0.3))
train.HotelReviews <- HotelReviews[ind == 1, ]  #70%
test.HotelReviews <- HotelReviews [ind == 2, ]  #30%

# Get rid of reviews greater than 5
HotelReviews <- subset(HotelReviews, reviews.rating <= 5)

# Round ratings to the nearrest whole number
HotelReviews$reviews.rating <- round(HotelReviews$reviews.rating)

# Get rid of nul values
HotelReviews <- HotelReviews[complete.cases(HotelReviews$reviews.text), ]

# Get rid of anything without letters
HotelReviews <- HotelReviews[grepl("[a-zA-Z]", HotelReviews$reviews.text), ]

# Get rid of anything with the text as follows: reasoning: too many 0 reviews with this, could be spam
HotelReviews <- subset(HotelReviews, reviews.text != "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

### Looking at the top 10 words for each star review ###

Star_rating <- 5

#Filter x -star reviews
five_star_reviews <- train.HotelReviews %>%
  filter(reviews.rating == Star_rating)

# Tokenize the text into words and remove specified words, we removed 
# subject pronouns,artical and preposition words as well as a few other ones that
# did not help the analysis

exclude_words <- c("the", "and", "was", "a", "the", "in", "on", "at", "by",
                   "with", "to", "of", "an", "for", "as", "is", "it", "i", 
                   "you", "he", "she",
                   "we", "they", "hotel","room", "Room")

# Tokenization

words <- five_star_reviews %>%
  unnest_tokens(word, reviews.text) %>%
  filter(!word %in% exclude_words)

# Count the frequency of each word
word_counts <- words %>%
  count(word, sort = TRUE)

# Select the top 10 words
top_10_words <- word_counts %>%
  slice(1:10)

# Create a bar graph
ggplot(top_10_words, aes(x = reorder(word, -n), y = n)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 10 Words in 5-Star Reviews Train",
       x = "Word",
       y = "Frequency") +
  coord_flip()

SView(HotelReviews)

## Looking at the top word combinations ###
Star_rating <- 0

# Filter x -star reviews
five_star_reviews <- hotelreviews %>%
  filter(reviews.rating == Star_rating)

# Tokenize the text into bigrams
bigrams <- five_star_reviews %>%
  unnest_tokens(bigram, reviews.text, token = "ngrams", n = 4)

# Count the frequency of each n-gram
bigram_counts <- bigrams %>%
  count(bigram, sort = TRUE)

# Select the top 10 bigrams
top_10_bigrams <- bigram_counts %>%
  slice(1:10)

# Create a bar graph
ggplot(top_10_bigrams, aes(x = reorder(bigram, -n), y = n)) +
  geom_bar(stat = "identity") +
  labs(title = "Top 10 4-word combo in 0-Star Reviews",
       x = "n - gram",
       y = "Frequency") +
  coord_flip()

### Polt After cleaning ### 

barplot(table(HotelReviews$reviews.rating), 
        main = "reviews.rating", xlab = "Rating", ylab = "Count", col = "blue")

### Plot Good Reviews ### 

# Group by review rating and count occurrences of "Bad"
rating_counts <- HotelReviews %>%
  group_by(reviews.rating) %>%
  summarize(Good_Count = sum(sapply(reviews.title, function(doc) str_count(doc, "Bad"))))

# Ensure 'reviews.rating' is treated as a factor for proper ordering
rating_counts$reviews.rating <- factor(rating_counts$reviews.rating, levels = 1:5)

# Print the counts
print(rating_counts)

# Create a bar chart
library(ggplot2)

ggplot(rating_counts, aes(x = Good_Count, y = reviews.rating)) +
  geom_bar(stat = "identity", fill = "Red") +
  labs(title = "Occurrences of 'Bad' by Review Rating",
       x = "Number of 'Bad' Occurrences",
       y = "Review Rating")

install.packages("Rcampdf", repos = "http://datacube.wu.ac.at/", type = "source")

## principal component analysis (PCA)
install.packages("FactoMineR")
library(FactoMineR)
pca_result <- PCA(HotelReviews_data[, c("reviews.rating", "latitude", "longitude")], 
                  scale.unit = TRUE, 
                  ncp = 5) # 'ncp' is the number of dimensions kept in the results (principal components)
summary(pca_result)

## Clustering
# Let's assume you want to create 3 clusters based on 'reviews.rating', 'latitude', and 'longitude'
# First, ensure that the necessary data columns do not contain NA values
HotelReviews <- na.omit(HotelReviews[, c("reviews.rating", "latitude", "longitude")])

# Perform k-means clustering
set.seed(123) # Setting a seed for reproducibility
kmeans_result <- kmeans(HotelReviews, centers = 3)

# Now you can add the cluster assignments to your original dataframe
HotelReviews$cluster <- kmeans_result$cluster

# Summarize the clustering results
print(kmeans_result)

library(ggplot2)

# Create a visual cluster plot
ggplot(HotelReviews, aes(x = longitude, y = latitude, color = as.factor(cluster))) +
  geom_point(alpha = 0.5) +  # Plot each point with some transparency
  scale_color_manual(values = c("red", "green", "blue")) +  # Color setup for each cluster
  geom_point(data = as.data.frame(kmeans_result$centers), aes(x = longitude, y = latitude), 
             color = "black", size = 5, shape = 3) +  # Plot cluster centers
  labs(title = "Hotel Reviews - Cluster Plot", x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(legend.title = element_blank())  # Remove the legend title

# Display the cluster plot
print(cluster_plot)
