SELECT *
FROM churn;

-- What behaviors most differentiate churned customers from retained customers?

-- Grouping Churn Rates by Login Activity
SELECT Login_Levels,
	COUNT(*) AS total_customers,
    SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    SUM(CASE WHEN Churned = 0 THEN 1 ELSE 0 END) AS Retained_Customers,
    ROUND(
		(SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
	) AS Churn_Rate
FROM churn
GROUP BY Login_Levels;

SELECT COUNT(*)
FROM churn
WHERE Login_Levels = 'Inactive' AND Churned = 1;

-- Grouping Churn Rates by Discount Usage
SELECT Discount_Usage_Tiers,
    SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    SUM(CASE WHEN Churned = 0 THEN 1 ELSE 0 END) AS Retained_Customers,
    COUNT(*) AS total_customers,
    ROUND(
		(SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
	) AS Churn_Rate
FROM churn
GROUP BY Discount_Usage_Tiers;

-- Grouping Churn Rates by Email Open Rate
SELECT (CASE
			WHEN Email_Open_Rate < 10 THEN 'Rarely'
            WHEN Email_Open_Rate BETWEEN 10.01 AND 40 THEN 'Sometimes'
            WHEN Email_Open_Rate BETWEEN 40.01 AND 80 THEN 'Often'
            WHEN Email_Open_Rate > 80 THEN 'Always'
		END) AS Email_Open,
    SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    SUM(CASE WHEN Churned = 0 THEN 1 ELSE 0 END) AS Retained_Customers,
    COUNT(*) AS total_customers,
    ROUND(
		(SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
	) AS Churn_Rate
FROM churn
WHERE (CASE
			WHEN Email_Open_Rate < 10 THEN 'Rarely'
            WHEN Email_Open_Rate BETWEEN 10.01 AND 40 THEN 'Sometimes'
            WHEN Email_Open_Rate BETWEEN 40.01 AND 80 THEN 'Often'
            WHEN Email_Open_Rate > 80 THEN 'Always'
		END) IS NOT NULL
GROUP BY (CASE
			WHEN Email_Open_Rate < 10 THEN 'Rarely'
            WHEN Email_Open_Rate BETWEEN 10.01 AND 40 THEN 'Sometimes'
            WHEN Email_Open_Rate BETWEEN 40.01 AND 80 THEN 'Often'
            WHEN Email_Open_Rate > 80 THEN 'Always'
		END);

-- Grouping by Mobile App Usage
SELECT CASE
			WHEN Mobile_App_Usage < 10 THEN 'Rarely'
            WHEN Mobile_App_Usage BETWEEN 10.01 AND 25 THEN 'Sometimes'
            WHEN Mobile_App_Usage BETWEEN 25.01 AND 50 THEN 'Often'
            WHEN Mobile_App_Usage > 50 THEN 'Top User'
		END AS App_Usage,
	SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) AS Churned_Customers,
    SUM(CASE WHEN Churned = 0 THEN 1 ELSE 0 END) AS Retained_Customers,
    COUNT(*) AS total_customers,
    ROUND(
		(SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
	) AS Churn_Rate
FROM churn
GROUP BY (CASE
			WHEN Mobile_App_Usage < 10 THEN 'Rarely'
            WHEN Mobile_App_Usage BETWEEN 10.01 AND 25 THEN 'Sometimes'
            WHEN Mobile_App_Usage BETWEEN 25.01 AND 50 THEN 'Often'
            WHEN Mobile_App_Usage > 50 THEN 'Top User'
		END);
        
-- Which customer segments generate the highest lifetime value, and how stable are they?

SELECT
    Lifetime_Value_Levels,
    COUNT(*) AS customers,
    ROUND(AVG(Lifetime_Value), 2) AS avg_ltv,
    ROUND(SUM(Lifetime_Value), 2) AS total_ltv
FROM churn
GROUP BY Lifetime_Value_Levels
ORDER BY avg_ltv DESC;

SELECT
    Age_Group,
    Lifetime_Value_Levels,
    COUNT(*) AS customers,
    ROUND(AVG(Lifetime_Value), 2) AS avg_ltv
FROM churn
GROUP BY Age_Group, Lifetime_Value_Levels
ORDER BY Lifetime_Value_Levels, customers DESC;

SELECT
    Membership_Length,
    COUNT(*) AS customers,
    ROUND(AVG(Lifetime_Value), 2) AS avg_ltv,
    ROUND(SUM(Lifetime_Value), 2) AS total_ltv
FROM churn
GROUP BY Membership_Length
ORDER BY avg_ltv DESC;

SELECT
    Login_Levels,
    COUNT(*) AS customers,
    ROUND(AVG(Lifetime_Value), 2) AS avg_ltv
FROM churn
GROUP BY Login_Levels
ORDER BY avg_ltv DESC;


SELECT
    Lifetime_Value_Levels,
    COUNT(*) AS customers,
    ROUND(AVG(Churned) * 100, 2) AS churn_rate_pct
FROM churn
GROUP BY Lifetime_Value_Levels
ORDER BY churn_rate_pct;

SELECT
    Age_Group,
    Lifetime_Value_Levels,
    COUNT(*) AS customers,
    ROUND(AVG(Churned) * 100, 2) AS churn_rate_pct
FROM churn
GROUP BY Age_Group, Lifetime_Value_Levels
ORDER BY Lifetime_Value_Levels, churn_rate_pct DESC;

-- How much revenue is currently at risk due to churn?

WITH churn_share AS (
SELECT
	Churned,
    COUNT(*) AS Total_Customers,
	ROUND(SUM(Lifetime_Value),2) AS Total_LTV,
    ROUND(AVG(Lifetime_Value),2) AS AVG_LTV
FROM churn
GROUP BY churned
)
SELECT *,
	ROUND(Total_LTV / SUM(Total_LTV) OVER () * 100, 2) AS pct_share
FROM churn_share;

WITH churn_share2 AS (
SELECT
	Churned,
    Lifetime_Value_Levels,
	ROUND(SUM(Lifetime_Value),2) AS Total_LTV,
    ROUND(AVG(Lifetime_Value),2) AS AVG_LTV
FROM churn
GROUP BY churned, Lifetime_Value_Levels
ORDER BY FIELD(Churned, '1', '0'), FIELD(Lifetime_Value_Levels, 'Low Value', 'Emerging Value', 'Core Value', 'High Value', 'Top Customer')
)
SELECT *,
	ROUND(Total_LTV / SUM(Total_LTV) OVER (PARTITION BY Churned) * 100, 2) AS pct_share
FROM churn_share2;

WITH age_churn AS (
SELECT
	Churned,
    Age_Group,
	ROUND(SUM(Lifetime_Value),2) AS Total_LTV,
    ROUND(AVG(Lifetime_Value),2) AS AVG_LTV
FROM churn
WHERE Age_Group <> 'Unknown'
GROUP BY churned, Age_Group
ORDER BY Churned, FIELD(Age_Group, 'Children (<18)', 'Young Adults (18-24)', 'Early Career (25-34)', 'Middle Age (35-44)', 'Established (45-54)', 'Established (45-54)', 'Established (45-54)', 'Pre-Retirement (55-64)', 'Seniors (65+)')
)
SELECT *,
	ROUND(Total_LTV / SUM(Total_LTV) OVER (PARTITION BY Churned) * 100, 2) AS pct_share
FROM age_churn;

WITH login_churn AS (
SELECT
	Churned,
    Login_Levels,
	ROUND(SUM(Lifetime_Value),2) AS Total_LTV,
    ROUND(AVG(Lifetime_Value),2) AS AVG_LTV
FROM churn
WHERE Login_Levels <> 'Unknown'
GROUP BY Churned, Login_Levels
ORDER BY Churned, FIELD(Login_Levels, 'Inactive', 'Very Low Activity', 'Low Activity', 'Moderate Activity', 'Top User')
)
SELECT *,
	ROUND(Total_LTV / SUM(Total_LTV) OVER (PARTITION BY Churned) * 100, 2) AS pct_share
FROM login_churn;

SELECT
	Age_Group,
    Lifetime_Value_Levels,
    COUNT(*) AS at_risk_customers,
    ROUND(SUM(Lifetime_Value), 2) AS ltv_at_risk,
    ROUND(AVG(Lifetime_Value), 2) AS avg_ltv,
    SUM(Average_Order_Value * Total_Purchases) AS revenue_at_risk
FROM churn
WHERE Churned = 0
	AND Lifetime_Value_Levels IN ('Core Value', 'High Value', 'Top Customer')
    AND (
			Days_Since_Last_Purchase >= 90
		OR Login_Levels IN ('Inactive', 'Very Low Activity')
        OR Discount_Usage_Tiers IN ('Deal Dependent')
	)
GROUP BY Age_Group, Lifetime_Value_Levels
ORDER BY FIELD(Lifetime_Value_Levels, 'Top Customer', 'High Value', 'Core Value'), revenue_at_risk DESC;

-- Are newer customers churning at higher rates than long-tenured customers?

WITH membership_churn AS (
SELECT
	Churned,
    Membership_Length,
    COUNT(*) AS total_customers
FROM churn
GROUP BY Churned, Membership_Length
)
SELECT *,
	ROUND(
		CASE
			WHEN Churned = 1 THEN 
				total_customers / 
                SUM(total_customers) OVER (PARTITION BY Membership_Length) * 100
			ELSE NULL
		END,
        2
	) AS churn_rate
FROM membership_churn;

-- Which engagement channels are most effective at retaining customers?

WITH email_churn AS (
SELECT
	Churned,
    CASE
		WHEN Email_Open_Rate < 14.99 THEN 'Rarely'
        WHEN Email_Open_Rate BETWEEN 15 AND 39.99 THEN 'Sometimes'
        WHEN Email_Open_Rate BETWEEN 40 AND 64.99 THEN 'Often'
        WHEN Email_Open_Rate > 65 THEN 'Always'
        ELSE 'Unknown'
	END AS Email_Open_Tiers,
    COUNT(*) AS total_customers
FROM churn
GROUP BY Churned, Email_Open_Tiers
)
SELECT *,
	ROUND(
		CASE
			WHEN Churned = 1 THEN 
				total_customers / 
                SUM(total_customers) OVER (PARTITION BY Email_Open_Tiers) * 100
			ELSE NULL
		END,
        2
	) AS churn_rate
FROM email_churn
WHERE Email_Open_Tiers <> 'Unknown'
ORDER BY FIELD(Email_Open_Tiers, 'Rarely', 'Sometimes', 'Often', 'Always'), Churned DESC;

WITH social_churn AS (
SELECT
	Churned,
    CASE
		WHEN Social_Media_Engagement_Score < 24.99 THEN 'Minimal'
        WHEN Social_Media_Engagement_Score BETWEEN 25 AND 49.99 THEN 'Moderate'
        WHEN Social_Media_Engagement_Score BETWEEN 50 AND 74.99 THEN 'Strong'
        WHEN Social_Media_Engagement_Score > 75 THEN 'Top-Tier'
        ELSE 'Unknown'
	END AS SME_Tiers,
    COUNT(*) AS total_customers
FROM churn
GROUP BY Churned, SME_Tiers
)
SELECT *,
	ROUND(
		CASE
			WHEN Churned = 1 THEN 
				total_customers / 
                SUM(total_customers) OVER (PARTITION BY SME_Tiers) * 100
			ELSE NULL
		END,
        2
	) AS churn_rate
FROM social_churn
WHERE SME_Tiers <> 'Unknown'
ORDER BY FIELD(SME_Tiers, 'Minimal', 'Moderate', 'Strong', 'Top-Tier'), Churned DESC;

WITH login_churn AS (
SELECT
	Churned,
    Login_Levels,
    COUNT(*) AS total_customers
FROM churn
GROUP BY Churned, Login_Levels
)
SELECT *,
	ROUND(
		CASE
			WHEN Churned = 1 THEN 
				total_customers / 
                SUM(total_customers) OVER (PARTITION BY Login_Levels) * 100
			ELSE NULL
		END,
        2
	) AS churn_rate
FROM login_churn
ORDER BY FIELD(Login_Levels, 'Inactive', 'Very Low Activity', 'Low Activity', 'Moderate Activity', 'Top User'), Churned DESC;

WITH app_churn AS (
SELECT
	Churned,
    CASE
		WHEN Mobile_App_Usage < 14.99 THEN 'Minimal'
        WHEN Mobile_App_Usage BETWEEN 15 AND 29.99 THEN 'Moderate'
        WHEN Mobile_App_Usage BETWEEN 30 AND 44.99 THEN 'Strong'
        WHEN Mobile_App_Usage > 45 THEN 'Top-Tier'
        ELSE 'Unknown'
	END AS App_Tiers,
    COUNT(*) AS total_customers
FROM churn
GROUP BY Churned, App_Tiers
)
SELECT *,
	ROUND(
		CASE
			WHEN Churned = 1 THEN 
				total_customers / 
                SUM(total_customers) OVER (PARTITION BY App_Tiers) * 100
			ELSE NULL
		END,
        2
	) AS churn_rate
FROM app_churn
WHERE App_Tiers <> 'Unknown'
ORDER BY FIELD(App_Tiers, 'Minimal', 'Moderate', 'Strong', 'Top-Tier'), Churned DESC;

-- Do discounts improve retention or simply reduce margins?

WITH discount_churn AS (
SELECT
	Churned,
    Discount_Usage_Tiers,
    COUNT(*) AS total_customers
FROM churn
GROUP BY Churned, Discount_Usage_Tiers
)
SELECT *,
	ROUND(
		CASE
			WHEN Churned = 1 THEN 
				total_customers / 
                SUM(total_customers) OVER (PARTITION BY Discount_Usage_Tiers) * 100
			ELSE NULL
		END,
        2
	) AS churn_rate
FROM discount_churn
WHERE Discount_Usage_Tiers <> 'Unknown' AND Discount_Usage_Tiers <> 'Full Price Buyer'
ORDER BY FIELD(Discount_Usage_Tiers, 'Full Price Buyer', 'Low Discount Usage', 'Moderate Discount Usage', 'High Discount Usage', 'Deal Dependent'), Churned DESC;

SELECT
	Lifetime_Value_Levels,
    ROUND(AVG(Discount_Usage_Rate),2) AS avg_discount
FROM churn
GROUP BY Lifetime_Value_Levels
ORDER BY FIELD(Lifetime_Value_Levels, 'Low Value', 'Emerging Value', 'Core Value', 'High Value', 'Top Customer');

SELECT
    Discount_Usage_Tiers,
    ROUND(AVG(Lifetime_Value),2) AS avg_ltv,
    COUNT(*) AS total_customers
FROM churn
WHERE Discount_Usage_Tiers <> 'Unknown' AND Discount_Usage_Tiers <> 'Full Price Buyer'
GROUP BY Discount_Usage_Tiers
ORDER BY FIELD(Discount_Usage_Tiers, 'Full Price Buyer', 'Low Discount Usage', 'Moderate Discount Usage', 'High Discount Usage', 'Deal Dependent');

SELECT
    Discount_Usage_Tiers,
    App_Usage_Tiers,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN Churned = 0 THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(
        SUM(CASE WHEN Churned = 1 THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) AS churn_rate_pct
FROM churn
WHERE Discount_Usage_Tiers <> 'Unknown' AND App_Usage_Tiers <> 'Unknown'
GROUP BY Discount_Usage_Tiers, App_Usage_Tiers
ORDER BY FIELD(Discount_Usage_Tiers, 'Full Price Buyer', 'Low Discount Usage', 'Moderate Discount Usage', 'High Discount Usage', 'Deal Dependent'), 
	FIELD(App_Usage_Tiers, 'Minimal', 'Moderate', 'Strong', 'Top-Tier');
