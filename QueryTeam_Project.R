# Install and load required libraries
install.packages("rvest") # For web scraping
install.packages("httr") # For handling HTTP requests
install.packages("dplyr") # For data manipulation
install.packages("stringr") # For string manipulation
# Load the libraries
library(rvest) # For web scraping and HTML parsing
library(httr) # For handling HTTP requests and responses
library(dplyr) # For data manipulation and transformation
library(stringr) # For string manipulation and regular expressions
library(ggplot2) # For data visualization and plotting
library(ggcorrplot) # For correlation heatmap visualization
library(mice) # For handling missing data and imputation
library(robot) # For checking robots.txt file

# Function to check if scraping is allowed
is_scraping_allowed <- function(url) {
  paths_allowed(url)
}

# Check if scraping is allowed for both websites
if (!is_scraping_allowed("https://www.theaa.com") || !is_scraping_allowed("https://www.cinch.co.uk")) {
  stop("Scraping is not allowed on one or both websites.")
} else {
  print("Scraping is allowed on both websites.")
}

# Initialize empty lists to store data for all pages of both websites
all_pages_data_theaa <- list()
all_pages_data_cinch <- list()
# Loop through pages 1 to 15 for TheAA
for (page_num in 1:15) {
  set.sleep(1) # Pause for 1 second between requests to avoid overwhelming the server
  # Construct the URL for the current page
  if (page_num == 1) {
    url_theaa <- "https://www.theaa.com/used-cars/local/greater-manchester"
  } else {
    url_theaa <- paste0("https://www.theaa.com/used-cars/displaycars?fullpostcode=&page=", page_num, "&county=greater-manchester") # nolint
  }
  
  # Fetch the webpage content for TheAA
  response_theaa <- GET(url_theaa)
  content_theaa <- content(response_theaa, as = "text", encoding = "UTF-8")
  
  # Parse the HTML content for TheAA
  parsed_html_theaa <- read_html(content_theaa)
  
  # Extract car name from TheAA website
  car_name_theaa <- parsed_html_theaa %>%
    html_nodes(".make-model-text") %>%
    html_text(trim = TRUE)

  # Extract car price from TheAA website
  car_price_theaa <- parsed_html_theaa %>%
    html_nodes(".total-price") %>%
    html_text(trim = TRUE)

  # Extract car details for TheAA (Year, Mileage, Fuel, Transmission)
  car_details_theaa <- parsed_html_theaa %>%
    html_nodes(".vl-specs") %>%
    html_text(trim = TRUE)

  # Split Car Details into components (Year, Mileage, Fuel, Transmission)
  car_details_split_theaa <- str_split(car_details_theaa, "\\n\\s*•\\s*\\n", simplify = TRUE) # nolint # nolint

  car_year_theaa <- car_details_split_theaa[, 1] %>% str_trim() # Year 
  car_mileage_theaa <- car_details_split_theaa[, 2] %>% str_trim() # Mileage 
  car_fuel_theaa <- car_details_split_theaa[, 3] %>% str_trim() # Fuel 
  car_transmission_theaa <- car_details_split_theaa[, 4] %>% str_trim() # Transmission # nolint # nolint

  # Combine into a data frame for the current page
  cars_data_theaa <- data.frame(
    Name = car_name_theaa,
    Price = car_price_theaa,
    Year = car_year_theaa,
    Mileage = car_mileage_theaa,
    Fuel = car_fuel_theaa,
    Transmission = car_transmission_theaa,
    stringsAsFactors = FALSE
  )

  # Store the data for the current page in the list
  all_pages_data_theaa[[page_num]] <- cars_data_theaa

  # Optional: Print progress
  print(paste("Scraped TheAA page", page_num))
}

# Combine data from all pages of TheAA into one data frame
cars_data_theaa_all <- do.call(rbind, all_pages_data_theaa)

# Fetch the first page to determine the total number of pages
url_cinch <- "https://www.cinch.co.uk/used-cars?financeType=any"
response_cinch <- GET(url_cinch)

# Check if the request was successful
if (response_cinch$status_code != 200) {
  stop("Failed to fetch the first page.")
}

# Parse the HTML content for Cinch website
content_cinch <- content(response_cinch, as = "text", encoding = "UTF-8")
parsed_html_cinch <- read_html(content_cinch)

# Extract pagination links using the .pagination_link__ANS_c class
pagination_links <- parsed_html_cinch %>%
  html_nodes(".pagination_link__ANS_c") %>% 
  html_attr("href") 

# Determine the maximum page number based on the pagination links
max_page <- 13 # Default to 13 if no pagination links are found
if (length(pagination_links) > 0) {
  # Extract the page numbers from the pagination links
  page_numbers <- str_extract(pagination_links, "(?<=pageNumber=)\\d+")
  page_numbers <- as.numeric(page_numbers)
  max_page <- min(max(page_numbers, na.rm = TRUE), 13) # Cap the maximum page number at 13
}

# Loop through pages 1 to max_page for Cinch website
for (page_num in 1:max_page) {
  # Construct the URL for the current page in Cinch website 
  if (page_num == 1) {
    url_cinch <- "https://www.cinch.co.uk/used-cars?financeType=any"
  } else {
    url_cinch <- paste0("https://www.cinch.co.uk/used-cars?financeType=any&pageNumber=", page_num)
  }
  
  # Fetch the webpage content for Cinch website
  response_cinch <- GET(url_cinch)
  
  # Check if the request was successful
  if (response_cinch$status_code != 200) {
    cat("Failed to fetch page", page_num, "\n")
    next

    set.sleep(1) # Pause for 1 second between requests to avoid overwhelming the server
  }
  
  content_cinch <- content(response_cinch, as = "text", encoding = "UTF-8")
  
  # Parse the HTML content for Cinch website 
  parsed_html_cinch <- read_html(content_cinch)

  # Extract car details for Cinch (Name, Price, Year, Mileage, Fuel, Transmission)
  car_name_cinch <- parsed_html_cinch %>%
    html_nodes(".vehicle-card_link__AvRBT") %>%
    html_text(trim = TRUE)
  
  # Extract car price for Cinch and remove "Full price."
  car_price_cinch <- parsed_html_cinch %>%
    html_nodes(".price_cashPrice__fSwOY") %>%
    html_text(trim = TRUE)
  car_price_cinch <- str_replace(car_price_cinch, "Full price.", "") # Remove "Full price."
  
  # Extract car details for Cinch (Year, Mileage, Fuel, Transmission)
  car_details_cinch <- parsed_html_cinch %>%
    html_nodes(".specs-list_upperCase__62SjC") %>%
    html_text(trim = TRUE)
  
  # Clean car details for Cinch by removing unnecessary text
  car_details_cinch <- str_replace_all(car_details_cinch,
                                       c("Vehicle Year," = "",
                                         "Mileage," = "",
                                         "Fuel Type," = "",
                                         "Transmission Type," = ""))
  
  # Split Car Details into Year, Mileage, Fuel, Transmission
  car_details_split_cinch <- str_split(car_details_cinch, "\\s+", simplify = TRUE) # Split by spaces
  
  # Handle cases where the split does not return expected columns
  car_year_cinch <- ifelse(ncol(car_details_split_cinch) >= 2, car_details_split_cinch[, 2], NA)
  car_mileage_cinch <- ifelse(ncol(car_details_split_cinch) >= 4, paste(car_details_split_cinch[, 3], car_details_split_cinch[, 4]), NA)
  car_fuel_cinch <- ifelse(ncol(car_details_split_cinch) >= 5, car_details_split_cinch[, 5], NA)
  car_transmission_cinch <- ifelse(ncol(car_details_split_cinch) >= 8, paste(car_details_split_cinch[, 6], car_details_split_cinch[, 7], car_details_split_cinch[, 8]), NA)
  
  # Combine into a data frame for the pages in Cinch website
  cars_data_cinch <- data.frame(
    Name = car_name_cinch,
    Price = car_price_cinch,
    Year = car_year_cinch,
    Mileage = car_mileage_cinch,
    Fuel = car_fuel_cinch,
    Transmission = car_transmission_cinch,
    stringsAsFactors = FALSE
  )
  
  # Store the data for the current page in the list of all pages data for Cinch
  all_pages_data_cinch[[page_num]] <- cars_data_cinch 
  
  # Optional: Print progress for each page scraped in Cinch website 
  print(paste("Scraped Cinch page", page_num))
}
# Combine all Cinch data
cars_data_cinch_all <- do.call(rbind, all_pages_data_cinch)

# Combine data from all pages of Cinch into one data frame
combined_data <- full_join(cars_data_theaa_all, cars_data_cinch_all, by = c("Name", "Price", "Year", "Mileage", "Fuel", "Transmission"))

# Detect missing values using colSums
missing_values_summary <- colSums(is.na(combined_data))
print("Summary of Missing Values:")
print(missing_values_summary)

# Alternatively, fill missing values using Random Sampling
observed_values <- combined_data$Transmission[!is.na(combined_data$Transmission)]
combined_data$Transmission[is.na(combined_data$Transmission)] <- sample(observed_values, sum(is.na(combined_data$Transmission)), replace = TRUE)

# check to confirm missing values using colSums have been handled
missing_values_summary <- colSums(is.na(combined_data))
print("Summary of Missing Values:")
print(missing_values_summary)

# Clean the Price column
combined_data$Price <- str_replace_all(combined_data$Price, "£|,|\\+ VAT", "")
combined_data$Price <- as.numeric(as.character(combined_data$Price))

# Clean the Mileage column
combined_data$Mileage <- str_replace_all(combined_data$Mileage, " miles", "")
combined_data$Mileage <- as.numeric(str_replace_all(combined_data$Mileage, ",", ""))

# Convert Year to numeric
combined_data$Year <- as.numeric(combined_data$Year)

# Box Plot for Price and Mileage by Year (After Imputation)
ggplot(combined_data, aes(x = factor(Year))) + 
  geom_boxplot(aes(y = Price, fill = "Price"), alpha = 0.5, outlier.color = "red") +
  geom_boxplot(aes(y = Mileage, fill = "Mileage"), alpha = 0.5, outlier.color = "blue") +
  scale_fill_manual(values = c("Price" = "blue", "Mileage" = "red")) +
  labs(title = "Box Plot of Price and Mileage by Year (After Imputation)",
       x = "Year",
       y = "Value") +
  theme_minimal()

# Function to detect outliers using IQR
detect_outliers <- function(column) {
  Q1 <- quantile(column, 0.25, na.rm = TRUE)
  Q3 <- quantile(column, 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  # Identify outliers
  outliers <- column[column < lower_bound | column > upper_bound]
  
  return(list(
    lower_bound = lower_bound,
    upper_bound = upper_bound,
    outliers = outliers,
    num_outliers = length(outliers) # Count the number of outliers
  ))
}

# Apply outlier detection to Price and Mileage columns
price_outliers <- detect_outliers(combined_data$Price)
mileage_outliers <- detect_outliers(combined_data$Mileage)

# Output the results for Price
print("Outliers in Price:")
print(price_outliers$outliers)
cat("Number of outliers in Price:", price_outliers$num_outliers, "\n")

# Output the results for Mileage
print("Outliers in Mileage:")
print(mileage_outliers$outliers)
cat("Number of outliers in Mileage:", mileage_outliers$num_outliers, "\n")

# Function to replace outliers with NA
replace_outliers_with_na <- function(column) {
  Q1 <- quantile(column, 0.25, na.rm = TRUE)
  Q3 <- quantile(column, 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  column[column < lower_bound | column > upper_bound] <- NA
  return(column)
}

# Replace outliers in Price and Mileage columns with NA
combined_data$Price <- replace_outliers_with_na(combined_data$Price)
combined_data$Mileage <- replace_outliers_with_na(combined_data$Mileage)

# Check to confirm missing values using colSums
check_NA <- colSums(is.na(combined_data))
print("Summary of Missing Values After Replacing Outliers:")
print(check_NA)

# Impute missing values using mice
imputed_data <- mice(combined_data, 5) # Predictive mean matching
complete_data <- complete(imputed_data)

# Check summary after imputation
summary(complete_data)

# Check to confirm missing values have been handled after imputation
check_NA_after_imputation <- colSums(is.na(complete_data))
print("Summary of Missing Values After Imputation:")
print(check_NA_after_imputation)

# Box Plot for Price and Mileage by Year (After Imputation)
ggplot(complete_data, aes(x = factor(Year))) + 
  geom_boxplot(aes(y = Price, fill = "Price"), alpha = 0.5, outlier.color = "red") +
  geom_boxplot(aes(y = Mileage, fill = "Mileage"), alpha = 0.5, outlier.color = "blue") +
  scale_fill_manual(values = c("Price" = "blue", "Mileage" = "red")) +
  labs(title = "Box Plot of Price and Mileage by Year (After Imputation)",
       x = "Year",
       y = "Value") +
  theme_minimal()

# Detect outliers in Price and Mileage after imputation
price_outliers_after_imputation <- detect_outliers(complete_data$Price)
mileage_outliers_after_imputation <- detect_outliers(complete_data$Mileage)

# Output the results for Price
print("Outliers in Price After Imputation:")
print(price_outliers_after_imputation$outliers)
cat("Number of outliers in Price After Imputation:", price_outliers_after_imputation$num_outliers, "\n")

# Output the results for Mileage
print("Outliers in Mileage After Imputation:")
print(mileage_outliers_after_imputation$outliers)
cat("Number of outliers in Mileage After Imputation:", mileage_outliers_after_imputation$num_outliers, "\n")

# Drop rows with outliers in Price and Mileage
cleaned_data <- complete_data %>%
  filter(Price >= price_outliers_after_imputation$lower_bound & Price <= price_outliers_after_imputation$upper_bound) %>%
  filter(Mileage >= mileage_outliers_after_imputation$lower_bound & Mileage <= mileage_outliers_after_imputation$upper_bound)

# Verify the number of rows after dropping outliers
cat("Number of rows before dropping outliers:", nrow(complete_data), "\n")
cat("Number of rows after dropping outliers:", nrow(cleaned_data), "\n")


# Detect outliers in Price and Mileage after dropping the rows that have outliers
price_outliers_after_cleaning <- detect_outliers(cleaned_data$Price)
mileage_outliers_after_cleaning <- detect_outliers(cleaned_data$Mileage)

# Output the results for Price
print("Outliers in Price After Imputation:")
print(price_outliers_after_cleaning$outliers)
cat("Number of outliers in Price After Imputation:", price_outliers_after_imputation$num_outliers, "\n")

# Output the results for Mileage
print("Outliers in Mileage After Imputation:")
print(mileage_outliers_after_cleaning$outliers)
cat("Number of outliers in Mileage After Imputation:", mileage_outliers_after_imputation$num_outliers, "\n")

# Summary statistics for numerical columns
summary_stats <- cleaned_data %>%
  summarise(
    Mean_Price = mean(Price, na.rm = TRUE),
    Median_Price = median(Price, na.rm = TRUE),
    Min_Price = min(Price, na.rm = TRUE),
    Max_Price = max(Price, na.rm = TRUE),
    Mean_Mileage = mean(Mileage, na.rm = TRUE),
    Median_Mileage = median(Mileage, na.rm = TRUE),
    Min_Mileage = min(Mileage, na.rm = TRUE),
    Max_Mileage = max(Mileage, na.rm = TRUE)
  )

print(summary_stats)

# Histogram of car prices
ggplot(cleaned_data, aes(x = Price)) +
  geom_histogram(binwidth = 5000, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Car Prices", x = "Price (£)", y = "Car Number") +
  theme_minimal()

# Calculate the correlation matrix for Year, Price, and Mileage
correlation_matrix <- cor(cleaned_data[, c("Year", "Price", "Mileage")], use = "complete.obs")
print("Correlation Matrix for Year, Price, and Mileage:")
print(correlation_matrix)

# Correlation Heatmap
heatmap_plot <- ggcorrplot(
  correlation_matrix,
  method = "square", # Square layout
  type = "lower",    # Show only the lower triangle
  lab = TRUE,        # Add correlation coefficients as labels
  lab_size = 3,      # Font size for labels
  title = "Correlation Heatmap of Car Data",
  colors = c("#6D9EC1", "white", "#E46726") # Blue for positive, white for neutral, red for negative
)
# Display the heatmap
print(heatmap_plot)

# Save the cleaned data to a CSV file
write.csv(cleaned_data, "cleaned_cars_data.csv", row.names = FALSE)