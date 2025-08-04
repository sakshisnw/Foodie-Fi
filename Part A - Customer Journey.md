# <p align="center" style="margin-top: 0px;"> 🥑 Data With Danny Case Study - Foodie-Fi 🥑
## <p align="center"> Part A. Customer Journey

*Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief
description about each customer’s onboarding journey. Try to keep it as short as possible - you may also
want to run some sort of join to make your explanations a bit easier!*

### Approach: Tracking Customer Journeys
1. Selected 8 Sample Customers
Focused on IDs: 1, 2, 11, 13, 15, 16, 18, 19.

2. Joined subscriptions + plans
Pulled customer_id, plan_name, start_date.

3. Sorted by Customer & Date
To follow each customer’s journey in order.

4. Summarized Journeys
Tracked plan changes: trial → upgrades → churn.
	
### Solution

```sql
-- selecting the unique customers based on the sample from the subscriptions table
SELECT s.customer_id,
	   p.plan_id, 
	   p.plan_name, 
	   s.start_date
FROM plans AS p
INNER JOIN subscriptions AS s
  ON p.plan_id = s.plan_id
WHERE s.customer_id IN (1,2,11,13,15,16,18,19)
ORDER BY s.customer_id, s.start_date;
````

| customer\_id | plan\_id | plan\_name    | start\_date |
| ------------ | -------- | ------------- | ----------- |
| 1            | 0        | trial         | 2020-08-01  |
| 1            | 1        | basic monthly | 2020-08-08  |
| 2            | 0        | trial         | 2020-09-20  |
| 2            | 3        | pro annual    | 2020-09-27  |
| 11           | 0        | trial         | 2020-11-19  |
| 11           | 4        | churn         | 2020-11-26  |
| 13           | 0        | trial         | 2020-12-15  |
| 13           | 1        | basic monthly | 2020-12-22  |
| 13           | 2        | pro monthly   | 2021-03-29  |
| 15           | 0        | trial         | 2020-03-17  |
| 15           | 2        | pro monthly   | 2020-03-24  |
| 15           | 4        | churn         | 2020-04-29  |
| 16           | 0        | trial         | 2020-05-31  |
| 16           | 1        | basic monthly | 2020-06-07  |
| 16           | 3        | pro annual    | 2020-10-21  |
| 18           | 0        | trial         | 2020-07-06  |
| 18           | 2        | pro monthly   | 2020-07-13  |
| 19           | 0        | trial         | 2020-06-22  |
| 19           | 2        | pro monthly   | 2020-06-29  |
| 19           | 3        | pro annual    | 2020-08-29  |

### Brief description on the customers journey based on the results from the above query:

* Customer 1:
Started with a trial on Dec 1, 2020, and upgraded to a pro annual plan on Dec 8, 2020.

* Customer 2:
Started with a trial on Dec 20, 2020, and downgraded to a basic monthly plan on Dec 27, 2020.

* Customer 11:
Started with a trial on Dec 19, 2020, and cancelled the service on Dec 26, 2020, before the trial ended.

* Customer 13:
Started with a trial on Dec 15, 2020, upgraded to basic monthly on Dec 22, 2020, and later upgraded to pro monthly on Mar 29, 2021.

* Customer 15:
Started with a trial on Dec 17, 2020, upgraded to pro monthly on Dec 24, 2020, and later cancelled on Jan 20, 2021.

* Customer 16:
Started with a trial on Dec 6, 2020, and upgraded directly to pro annual on Dec 13, 2020.

* Customer 18:
Started with a trial on Dec 27, 2020, and continued with pro monthly from Jan 3, 2021.

* Customer 19:
Started with a trial on Dec 5, 2020, upgraded to basic monthly on Dec 12, 2020, and later churned on Jan 9, 2021.


