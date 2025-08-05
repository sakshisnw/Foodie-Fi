# <p align="center" style="margin-top: 0px;"> 🥑 Data With Danny Case Study - Foodie-Fi 🥑
## <p align="center"> Part C.Challenge Payment Question
---

### Challenge: Create a 2020 Payments Table

**Business Question:**  
Build a payments table for 2020, showing every paid amount per customer, including plan, payment date, payment amount, and sequence (payment order).  
Special logic:  
- Monthly plan payments occur each month on the same day as the subscription's start date, until upgrade/churn.
- Upgrades from basic to pro monthly reduce the new plan's first-month fee by the unused portion of the basic plan (not implemented here, see note).
- Upgrades from pro monthly to pro annual are paid at the end of the current billing period.
- Customers stop paying after a churn.

---

**Step-by-Step Solution**

#### Approach

1. **Identify all monthly subscription periods** (basic monthly and pro monthly), including each plan's start date and when the next plan or churn happens.
2. **Generate a row for every monthly payment** between the plan’s start and its end—each on the correct day of the month.
3. **Identify annual plans** (pro annual) and include a single payment for the annual fee on the plan start date.
4. **Combine all payment events** and assign the correct payment amount:
    - Basic Monthly: $9.90  
    - Pro Monthly: $19.90  
    - Pro Annual: $199.00
5. **Order and enumerate each customer’s payments** (payment_order: 1, 2, 3, ...).
6. **Optional note:** Advanced pro-rata reduction for plan upgrades is not implemented in this SQL (see Data With Danny sample for logic).

---

**SQL Solution**

```
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
    AND s.start_date = '2020-01-01'
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
```

---

**Sample Output:**

| customer_id | plan_id | plan_name     | payment_date | amount | payment_order |
| ----------- | ------- | ------------ | ------------ | ------ | ------------- |
| 1           | 1       | basic monthly| 2020-08-08   | 9.90   | 1             |
| 1           | 1       | basic monthly| 2020-09-08   | 9.90   | 2             |
| 2           | 3       | pro annual   | 2020-09-27   | 199.00 | 1             |
| ...         | ...     | ...          | ...          | ...    | ...           |

---

**🟢 Interpretation:**
- This solution provides a full payment history for each Foodie-Fi customer in 2020.
- Every monthly and annual payment is included, with exact dates, plan, amount, and order.
- Foodie-Fi can use this to analyze revenue, see who paid and when, and understand customer payment patterns.

---
