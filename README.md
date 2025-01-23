# Global Layoffs Dataset (2020-2023): Data Cleaning and Analysis

## Overview
This project demonstrates the process of cleaning and transforming a dataset of layoffs in various companies. The dataset contains key information about companies, locations, industries, layoffs, and other financial details. The aim is to standardize, clean, and remove inconsistencies and duplicates to make the data ready for analysis.

## Objectives
- Duplicate Removal
- Standardizing text and date formats
- Handling missing and blank values
- Validating categorical data consistency
- Using a staging table for safe data cleaning

## Dataset
This project works with a dataset of layoffs across companies, containing the following columns:
- company: The name of the company.
- location: The location of the company or the affected employees.
- industry: The sector or industry the company operates in.
- total_laid_off: The number of employees laid off.
- percentage_laid_off: The percentage of the workforce laid off.
- date: The date of the layoffs.
- stage: The phase or stage of layoffs (e.g., planning, execution).
- country: The country where the company is located.
- funds_raised_millions: The amount of funds raised by the company (in millions).


## Methodology
This data cleaning process is carried out through SQL queries, focusing on several common issues in real-world datasets:
###   1. Removing duplicates:
        - I used a Common Table Expression (CTE) with `ROW_NUMBER()` to identify and remove exact duplicate rows.
###   2. Standardizing Text:
        - Categorical fields like `company`, `location`, `industry`, and `country` were cleaned to remove extra spaces and inconsistent naming conventions (e.g., standardizing "Crypto" and "CryptoCurrency" to "Crypto").
###   3. Date Format Standardization:
        - The `date` field was standardized from a text format (`MM/DD/YYYY`) to the DATE type in MySQL.
###   4. Handling Null or Blank Values:
        -Rows with null or empty values in critical fields like `total_laid_off` and `percentage_laid_off` were removed to ensure data integrity.
###   5. Using a Staging Table:
        - All cleaning operations were performed on a staging table (`layoffs_staging`) to prevent any accidental modifications to the original data.

### Future Improvements
- **Performance Optimization:** If the dataset grows larger, indexing and query optimization strategies can be implemented to improve performance.
- **Automated Data Cleaning:** Implement stored procedures or Python scripts to automate the cleaning process for regular updates.
