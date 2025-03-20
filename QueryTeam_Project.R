# Install and load required libraries
install.packages("rvest") # For web scraping
install.packages("httr") # For handling HTTP requests
install.packages("dplyr") # For data manipulation
install.packages("stringr") # For string manipulation
# Load the libraries
library(rvest)
library(httr)
library(dplyr)
library(stringr)

# Initialize empty lists to store data for all pages of both websites
all_pages_data_theaa <- list()
all_pages_data_cinch <- list()
# Loop through pages 1 to 15 for TheAA
for (page_num in 1:15) {
  # Construct the URL for the current page
  if (page_num == 1) {
    url_theaa <- "https://www.theaa.com/used-cars/local/greater-manchester"
  } else {
    url_theaa <- paste0("https://www.theaa.com/used-cars/displaycars?fullpostcode=&page=", page_num, "&county=greater-manchester") # nolint
  }
  # nolint
  # Fetch the webpage content for TheAA
  response_theaa <- GET(url_theaa)
  content_theaa <- content(response_theaa, as = "text", encoding = "UTF-8")
  # nolint
  # Parse the HTML content for TheAA
  parsed_html_theaa <- read_html(content_theaa)
  # nolint
  # Extract car details for TheAA
  car_name_theaa <- parsed_html_theaa %>%
    html_nodes(".make-model-text") %>%
    html_text(trim = TRUE)
  # nolint
  car_price_theaa <- parsed_html_theaa %>%
    html_nodes(".total-price") %>%
    html_text(trim = TRUE)

  car_details_theaa <- parsed_html_theaa %>%
    html_nodes(".vl-specs") %>%
    html_text(trim = TRUE)

  # Split Car Details into components
  car_details_split_theaa <- str_split(car_details_theaa, "\\n\\s*•\\s*\\n", simplify = TRUE)

  car_year_theaa <- car_details_split_theaa[, 1] %>% str_trim() # Year
  car_mileage_theaa <- car_details_split_theaa[, 2] %>% str_trim() # Mileage
  car_fuel_theaa <- car_details_split_theaa[, 3] %>% str_trim() # Fuel
  car_transmission_theaa <- car_details_split_theaa[, 4] %>% str_trim() # Transmission

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
  print(paste("Scraped TheAA page", page_num, "\n"))
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

content_cinch <- content(response_cinch, as = "text", encoding = "UTF-8")
parsed_html_cinch <- read_html(content_cinch)

# Extract pagination links using the .pagination_link__ANS_c class
pagination_links <- parsed_html_cinch %>%
  html_nodes(".pagination_link__ANS_c") %>%
  html_attr("href")

# Determine the maximum page number
max_page <- 13 # Default to 13 if no pagination links are found
if (length(pagination_links) > 0) {
  # Extract the page numbers from the pagination links
  page_numbers <- str_extract(pagination_links, "(?<=pageNumber=)\\d+")
  page_numbers <- as.numeric(page_numbers)
  max_page <- min(max(page_numbers, na.rm = TRUE), 13) # Cap the maximum page number at 13
}

# Loop through pages 1 to max_page for Cinch
for (page_num in 1:max_page) {
  # Construct the URL for the current page
  if (page_num == 1) {
    url_cinch <- "https://www.cinch.co.uk/used-cars?financeType=any"
  } else {
    url_cinch <- paste0("https://www.cinch.co.uk/used-cars?financeType=any&pageNumber=", page_num)
  }
  
  # Fetch the webpage content for Cinch
  response_cinch <- GET(url_cinch)
  
  # Check if the request was successful
  if (response_cinch$status_code != 200) {
    cat("Failed to fetch page", page_num, "\n")
    next
  }
  
  content_cinch <- content(response_cinch, as = "text", encoding = "UTF-8")
  
  # Parse the HTML content for Cinch
  parsed_html_cinch <- read_html(content_cinch)

  # Extract car details for Cinch
  car_name_cinch <- parsed_html_cinch %>%
    html_nodes(".vehicle-card_link__AvRBT") %>%
    html_text(trim = TRUE)
  
  # Extract car price for Cinch
  car_price_cinch <- parsed_html_cinch %>%
    html_nodes(".price_cashPrice__fSwOY") %>%
    html_text(trim = TRUE)
  car_price_cinch <- str_replace(car_price_cinch, "Full price.", "") # Remove "Full price."
  
  # Extract car details for Cinch
  car_details_cinch <- parsed_html_cinch %>%
    html_nodes(".specs-list_upperCase__62SjC") %>%
    html_text(trim = TRUE)
  
  # Clean car details for Cinch
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
  
  # Combine into a data frame for the current page
  cars_data_cinch <- data.frame(
    Name = car_name_cinch,
    Price = car_price_cinch,
    Year = car_year_cinch,
    Mileage = car_mileage_cinch,
    Fuel = car_fuel_cinch,
    Transmission = car_transmission_cinch,
    stringsAsFactors = FALSE
  )
  
  # Store the data for the current page in the list
  all_pages_data_cinch[[page_num]] <- cars_data_cinch
  
  # Optional: Print progress
  cat("Scraped Cinch page", page_num, "\n")
}

# Combine data from all pages of Cinch into one data frame
cars_data_cinch_all <- do.call(rbind, all_pages_data_cinch)

# View the final combined data
print(cars_data_cinch_all)

# Combine the datasets
cars_data_theaa_all$Source <- "TheAA" # Add a "Source" column for TheAA data
cars_data_cinch_all$Source <- "Cinch" # Add a "Source" column for Cinch data

# Combine the datasets into one
combined_data <- rbind(cars_data_theaa_all, cars_data_cinch_all)

combined_data$Price <- str_replace_all(combined_data$Price, "£|,|\\+ VAT", "") # Remove £, commas, and "+ VAT"
combined_data$Price <- as.numeric(as.character(combined_data$Price)) # Convert to numeric

# View the cleaned Price column
print(combined_data$Price)

# Clean the Mileage column
combined_data$Mileage <- str_replace_all(combined_data$Mileage, " miles", "") # Remove " miles"
combined_data$Mileage<- as.numeric(str_replace_all(combined_data$Mileage, ",", ""))

# View the final dataset
print(combined_data)

# Save the data to a CSV file
write.csv(combined_data, "scraped_cars_data.csv", row.names = FALSE)

# Summary statistics for numerical columns
summary_stats <- combined_data %>%
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

# Create the box plot for Price by Year and Mileage by Year in one plot
ggplot(combined_data) + 
  geom_boxplot(aes(x = factor(Year), y = Price, color = "Price", fill = "blue"), alpha = 0.3) +
  geom_boxplot(aes(x = factor(Year), y = Mileage, color = "Mileage", fill = "red"), alpha = 0.3) +
  labs(title = "Box Plot of Price and Mileage by Year",
       x = "Year",
       y = "Value") +
  scale_color_manual(values = c("Price" = "blue", "Mileage" = "red")) +
  theme_minimal()

# Histogram of car prices
ggplot(combined_data, aes(x = Price)) +
  geom_histogram(binwidth = 5000, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Distribution of Car Prices", x = "Price (£)", y = "Car Number") +
  theme_minimal()
# Save the plot to a file
ggsave("line_plot_year_price_mileage.png", width = 10, height = 6, dpi = 300)

