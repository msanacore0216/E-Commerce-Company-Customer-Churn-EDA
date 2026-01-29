# E-Commerce-Company-Customer-Churn-EDA

## Overview
An exploratory data analysis using SQL, Excel, and Tableau to identify churn drivers, high-risk customer segments, and retention levers in an e-commerce platform.

## Business Questions
1. What behaviors differentiate churned vs. retained customers?
2. Which customer segments generate the highest lifetime value, and how stable are they?
3. How much revenue is currently at risk due to churn?
4. Are newer customers churning at higher rates than long-tenured customers?
5. Which engagement channels are most effective at retaining customers?
6. Do discounts improve retention or simply reduce margins?

## Tools
- SQL (MySQL)
- Tableau (dashboard)
- Excel (initial exploration)

## Repository Guide
- `sql/` — queries for cleaning, feature engineering, and analysis
- `data/raw/` — original dataset (or link if not shareable)
- `data/cleaned/` — cleaned export used in Tableau
- `tableau/` — Tableau workbook / packaged workbook
- `docs/` — written executive summary / notes
- `images/screenshots/` — visuals used in README

## Key Findings (summary)
- Overall churn rate is 28.9%, representing 14,450 lost customers and nearly 30% of total lifetime value, making churn a significant revenue risk.
- Customer engagement is the strongest driver of retention.
- Churn rates exceed 40% among minimally engaged users but fall below 20% for customers with strong or top-tier engagement across email, app usage, and login activity.
- Moderately engaged customers account for nearly half of churn-related revenue loss. These customers represent the largest opportunity for retention impact, as they are neither inactive nor fully loyal.
- Customers aged 25–54 generate the majority of lifetime value, with middle-aged customers (35–44) representing the largest concentration of revenue at risk due to churn.
- Higher engagement correlates with higher lifetime value.
- Top-engagement customers generate more than 2× the lifetime value of low-engagement customers.
- Discount usage is associated with lower churn, declining from over 35% among low-discount users to approximately 24% for deal-dependent customers.
- Discounts alone do not ensure retention.
- The lowest churn rates occur when high discount usage is paired with high engagement, particularly strong mobile app usage.

## Tableau Dashboard
An interactive Tableau dashboard was built to visualize churn drivers, customer engagement, and lifetime value at risk.

Link: https://public.tableau.com/views/E-CommerceCompanyChurnDashboard/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link

Preview: https://github.com/user-attachments/assets/232d532e-8959-400f-86c7-0502c3e4368e



