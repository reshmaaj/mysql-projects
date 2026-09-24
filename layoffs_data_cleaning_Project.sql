-- Data Cleaning
SELECT *
FROM layoffs;

-- creating a copy of the raw data since we're gonna make a lotta changes here - do not work directly on raw data!
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs; 


-- Step1: Remove Duplicates
-- Step2: Standardize the Data
-- Step3: Null Values or blank values
-- Step4: Remove any columns

-- Step1: Remove Duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() 
OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions
) 
AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;  -- 2 and above means the table contains duplicate values

-- creating the copy of the table to perform delete 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() 
OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions
) 
AS row_num
FROM layoffs_staging;

/* SELECT COUNT(*)
FROM layoffs_staging2; 

TRUNCATE TABLE layoffs_staging2; */ -- deleted the table since i inserted the datas into it multiple times!

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

-- Step2: Standardize the Data
-- find the issues and fix them
SELECT company, TRIM(company) 
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'; 
-- there are 3 industries named after crypto, they all should come under one grp: Crypto, which is the ryt practice for visualisation
-- so we update it
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT * 
FROM layoffs_staging
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country like 'United States%'
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM Country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM Country)
WHERE country LIKE 'United States%';


