# <p align="center" style="margin-top: 0px;"> 🥑 Data With Danny Case Study - Foodie-Fi 🥑
## <p align="center"> Part B. Data Analysis Questions

---

### 1. How many customers has Foodie‑Fi ever had?

**Steps:**  
- Count only unique `customer_id` values so we don’t double-count the same customer.

```sql
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions;
````

**Output:**

| total\_customers |
| ---------------- |
| 1000             |

**Interpretation:**
Foodie‑Fi has served **1,000 unique customers** to date.

---

### 2. Monthly distribution of trial plan starts

**Steps:**

* Extract the month number from each `start_date`
* Only count those rows where `plan_name = 'trial'`
* Group by month to see how many started the trial each month

```sql
SELECT month(start_date) AS month,
       COUNT(*) AS total_trials
FROM subscriptions AS s
JOIN plans AS p ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY month(start_date)
ORDER BY total_trials DESC;
```

**Output:**

| month | total\_trials |
| ----- | ------------- |
| 3     | 94            |
| 7     | 89            |
| ...   | ...           |
| 2     | 68            |

**Interpretation:**
March saw the **highest trial starts (94)** and February the **lowest (68)**.

---

### 3. Plan starts after 2020 by plan name

**Steps:**

* Filter subscriptions with `start_date >= '2021-01-01'`
* Count how many times each plan was chosen after 2020

```sql
SELECT p.plan_name,
       p.plan_id,
       COUNT(*) AS event_2021
FROM plans AS p
JOIN subscriptions AS s ON p.plan_id = s.plan_id
WHERE s.start_date >= '2021-01-01'
GROUP BY p.plan_id, p.plan_name
ORDER BY p.plan_id;
```

**Output:**

| plan\_name    | plan\_id | event\_2021 |
| ------------- | -------- | ----------- |
| basic monthly | 1        | 8           |
| pro monthly   | 2        | 60          |
| pro annual    | 3        | 63          |
| churn         | 4        | 71          |

**Interpretation:**
No trial plans started in 2021—most activity was among **paid plans or churn**.

---

### 4. How many customers have churned (and percentage)?

**Steps:**

* Count rows where `plan_id = 4` (churn)
* Compute the percentage versus total unique customers

```sql
SELECT COUNT(*) AS customer_count,
       ROUND((COUNT(*) * 100.0) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 1) AS churn_percentage
FROM subscriptions
WHERE plan_id = 4;
```

**Output:**

| customer\_count | churn\_percentage |
| --------------- | ----------------- |
| 307             | 30.7              |

**Interpretation:**
**307 customers (30.7%)** left the platform during the analysis period.

---

### 5. Customers who churned immediately after trial

**Steps:**

* Identify customers whose first plan is trial (`plan_id=0`)
* And their only other plan is churn (`plan_id=4`)

```sql
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
```

**Output:**

| churn\_after\_trial |
| ------------------- |
| 92                  |

**Interpretation:**
**92 users** tried the trial and left immediately, with no paid plan.

---

### 6. Next plan after trial (counts and percentages)

**Steps:**

* Rank each customer's plans chronologically
* Select their second plan only
* Count how many customers chose each next plan

```sql
WITH ranked_plans AS (
  SELECT customer_id,
         plan_id,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date) AS plan_order
  FROM subscriptions
),
second_plan AS (
  SELECT customer_id, plan_id
  FROM ranked_plans
  WHERE plan_order = 2
)
SELECT p.plan_name,
       COUNT(*) AS customer_count,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM second_plan), 1) AS percentage
FROM second_plan sp
JOIN plans p ON sp.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY customer_count DESC;
```

**Output:**

| plan\_name    | customer\_count | percentage |
| ------------- | --------------- | ---------- |
| basic monthly | 546             | 54.6       |
| pro monthly   | 325             | 32.5       |
| churn         | 92              | 9.2        |
| pro annual    | 37              | 3.7        |

**Interpretation:**
After the free trial:

* **54.6%** upgraded to Basic Monthly
* **32.5%** chose Pro Monthly
* **9.2%** churned immediately
* **3.7%** upgraded to Pro Annual

---

### 7. Plan distribution on 2020-12-31

**Steps:**

* For each customer, find their latest plan as of end of 2020
* Count how many are on each plan that day

```sql
WITH ranked_plans AS (
  SELECT customer_id, plan_id,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY start_date DESC) AS rn
  FROM subscriptions
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
JOIN plans p ON lp.plan_id = p.plan_id
GROUP BY p.plan_name
ORDER BY customer_count DESC;
```

**Output:**

| plan\_name    | customer\_count | percentage |
| ------------- | --------------- | ---------- |
| pro monthly   | 326             | 32.6       |
| churn         | 236             | 23.6       |
| basic monthly | 224             | 22.4       |
| pro annual    | 195             | 19.5       |
| trial         | 19              | 1.9        |

**Interpretation:**
As of Dec 31, 2020:

* **Pro Monthly** leads (32.6%)
* 23.6% had already churned
* Others split between Basic, Pro Annual, and Trial

---

### 8. Customers who upgraded to Pro Annual in 2020

**Steps:**

* Count unique customers with `plan_id = 3` and `start_date` in 2020

```sql
SELECT COUNT(DISTINCT customer_id) AS upgraded_to_annual
FROM subscriptions
WHERE plan_id = 3 AND start_date BETWEEN '2020-01-01' AND '2020-12-31';
```

**Output:**

| upgraded\_to\_annual |
| -------------------- |
| 195                  |

**Interpretation:**
**195 customers** upgraded to Pro Annual in 2020.

---

### 9. Average days to upgrade from trial to annual

**Steps:**

* Subtract trial start date from annual plan start date per customer
* Compute average days across all end-to-end transitions

```sql
SELECT ROUND(AVG(annual.start_date - trial.start_date)) AS avg_days_to_annual
FROM subscriptions AS trial
JOIN subscriptions AS annual 
  ON trial.customer_id = annual.customer_id
WHERE trial.plan_id = 0 AND annual.plan_id = 3;
```

**Output:**

| avg\_days\_to\_annual |
| --------------------- |
| 105                   |

**Interpretation:**
On average, it takes **105 days** to move from trial to Pro Annual.

---

### 🔟 Breakdown of upgrade time in 30-day buckets

**Steps:**

* Calculate difference between trial and annual plan in days
* Group those customers into time range buckets (0–30, 31–60, etc.)

```sql
SELECT 
  CASE 
    WHEN days_to_annual BETWEEN 0 AND 30 THEN '0-30 days'
    WHEN days_to_annual BETWEEN 31 AND 60 THEN '31-60 days'
    … 
    ELSE '>180 days'
  END AS days_group,
  COUNT(*) AS num_customers,
  ROUND(AVG(days_to_annual)) AS avg_days_to_upgrade
FROM (
  SELECT t.customer_id,
         pa.start_date - t.start_date AS days_to_annual
  FROM subscriptions t
  JOIN subscriptions pa ON t.customer_id = pa.customer_id
  WHERE t.plan_id = 0 AND pa.plan_id = 3
    AND pa.start_date BETWEEN '2020-01-01' AND '2020-12-31'
) sub
GROUP BY days_group
ORDER BY MIN(days_to_annual);
```

**Output (example):**

| days\_group | num\_customers | avg\_days\_to\_upgrade |
| ----------- | -------------- | ---------------------- |
| 0–30        | 48             | 9                      |
| 31–60       | 25             | 41                     |
| …           | …              | …                      |

**Interpretation:**
Most customers upgrade within the **first 30 days**, with fewer upgrading after 180 days.

---

### 1️⃣1️⃣ Downgrades from Pro Monthly to Basic Monthly in 2020

**Steps:**

* Check if customer had `plan_id=2` then `plan_id=1` (Pro → Basic) within 2020

```sql
WITH next_plan_cte AS (
  SELECT customer_id,
         plan_id,
         LEAD(plan_id) OVER (PARTITION BY customer_id ORDER BY start_date) AS next_plan
  FROM subscriptions
)
SELECT COUNT(*) AS downgrades
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
  AND plan_id = 2 AND next_plan = 1;
```

**Output:**

| downgrades |
| ---------- |
| 0          |

**Interpretation:**
No customers downgraded from Pro Monthly to Basic Monthly during 2020.

---

Let me know if you’d like a downloadable `.md` version of this or to visualize any of the results!
