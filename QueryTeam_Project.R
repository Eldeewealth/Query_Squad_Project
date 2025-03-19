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

