/*

	Data Cleaning in MySQL

*/

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 1: Review the data
-- Select all rows from the 'layoffs' table for an initial review of the data.
SELECT * FROM layoffs;

-- Describe the structure of the 'layoffs' table to better understand its columns.
DESCRIBE layoffs;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 2: Set up a staging table
-- It's a good practice to use a staging table instead of directly modifying the original table.

-- Create a new staging table to store cleaned data, including an additional 'row_num' column to help identify duplicate rows.
CREATE TABLE `layoffs_staging` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_num` INT -- Adding 'row_num' column for identifying and handling duplicates
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Check the structure of the new staging table to confirm creation.
DESCRIBE layoffs_staging;

-- Verify the staging table is empty before starting the data import.
SELECT * FROM layoffs_staging;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 3: Remove Duplicates

-- Use a CTE to identify duplicate rows based on columns
WITH CTE_ROW_NUM AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
           ORDER BY company
         ) AS row_num
  FROM layoffs
)
-- Select rows that are considered duplicates (row_num > 1) for review.
SELECT * 
FROM CTE_ROW_NUM 
WHERE row_num > 1;

-- Insert the result of the query into the 'layoffs_staging' table including the row_num column
INSERT INTO layoffs_staging
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
           ORDER BY company
       ) AS row_num
FROM layoffs;

-- Review the rows with 'row_num' greater than 1, which are duplicates.
SELECT * 
FROM layoffs_staging 
WHERE row_num > 1;

-- Delete the duplicate rows from the staging table (row_num > 1).
DELETE 
FROM layoffs_staging 
WHERE row_num > 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 4: Standardize Data/Values

-- Remove leading and trailing whitespace from text columns for consistency.
UPDATE layoffs_staging
SET company = TRIM(company);

UPDATE layoffs_staging
SET location = TRIM(location);

UPDATE layoffs_staging
SET industry = TRIM(industry);

UPDATE layoffs_staging
SET country = TRIM(country);

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 5: Check for inconsistencies in categorical columns

-- Identify unique values in the 'location' column for consistency check.
SELECT DISTINCT location FROM layoffs_staging;

-- Identify unique values in the 'company' column for consistency check.
SELECT DISTINCT company FROM layoffs_staging;

-- Identify unique values in the 'industry' column for consistency check.
SELECT DISTINCT industry FROM layoffs_staging;

-- Normalize industry values such as 'CryptoCurrency' and 'Crypto' to a single value ('Crypto').
SELECT DISTINCT industry 
FROM layoffs 
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Identify any inconsistent values in the 'stage' column.
SELECT DISTINCT stage FROM layoffs_staging;

-- Identify inconsistent values in the 'country' column.
SELECT DISTINCT country FROM layoffs_staging;

-- Remove trailing periods (.) from country names, if any.
SELECT country 
FROM layoffs_staging 
WHERE country REGEXP '[.]$';

UPDATE layoffs_staging
SET country = SUBSTRING(country, 1, CHAR_LENGTH(country) - 1)
WHERE country REGEXP '[.]$';

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 6: Standardize date format

-- Verify and review date format inconsistencies.
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date 
FROM layoffs_staging;

-- Convert date column to a uniform format using STR_TO_DATE().
UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Convert 'date' column from TEXT type to DATE type for better handling.
ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Step 7: Clean up unnecessary columns

-- Remove the 'row_num' column, which was used for duplicate management, as it's no longer needed.
ALTER TABLE layoffs_staging
DROP COLUMN row_num;

-- Step 8: Handle null or blank values

-- Identify and review rows with null or blank values in the 'total_laid_off' column.
SELECT * 
FROM layoffs_staging
WHERE total_laid_off IS NULL OR total_laid_off = '';

-- Remove rows with null or blank values in the 'total_laid_off' column.
DELETE 
FROM layoffs_staging
WHERE total_laid_off IS NULL OR total_laid_off = '';

-- Identify and review rows with null or blank values in the 'percentage_laid_off' column.
SELECT * 
FROM layoffs_staging
WHERE percentage_laid_off IS NULL OR percentage_laid_off = '';

-- Remove rows with null or blank values in the 'percentage_laid_off' column.
DELETE 
FROM layoffs_staging
WHERE percentage_laid_off IS NULL OR percentage_laid_off = '';
