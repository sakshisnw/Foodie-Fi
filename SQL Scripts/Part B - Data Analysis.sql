-- B. Data Analysis Questions

/* 1. How many customers has Foodie-Fi ever had? */
/* 
Approach:
- Each customer has a customer_id.
- We count only unique customer_id values to avoid duplicates.
*/

SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM foodie_fi.subscriptions;

-- Foodie-Fi has 1000 customers.



/* 2. What is the monthly distribution of trial plan start_date values for our dataset? */
/*
Approach:
- We want to know how many people started a trial plan in each month.
- First, join subscriptions and plans to get the plan_name.
- Filter only trial plans.
- Use DATE_TRUNC('month', start_date) to group all days into the month they belong to.
- Then count how many started each month.
*/

SELECT 
  DATE_TRUNC('month', start_date) AS month_start,
  COUNT(*) AS trial_starts
FROM subscriptions AS s
JOIN plans AS p 
  ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY month_start;

-- March has the most trials (94), February the fewest (68).



/* 3. What plan start_date values occur after the year 2020? */
/*
Approach:
- We want to see which plans people started after 2020.
- Join subscriptions and plans to get plan_name.
- Filter records where start_date is after 2020.
- Count how many times each plan was chosen.
*/

SELECT p.plan_name, 
       COUNT(*) AS plan_count
FROM subscriptions s
JOIN plans p 
  ON s.plan_id = p.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY p.plan_name
ORDER BY plan_count DESC;

-- Most users who continued after 2020 chose the Pro plans. Few picked Basic.



/* 4. What is the customer count and percentage of customers who have churned? */
/*
Approach:
- Churned customers have plan_id = 4.
- Count how many customers have this plan.
- Divide by total number of customers and convert to percentage.
*/

SELECT 
    COUNT(*) AS customer_count,
    ROUND(
        (COUNT(*) * 100.0) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 
        1
    ) AS churn_percentage
FROM subscriptions
WHERE plan_id = 4;

-- About 30.7% of customers have churned (left the platform).



/* 5. How many customers have churned right after the trial plan? */
/*
Approach:
- We find customers whose first plan is trial (plan_id = 0) and last plan is churn (plan_id = 4).
- These customers have only 2 records in subscriptions.
*/

SELECT COUNT(*) AS churn_after_trial
FROM (
  SELECT customer_id,
         MIN(plan_id) AS first_plan,
         MAX(plan_id) AS last_plan,
         COUNT(*) AS total_plans
  FROM subscriptions
  GROUP BY customer_id
) sub
WHERE total_plans = 2 AND first_plan = 0 AND last_plan = 4;

-- 92 customers churned right after the trial.



/* 6. What is the next plan customers choose after trial? */
/*
Approach:
- We use ROW_NUMBER() to rank plans in order for each customer.
- We select the second plan only.
- Then count how many customers chose each plan.
*/

WITH ranked_plans AS (
    SELECT customer_id, 
           plan_id, 
           start_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS plan_order
    FROM foodie_fi.subscriptions
),
second_plan AS (
    SELECT customer_id, plan_id
    FROM ranked_plans
    WHERE plan_order = 2
)

SELECT 
    p.plan_name, 
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM second_plan), 1) AS percentage
FROM second_plan sp
JOIN foodie_fi.plans p ON sp.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY customer_count DESC;

-- Most customers upgraded to Basic Monthly or Pro Monthly after trial.



/* 7. What was the plan distribution on 2020-12-31? */
/*
Approach:
- For each customer, find their latest plan *before or on* 2020-12-31.
- Use ROW_NUMBER() to pick the latest entry.
- Count how many customers had each plan on that day.
*/

WITH ranked_plans AS (
  SELECT customer_id, plan_id, 
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS rn
  FROM foodie_fi.subscriptions
  WHERE start_date <= '2020-12-31'
),
latest_plan AS (
  SELECT customer_id, plan_id
  FROM ranked_plans
  WHERE rn = 1
)

SELECT p.plan_name,
       COUNT(lp.customer_id) AS customer_count,
       ROUND(100.0 * COUNT(lp.customer_id) / SUM(COUNT(lp.customer_id)) OVER (), 1) AS percentage
FROM latest_plan lp
JOIN foodie_fi.plans p ON lp.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY customer_count DESC;

-- Most customers were on Pro Monthly at the end of 2020.



/* 8. How many customers upgraded to an annual plan in 2020? */
/*
Approach:
- We just count customers who have plan_id = 3 (Pro Annual) and start_date within 2020.
*/

SELECT COUNT(DISTINCT customer_id) AS upgraded_to_annual
FROM subscriptions
WHERE plan_id = 3 AND start_date BETWEEN '2020-01-01' AND '2020-12-31';

-- 195 customers upgraded to annual plan in 2020.



/* 9. How many days does it take for customers to upgrade to the annual plan? */
/*
Approach:
- For customers who started with trial and later chose Pro Annual:
   → Subtract start_date of trial from annual plan start_date.
   → Take the average of those days.
*/

SELECT 
    ROUND(AVG(annual.start_date - trial.start_date)) AS avg_days_to_annual
FROM subscriptions AS trial
JOIN subscriptions AS annual 
  ON trial.customer_id = annual.customer_id
WHERE trial.plan_id = 0 AND annual.plan_id = 3;

-- On average, it takes 105 days to upgrade to Pro Annual.



/* 10. Breakdown of upgrade time to annual in 30-day ranges */
/*
Approach:
- First calculate number of days between trial and annual upgrade.
- Then group the results into ranges like 0-30, 31-60, etc.
- Count how many customers fall in each range.
*/

SELECT 
  CASE 
    WHEN days_to_annual BETWEEN 0 AND 30 THEN '0-30 days'
    WHEN days_to_annual BETWEEN 31 AND 60 THEN '31-60 days'
    WHEN days_to_annual BETWEEN 61 AND 90 THEN '61-90 days'
    WHEN days_to_annual BETWEEN 91 AND 120 THEN '91-120 days'
    WHEN days_to_annual BETWEEN 121 AND 150 THEN '121-150 days'
    WHEN days_to_annual BETWEEN 151 AND 180 THEN '151-180 days'
    ELSE '>180 days'
  END AS days_group,
  COUNT(*) AS num_customers,
  ROUND(AVG(days_to_annual)) AS avg_days_to_upgrade
FROM (
  SELECT
    t.customer_id,
    (pa.start_date - t.start_date) AS days_to_annual
  FROM
    foodie_fi.subscriptions t
    JOIN foodie_fi.subscriptions pa
      ON t.customer_id = pa.customer_id
  WHERE
    t.plan_id = 0          -- trial
    AND pa.plan_id = 3     -- pro annual
    AND pa.start_date >= '2020-01-01'
    AND pa.start_date < '2021-01-01'
) sub
GROUP BY days_group
ORDER BY 
  MIN(days_to_annual);

-- Most users upgraded within 30 days; some took much longer.



/* 11. How many customers downgraded from Pro Monthly to Basic Monthly in 2020? */
/*
Approach:
- For the same customer, check if they moved from plan_id = 2 (Pro Monthly) to plan_id = 1 (Basic Monthly).
- Ensure this happened in 2020.
*/

SELECT
  COUNT(DISTINCT s1.customer_id) AS customers_downgraded
FROM
  foodie_fi.subscriptions s1
JOIN
  foodie_fi.subscriptions s2
    ON s1.customer_id = s2.customer_id
    AND s2.start_date > s1.start_date
WHERE
  s1.plan_id = 2          -- pro monthly
  AND s2.plan_id = 1      -- basic monthly
  AND s2.start_date >= '2020-01-01'
  AND s2.start_date < '2021-01-01';

-- 0 customers downgraded from Pro Monthly to Basic Monthly in 2020.
