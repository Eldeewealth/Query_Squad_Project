---

# Security Policy

This project focuses on data cleaning and analysis for car data scraped from external websites. While the script itself does not introduce security vulnerabilities, it is important to handle data responsibly and follow best practices to ensure privacy and reliability.

---

## Supported Versions

This project is actively maintained, and updates are provided for the latest stable version. Older versions are not officially supported.

| Version   | Supported          |
|-----------|--------------------|
| 1.3    | :white_check_mark: |

If you're using an older version of the script, we strongly recommend upgrading to the latest version to benefit from improvements and bug fixes.

---

## Data Privacy and Security

### **1. Data Sources**
- The script scrapes data from external websites (e.g., TheAA and Cinch). Ensure that you comply with the terms of service of these websites when running the script.
- No personally identifiable information (PII) is collected during the scraping process. However, always review the data to ensure compliance with applicable privacy laws.

### **2. Data Storage**
- The cleaned dataset is saved as a CSV file (`cleaned_cars_data.csv`). Ensure that this file is stored securely and is not shared publicly unless appropriate anonymization measures are taken.
- Avoid storing sensitive or proprietary data alongside the scraped data.

### **3. Data Cleaning**
- Missing values in categorical columns (e.g., `Transmission`) are filled using random sampling.
- Outliers in numeric columns (`Price`, `Mileage`) are detected using the Interquartile Range (IQR) method and removed.
- Imputation is performed using the `mice` package to handle missing values responsibly.

### **4. Responsible Use**
- Do not use the script to scrape or analyze data for malicious purposes.
- Ensure that any data you handle complies with local privacy regulations (e.g., GDPR, CCPA).

---

## Reporting Issues

If you encounter any issues related to data handling, privacy, or unexpected behavior in the script, please report them by following these steps:

### **How to Report**
1. **Preferred Method**: Open an issue on the [GitHub repository](https://github.com/Eldeewealth/Query_Squad_Project/issues).
2. Provide the following details:
   - A clear description of the issue.
   - Steps to reproduce the problem.
   - Any relevant code snippets, screenshots, or logs.

### **What Happens Next?**
- **Acknowledgment**: You will receive a response within **1-3 business days**.
- **Updates**: We will keep you informed about the progress of our investigation and resolution.
- **Resolution**: Once the issue is resolved, we will notify you of the fix and any recommended actions on your part.

---

## Best Practices

To ensure the security and reliability of your use of this script, consider the following best practices:

1. **Run Scripts in a Secure Environment**:
   - Execute the script in a controlled environment to prevent unintended access to sensitive data.

2. **Limit Data Exposure**:
   - Avoid sharing raw or cleaned datasets publicly unless necessary.
   - Anonymize or aggregate data before sharing.

3. **Keep Dependencies Updated**:
   - Regularly update the required R libraries to their latest versions to minimize risks.
   ```r
   install.packages(c("rvest", "httr", "dplyr", "stringr", "ggplot2", "mice", "ggcorrplot"))
   ```

4. **Respect Website Policies**:
   - When scraping data, ensure compliance with the target websites' terms of service and robots.txt files.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Contact

For general inquiries or non-security-related issues, please open an issue on the [GitHub repository](https://github.com/Eldeewealth/Query_Squad_Project/issues).

For data-related concerns, please email [lovedayokoro93@gmail.com](mailto:lovedayokoro93@gmail.com).

---
