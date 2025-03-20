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
