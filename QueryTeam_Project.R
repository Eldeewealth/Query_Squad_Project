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
}
