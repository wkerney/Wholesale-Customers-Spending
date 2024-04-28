# Install and load necessary packages
install.packages("readr")
install.packages("ggplot2")
install.packages("scales")
install.packages("knitr")
library(readr)
library(ggplot2)
library(scales)
library(knitr)
# Load the dataset
wholesale_data <- read_csv("Wholesale customers data.csv")
head(wholesale_data)  # Check the first few rows

# Check for missing values
sum(is.na(wholesale_data))  # Check for any NA values

# Transform data if necessary
# In this dataset, ensure relevant columns are numeric
wholesale_data$Channel <- as.factor(wholesale_data$Channel)
wholesale_data$Region <- as.factor(wholesale_data$Region)

# Create a new variable for total annual spending
wholesale_data$TotalSpending <- rowSums(wholesale_data[, c("Fresh", "Milk", "Grocery", "Frozen", "Detergents_Paper", "Delicassen")])

# Aggregate total spending by region
spending_by_region <- aggregate(TotalSpending ~ Region, data = wholesale_data, sum)

# Aggregate total spending by channel
spending_by_channel <- aggregate(TotalSpending ~ Channel, data = wholesale_data, sum)

# Get the average spending per category
average_spending_per_category <- sapply(wholesale_data[, c("Fresh", "Milk", "Grocery", "Frozen", "Detergents_Paper", "Delicassen")], mean)

# Bar plot of total spending by region
ggplot(spending_by_region, aes(x = Region, y = TotalSpending, fill = Region)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Spending by Region", x = "Region", y = "Total Spending")+  
  scale_y_continuous(labels = comma)

# Bar plot of total spending by channel
ggplot(spending_by_channel, aes(x = Channel, y = TotalSpending, fill = Channel)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Spending by Channel", x = "Channel", y = "Total Spending")+  
  scale_y_continuous(labels = comma)

# Bar plot of average spending by product category
average_spending_df <- data.frame(Category = names(average_spending_per_category), AverageSpending = average_spending_per_category)

ggplot(average_spending_df, aes(x = Category, y = AverageSpending, fill = Category)) +
  geom_bar(stat = "identity") +
  labs(title = "Average Spending by Product Category", x = "Product Category", y = "Average Spending")  + 
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
