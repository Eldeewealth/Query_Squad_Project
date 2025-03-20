# Query_Squad_Project
 This is a Data Analytics Project by a dedicated team.
## Overview

The **Query Squad Project** is a web scraping and data analysis project aimed at extracting and analyzing used car data from two popular websites: [TheAA](https://www.theaa.com) and [Cinch](https://www.cinch.co.uk). This project utilizes R programming along with several libraries to scrape, clean, and analyze the data, producing meaningful visualizations and insights.

### Key Features:
- Scrapes used car listings from TheAA and Cinch.
- Extracts essential details such as car name, price, year, mileage, fuel type, and transmission.
- Combines data from both sources into one dataset for comprehensive analysis.
- Generates insightful visualizations including histograms, scatter plots, box plots, and correlation heatmaps.
- Exports the cleaned dataset to a CSV file for further use.

---

## Table of Contents
1. [Installation](#installation)
2. [Usage](#usage)
3. [Dependencies](#dependencies)
4. [Data Extraction Process](#data-extraction-process)
5. [Data Cleaning & Transformation](#data-cleaning--transformation)
6. [Visualizations](#visualizations)
7. [Output Files](#output-files)
8. [Contributing](#contributing)
9. [License](#license)

---

## Installation

To run this project locally, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/Eldeewealth/Query_Squad_Project.git
   cd query-squad-project
   ```

2. Install the required R packages:
   ```R
   install.packages(c("rvest", "httr", "dplyr", "stringr", "ggplot2", "ggcorrplot"))
   ```

3. Run the script in your R environment:
   ```R
   source("QueryTeam_Project.R")
   ```

---

## Usage

This script performs the following tasks:
1. Scrapes data from TheAA and Cinch across multiple pages (up to 15 pages for TheAA and up to 13 pages for Cinch).
2. Cleans and transforms the scraped data, ensuring consistency between datasets.
3. Generates summary statistics and visualizations.
4. Saves the cleaned dataset and visualizations to files.

Run the script to generate the dataset (`scraped_cars_data.csv`) and visualizations.

---

## Dependencies

The project relies on the following R libraries:
- **`rvest`**: For web scraping HTML content.
- **`httr`**: For making HTTP requests.
- **`dplyr`**: For data manipulation and transformation.
- **`stringr`**: For string manipulation.
- **`ggplot2`**: For creating visualizations.
- **`ggcorrplot`**: For generating correlation heatmaps.

Install these dependencies using the `install.packages()` function as shown in the [Installation](#installation) section.

---

## Data Extraction Process

### TheAA:
- Scrapes data from the used cars section of TheAA's website.
- Extracts car details such as name, price, year, mileage, fuel type, and transmission.
- Loops through pages 1 to 15 to gather data.

### Cinch:
- Scrapes data from Cinch's used cars section.
- Dynamically determines the total number of pages (up to 13) based on pagination links.
- Extracts similar car details as TheAA.

Each page's data is stored in a list and combined into a single dataset after all pages are processed.

---

## Data Cleaning & Transformation

After scraping, the data undergoes the following cleaning steps:
1. Removes unnecessary characters (e.g., "£", ",", " miles").
2. Converts numeric columns (Price, Mileage) to appropriate numeric types.
3. Handles missing or inconsistent data by replacing them with `NA`.
4. Adds a "Source" column to differentiate between TheAA and Cinch data.

The cleaned dataset is then ready for analysis and visualization.

---

## Visualizations

The project generates several visualizations to provide insights into the data:

1. **Box Plots**:
   - Compares Price and Mileage distributions across different years.
   - Highlights trends and outliers in pricing and mileage.

2. **Histogram**:
   - Displays the distribution of car prices.
   - Helps identify common price ranges.

3. **Scatter Plot**:
   - Shows the relationship between Mileage and Price.
   - Differentiates data points by source (TheAA vs. Cinch).

4. **Correlation Heatmap**:
   - Visualizes correlations between Price, Mileage, and Year.
   - Provides insights into how these variables interact.

All visualizations are saved as image files (`*.png` or `*.pdf`) in the working directory.

---

## Output Files

The project generates the following output files:
1. `scraped_cars_data.csv`: The cleaned and combined dataset containing car details from both TheAA and Cinch.
2. Visualization files:
   - `line_plot_year_price_mileage.png`
   - `car_price_vs_mileage_plot.png`
   - `correlation_heatmap.pdf`

These files can be found in the working directory after running the script.

---

## Contributing

We welcome contributions to improve this project! To contribute:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description of your changes.

Please ensure your code adheres to best practices and includes appropriate documentation.

---

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute the code as per the terms of the license.

---

For questions or feedback, please contact the project maintainers via GitHub issues or email.

Happy coding! 🚗📊
