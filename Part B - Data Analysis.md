# <p align="center" style="margin-top: 0px;"> 🥑 Data With Danny Case Study - Foodie-Fi 🥑
## <p align="center"> Part B. Data Analysis Questions
---

### 1. How many customers has Foodie‑Fi ever had?

**Approach:**
- Each customer has a `customer_id`.
- We count only **unique** `customer_id` values to avoid duplicates.

```sql
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM foodie_fi.subscriptions;
````

**Output:**

| customer\_count |
| --------------- |
| 1000            |

**🟢 Interpretation:**
Foodie‑Fi has served **1,000 unique customers** to date.

---

### 2. Monthly distribution of trial plan starts

**Approach:**

* Join `subscriptions` and `plans` to get `plan_name`.
* Filter only `trial` plans.
* Use `DATE_TRUNC('month', start_date)` to group by month.
* Count how many started each month.

```sql
SELECT 
  DATE_TRUNC('month', start_date) AS month_start,
  COUNT(*) AS trial_starts
FROM subscriptions AS s
JOIN plans AS p 
  ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY DATE_TRUNC('month', start_date)
ORDER BY month_start;
```

**Output:**

| month\_start | trial\_starts |
| ------------ | ------------- |
| 2020-01-01   | 88            |
| 2020-02-01   | 68            |
| 2020-03-01   | 94            |
| 2020-04-01   | 81            |
| 2020-05-01   | 88            |
| 2020-06-01   | 79            |
| 2020-07-01   | 89            |
| 2020-08-01   | 88            |
| 2020-09-01   | 87            |
| 2020-10-01   | 79            |
| 2020-11-01   | 75            |
| 2020-12-01   | 84            |

**🟢 Interpretation:**
**March** saw the **highest trial starts (94)** and **February the lowest (68)**.

---

### 3. Plan starts after 2020 by plan name

**Approach:**

* Join `subscriptions` and `plans` to get `plan_name`.
* Filter records with `start_date` after 2020.
* Count how many times each plan was chosen.

```sql
SELECT p.plan_name, 
       COUNT(*) AS plan_count
FROM subscriptions s
JOIN plans p 
  ON s.plan_id = p.plan_id
WHERE s.start_date > '2020-12-31'
GROUP BY p.plan_name
ORDER BY plan_count DESC;
```

**Output:**

| plan\_name    | plan\_count |
| ------------- | ----------- |
| churn         | 71          |
| pro annual    | 63          |
| pro monthly   | 60          |
| basic monthly | 8           |

**🟢 Interpretation:**
**Pro Annual** and **Pro Monthly** were the most chosen plans after 2020.
**Basic Monthly** was the least popular among upgraders.

---

### 4. How many customers have churned (and percentage)?

**Approach:**

* Filter by `plan_id = 4` (churn).
* Count customers and calculate the percentage of total.

```sql
SELECT 
    COUNT(*) AS customer_count,
    ROUND(
        (COUNT(*) * 100.0) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions), 
        1
    ) AS churn_percentage
FROM subscriptions
WHERE plan_id = 4;
```

**Output:**

| customer\_count | churn\_percentage |
| --------------- | ----------------- |
| 307             | 30.7              |

**🟢 Interpretation:**
A total of **307 customers (30.7%)** have **churned**.

---

### 5. Customers who churned immediately after trial

**Approach:**

* Identify customers who had only 2 plans: **Trial → Churn**.
* Use `MIN(plan_id)` and `MAX(plan_id)` logic.

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

**🟢 Interpretation:**
**92 customers** churned **right after the trial** without upgrading to a paid plan.

---

### 6. Next plan after trial (counts and percentages)

**Approach:**

* Rank plans per customer using `ROW_NUMBER()`.
* Select only the second plan.
* Count plan frequencies and calculate percentages.

```sql
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
```

**Output:**

| plan\_name    | customer\_count | percentage |
| ------------- | --------------- | ---------- |
| basic monthly | 546             | 54.6       |
| pro monthly   | 325             | 32.5       |
| churn         | 92              | 9.2        |
| pro annual    | 37              | 3.7        |

**🟢 Interpretation:**
After the trial:

* **54.6%** chose **Basic Monthly**
* **32.5%** went for **Pro Monthly**
* **9.2%** churned
* Only **3.7%** opted for **Pro Annual**

---

### 7. Plan distribution on 2020-12-31

**Approach:**

* For each customer, find their **latest plan on or before** 2020-12-31 using `ROW_NUMBER()`.
* Group by `plan_id`.

```sql
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
```

**Output:**

| plan\_name    | customer\_count | percentage |
| ------------- | --------------- | ---------- |
| pro monthly   | 326             | 32.6       |
| churn         | 236             | 23.6       |
| basic monthly | 224             | 22.4       |
| pro annual    | 195             | 19.5       |
| trial         | 19              | 1.9        |

**🟢 Interpretation:**
As of **December 31, 2020**:

* **Pro Monthly** was the top plan (**32.6%**)
* **23.6% had already churned**
* Other customers were split between **Basic**, **Annual**, and a few on **Trial**

---

### 8. Customers who upgraded to Pro Annual in 2020

**Approach:**

* Filter `plan_id = 3` and `start_date` within 2020.

```sql
SELECT COUNT(DISTINCT customer_id) AS upgraded_to_annual
FROM subscriptions
WHERE plan_id = 3 AND start_date BETWEEN '2020-01-01' AND '2020-12-31';
```

**Output:**

| upgraded\_to\_annual |
| -------------------- |
| 195                  |

**🟢 Interpretation:**
**195 customers** upgraded to **Pro Annual** in 2020.

---

### 9. Average days to upgrade from trial to annual

**Approach:**

* Join trial and annual plans per customer.
* Subtract `start_date` values and take the average.

```sql
SELECT 
    ROUND(AVG(annual.start_date - trial.start_date)) AS avg_days_to_annual
FROM subscriptions AS trial
JOIN subscriptions AS annual 
  ON trial.customer_id = annual.customer_id
WHERE trial.plan_id = 0 AND annual.plan_id = 3;
```

**Output:**

| avg\_days\_to\_annual |
| --------------------- |
| 105                   |

**🟢 Interpretation:**
On average, customers took **105 days** to upgrade from **Trial → Pro Annual**.

---

### 10. Breakdown of upgrade time in 30-day buckets

**Approach:**

* Calculate `days_to_annual` for each customer.
* Bucket into 30-day intervals.
* Group and aggregate.

```sql
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
```

**Output:**

| days\_group  | num\_customers | avg\_days\_to\_upgrade |
| ------------ | -------------- | ---------------------- |
| 0–30 days    | 48             | 10                     |
| 31–60 days   | 22             | 43                     |
| 61–90 days   | 30             | 72                     |
| 91–120 days  | 24             | 101                    |
| 121–150 days | 28             | 134                    |
| 151–180 days | 22             | 164                    |
| >180 days    | 21             | 201                    |

**🟢 Interpretation:**
Most users (**48**) upgraded **within 30 days**, while **others took much longer**, up to **201 days** on average.

---

### 11. Downgrades from Pro Monthly to Basic Monthly in 2020

**Approach:**

* Check if a customer moved from `plan_id = 2` to `plan_id = 1` in 2020.

```sql
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
```

**Output:**

| customers\_downgraded |
| --------------------- |
| 0                     |

**🟢 Interpretation:**
There were **no downgrades** from **Pro Monthly → Basic Monthly** in 2020.

---

