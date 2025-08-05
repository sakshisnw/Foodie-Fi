-- C. Challenge Payment Question

/*
Build a payments table for Foodie-Fi in 2020:
This query will show when each customer needs to pay, what plan they are paying for, how much, and the order of their payments.
It covers:
- Monthly payments for each monthly subscription (basic and pro monthly)
- Annual payments for pro annual plans
- Correct dates, amounts, and payment numbers for each customer
- Stops payments if a customer changes plan or after the last subscription in 2020

STEPS:
1. Get all subscriptions for monthly plans (basic monthly = plan_id 1, pro monthly = plan_id 2), we call this "monthly_subs". Also, remember when their next plan starts.
2. For each monthly subscription, generate one payment on the same date every month from the subscription's start until (a) the next plan starts, (b) the end of the year, or (c) churn.
   - For example, if a monthly plan starts on the 8th, payments will happen on the 8th of each month.
3. Pick up annual subscriptions (plan_id 3), with a single payment on the start date of the annual plan.
4. Combine all payments (monthly and annual) into a single table and assign payment amounts:
   - Basic monthly costs $9.90
   - Pro monthly costs $19.90
   - Pro annual costs $199.00
5. Number every payment for each customer, to show which payment it is (payment_order = 1, 2, 3, ...).
6. Show all results ordered by customer and payment date.

The query below does all those steps using clear names for each part. Every CTE ("WITH" part) means a processing step.

Let's go!
*/

WITH monthly_subs AS (
  -- 1. Find all monthly plan subscriptions and when the next plan/change happens
  SELECT
    s.customer_id,
    s.plan_id,
    p.plan_name,
    s.start_date,
    LEAD(s.start_date) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_start,
    COALESCE(
      LEAD(s.plan_id) OVER (PARTITION BY s.customer_id ORDER BY s.start_date), 
      -1
    ) as next_plan_id
  FROM
    foodie_fi.subscriptions s
    JOIN foodie_fi.plans p ON s.plan_id = p.plan_id
  WHERE s.plan_id IN (1, 2) -- basic monthly, pro monthly
    AND s.start_date < '2021-01-01'
),
monthly_payments AS (
  -- 2. For each monthly plan, create a payment on the same date each month, stopping on plan change or year end
  SELECT
    ms.customer_id,
    ms.plan_id,
    ms.plan_name,
    gs.payment_date
  FROM monthly_subs ms
  JOIN LATERAL (
      SELECT generate_series(
          ms.start_date,
          LEAST(COALESCE(ms.next_start - INTERVAL '1 day', '2020-12-31'), '2020-12-31'),
          INTERVAL '1 month'
      )::date as payment_date
  ) gs ON TRUE
  WHERE gs.payment_date >= '2020-01-01'
),
annual_payments AS (
  -- 3. For each annual subscription, create a single payment on the start_date
  SELECT
    s.customer_id,
    s.plan_id,
    p.plan_name,
    s.start_date AS payment_date
  FROM foodie_fi.subscriptions s
    JOIN foodie_fi.plans p ON s.plan_id = p.plan_id
  WHERE s.plan_id = 3
    AND s.start_date >= '2020-01-01'
    AND s.start_date < '2021-01-01'
),
all_payments AS (
  -- 4. Combine all payments and assign the payment amount for each row
  SELECT
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    CASE
      WHEN plan_id = 1 THEN 9.90
      WHEN plan_id = 2 THEN 19.90
      WHEN plan_id = 3 THEN 199.00
      ELSE NULL
    END AS amount
  FROM monthly_payments
  UNION ALL
  SELECT
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    199.00 AS amount
  FROM annual_payments
),
final_payments AS (
  -- 5. Number every payment for each customer (so we know this is payment 1, 2, 3, etc)
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
  FROM all_payments
)
-- 6. Show all results, sorted by customer and date
SELECT *
FROM final_payments
ORDER BY customer_id, payment_date;
