SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

CREATE TABLE churn_staging (
	Age TEXT,
	Gender TEXT,
	Country TEXT,
	City TEXT,
	Membership_Years TEXT,
	Login_Frequency TEXT,
	Session_Duration_Avg TEXT,
	Pages_Per_Session TEXT,
	Cart_Abandonment_Rate TEXT,
	Wishlist_Items TEXT,
	Total_Purchases TEXT,
	Average_Order_Value TEXT,
	Days_Since_Last_Purchase TEXT,
	Discount_Usage_Rate TEXT,
	Returns_Rate TEXT,
	Email_Open_Rate TEXT,
	Customer_Service_Calls TEXT,
	Product_Reviews_Written TEXT,
	Social_Media_Engagement_Score TEXT,
	Mobile_App_Usage TEXT,
	Payment_Method_Diversity TEXT,
	Lifetime_Value TEXT,
	Credit_Balance TEXT,
	Churned TEXT,
	Signup_Quarter TEXT
    );

LOAD DATA LOCAL INFILE 'C:\Users\19176\Downloads\clean_ecommerce_customer_churn_dataset.csv'
INTO TABLE churn_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '/n'
IGNORE 1 LINES;

SELECT COUNT(Membership_Years)
FROM churn_staging;

SELECT DISTINCT total_purchases
FROM churn_staging
ORDER BY Total_Purchases;

-- Recode Total_Purchases Negatives to NULL
UPDATE churn_staging
SET Total_Purchases = NULL
WHERE Total_Purchases < 0;

-- Recode Cart_Abandonment_Rate over 100% to NULL
UPDATE churn_staging
SET Cart_Abandonment_Rate = NULL
WHERE Cart_Abandonment_Rate > 100; 

SELECT *
FROM churn_staging;

SELECT *
FROM churn_staging
ORDER BY Session_Duration_Avg DESC;

SELECT MAX(LENGTH(Lifetime_Value))
FROM churn_staging;

-- Adjusting Column Data Types
CREATE TABLE churn_staging2 (
Age INT,
Gender VARCHAR(10),
Country VARCHAR(10),
City VARCHAR(20), 
Membership_Years DECIMAL(5,1),
Login_Frequency INT,
Session_Duration_Avg DECIMAL(5,1),
Pages_Per_Session DECIMAL(5,1),
Cart_Abandonment_Rate DECIMAL(5,1), 
Wishlist_Items INT,
Total_Purchases INT,
Average_Order_Value DECIMAL(10,2),  
Days_Since_Last_Purchase INT,
Discount_Usage_Rate DECIMAL(10,2), 
Returns_Rate DECIMAL(10,2), 
Email_Open_Rate DECIMAL(5,1),  
Customer_Service_Calls INT, 
Product_Reviews_Written INT, 
Social_Media_Engagement_Score DECIMAL(5,1), 
Mobile_App_Usage DECIMAL(5,1), 
Payment_Method_Diversity INT,
Lifetime_Value DECIMAL(10,2), 
Credit_Balance BIGINT, 
Churned INT, 
Signup_Quarter VARCHAR(10)
);

INSERT INTO churn_staging2 (
  Age, Gender, Country, City, Membership_Years, Login_Frequency, Session_Duration_Avg,
  Pages_Per_Session, Cart_Abandonment_Rate, Wishlist_Items, Total_Purchases,
  Average_Order_Value, Days_Since_Last_Purchase, Discount_Usage_Rate, Returns_Rate,
  Email_Open_Rate, Customer_Service_Calls, Product_Reviews_Written,
  Social_Media_Engagement_Score, Mobile_App_Usage, Payment_Method_Diversity,
  Lifetime_Value, Credit_Balance, Churned, Signup_Quarter
)
SELECT
  CAST(NULLIF(Age, '') AS SIGNED)                                  AS Age,
  NULLIF(Gender, '')                                               AS Gender,
  NULLIF(Country, '')                                              AS Country,
  NULLIF(City, '')                                                 AS City,
  CAST(NULLIF(Membership_Years, '') AS DECIMAL(5,1))               AS Membership_Years,
  CAST(NULLIF(Login_Frequency, '') AS SIGNED)                      AS Login_Frequency,
  CAST(NULLIF(Session_Duration_Avg, '') AS DECIMAL(5,1))           AS Session_Duration_Avg,
  CAST(NULLIF(Pages_Per_Session, '') AS DECIMAL(5,1))              AS Pages_Per_Session,
  CAST(NULLIF(Cart_Abandonment_Rate, '') AS DECIMAL(5,1))          AS Cart_Abandonment_Rate,
  CAST(NULLIF(Wishlist_Items, '') AS SIGNED)                       AS Wishlist_Items,
  CAST(NULLIF(Total_Purchases, '') AS SIGNED)                      AS Total_Purchases,
  CAST(NULLIF(Average_Order_Value, '') AS DECIMAL(10,2))           AS Average_Order_Value,
  CAST(NULLIF(Days_Since_Last_Purchase, '') AS SIGNED)             AS Days_Since_Last_Purchase,
  CAST(NULLIF(Discount_Usage_Rate, '') AS DECIMAL(10,2))           AS Discount_Usage_Rate,
  CAST(NULLIF(Returns_Rate, '') AS DECIMAL(10,2))                  AS Returns_Rate,
  CAST(NULLIF(Email_Open_Rate, '') AS DECIMAL(5,1))                AS Email_Open_Rate,
  CAST(NULLIF(Customer_Service_Calls, '') AS SIGNED)               AS Customer_Service_Calls,
  CAST(NULLIF(Product_Reviews_Written, '') AS SIGNED)              AS Product_Reviews_Written,
  CAST(NULLIF(Social_Media_Engagement_Score, '') AS DECIMAL(5,1))  AS Social_Media_Engagement_Score,
  CAST(NULLIF(Mobile_App_Usage, '') AS DECIMAL(5,1))               AS Mobile_App_Usage,
  CAST(NULLIF(Payment_Method_Diversity, '') AS SIGNED)             AS Payment_Method_Diversity,
  CAST(NULLIF(Lifetime_Value, '') AS DECIMAL(10,2))                AS Lifetime_Value,
  CAST(NULLIF(Credit_Balance, '') AS SIGNED)                       AS Credit_Balance,
  CAST(NULLIF(Churned, '') AS SIGNED)                              AS Churned,
  NULLIF(Signup_Quarter, '')                                       AS Signup_Quarter
FROM churn_staging;

SELECT COUNT(*) AS text_rows FROM churn_staging;
SELECT COUNT(*) AS typed_rows FROM churn_staging2;

SELECT Age, Membership_Years, Average_Order_Value, Lifetime_Value, Credit_Balance, Churned
FROM churn_staging2
LIMIT 10;

-- Implementing Age Group Column
SELECT DISTINCT age
FROM churn_staging2
ORDER BY 1;

ALTER TABLE churn_staging2
ADD Age_Group VARCHAR(50)
AFTER age;

UPDATE churn_staging2
SET Age_Group = 
	CASE
		WHEN Age < 18 THEN 'Children (<18)'
        WHEN Age BETWEEN 18 AND 24 THEN 'Young Adults (18-24)'
        WHEN Age BETWEEN 25 AND 34 THEN 'Early Career (25-34)'
        WHEN Age BETWEEN 35 AND 44 THEN 'Middle Age (35-44)'
        WHEN Age BETWEEN 45 AND 54 THEN 'Established (45-54)'
        WHEN Age BETWEEN 55 AND 64 THEN 'Pre-Retirement (55-64)'
        WHEN Age >= 65 THEN 'Seniors (65+)'
        ELSE 'Unknown'
	END;
        
SELECT *
FROM churn_staging2
ORDER BY age;

-- Implementing Membership Length Brackets
SELECT DISTINCT Membership_Years
FROM churn_staging2
ORDER BY 1 DESC;

ALTER TABLE churn_staging2
ADD Membership_Length VARCHAR(50)
AFTER Membership_Years;

UPDATE churn_staging2
SET Membership_Length = 
	CASE
		WHEN Membership_Years < 1 THEN '< 1 year'
        WHEN Membership_Years BETWEEN 1 AND 3 THEN '1-3 years'
        WHEN Membership_Years BETWEEN 3.01 AND 6 THEN '3-6 years'
        WHEN Membership_Years > 6.01 THEN '6+ years'
        ELSE 'Unknown'
	END;
    
SELECT *
FROM churn_staging2
ORDER BY Membership_Years;

-- Implementing Lifetime Value Levels for Analysis
SELECT Lifetime_Value
FROM churn_staging2
ORDER BY 1;

ALTER TABLE churn_staging2
ADD Lifetime_Value_Levels VARCHAR(50)
AFTER Lifetime_Value;

UPDATE churn_staging2
SET Lifetime_Value_Levels = 
	CASE
		WHEN Lifetime_Value < 250 THEN 'Low Value'
        WHEN Lifetime_Value BETWEEN 250 AND 1000 THEN 'Emerging Value'
        WHEN Lifetime_Value BETWEEN 1000.01 AND 2500 THEN 'Core Value'
        WHEN Lifetime_Value BETWEEN 2500.01 AND 5000 THEN 'High Value'
        WHEN Lifetime_Value > 5000 THEN 'Top Customer'
        ELSE 'Unknown'
	END;
    
SELECT *
FROM churn_staging2
ORDER BY Lifetime_Value;
    
-- Implementing Login Frequency Scale Column
SELECT login_frequency
FROM churn_staging2
ORDER BY 1;

ALTER TABLE churn_staging2
ADD Login_Levels VARCHAR(50)
AFTER Login_Frequency;

UPDATE churn_staging2 
SET Login_Levels = 
	CASE
		WHEN Login_Frequency IS NULL THEN 'Inactive'
        WHEN Login_Frequency BETWEEN 1 AND 3 THEN 'Very Low Activity'
        WHEN Login_Frequency BETWEEN 4 AND 10 THEN 'Low Activity'
        WHEN Login_Frequency BETWEEN 11 AND 25 THEN 'Moderate Activity'
        WHEN Login_Frequency > 25 THEN 'Top User'
        ELSE 'Unknown'
	END;
    
SELECT *
FROM churn_staging2
ORDER BY Login_Frequency;

-- Removing Discount Usage Rate Values > 100
UPDATE churn_staging2
SET Discount_Usage_Rate = NULL
WHERE Discount_Usage_Rate > 100;
    
-- Implementing Discount Usage Rate Scales
SELECT Discount_Usage_Rate
FROM churn_staging2
WHERE Discount_Usage_Rate IS NOT NULL
ORDER BY 1 DESC;

ALTER TABLE churn_staging2
ADD Discount_Usage_Tiers VARCHAR(50)
AFTER Discount_Usage_Rate;

UPDATE churn_staging2
SET Discount_Usage_Tiers = 
	CASE
		WHEN Discount_Usage_Rate < 1 THEN 'Full Price Buyer'
        WHEN Discount_Usage_Rate BETWEEN 1 AND 20 THEN 'Low Discount Usage'
        WHEN Discount_Usage_Rate BETWEEN 20.01 AND 50 THEN 'Moderate Discount Usage'
        WHEN Discount_Usage_Rate BETWEEN 50.01 AND 80 THEN 'High Discount Usage'
        WHEN Discount_Usage_Rate > 80 THEN 'Deal Dependent'
        ELSE 'Unknown'
	END;
    
SELECT *
FROM churn_staging2
WHERE Discount_Usage_Rate IS NOT NULL
ORDER BY Discount_Usage_Rate;


-- Finalizing Clean Dataset
DROP TABLE IF EXISTS churn;

RENAME TABLE churn_staging2 TO churn;

ALTER TABLE churn
ADD App_Usage_Tiers VARCHAR(50)
AFTER Mobile_App_Usage;

UPDATE churn
SET App_Usage_Tiers = 
	CASE
		WHEN Mobile_App_Usage < 14.99 THEN 'Minimal'
        WHEN Mobile_App_Usage BETWEEN 15 AND 29.99 THEN 'Moderate'
        WHEN Mobile_App_Usage BETWEEN 30 AND 44.99 THEN 'Strong'
        WHEN Mobile_App_Usage > 45 THEN 'Top-Tier'
        ELSE 'Unknown'
	END;
