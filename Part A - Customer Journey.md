# <p align="center" style="margin-top: 0px;"> 🥑 Case Study #3 - Foodie-Fi 🥑
## <p align="center"> A. Customer Journey

*Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief
description about each customer’s onboarding journey. Try to keep it as short as possible - you may also
want to run some sort of join to make your explanations a bit easier!*

### Steps to answering the question:

- The sample customer_id given in the sample subscription table are 1, 2, 11, 13, 15, 16, 18, 19. 

- Create a base table with the following columns: customer_id, plan_id, plan_name, start_date.

- Order by Customer_id
	
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

* Customer 1 starts with a free trial plan on 2020-08-01 and when the trial ends, upgrades to basic monthly plan on 2020-08-08.

* Customer 2 starts with a free trial plan on 2020-09-20 and when the trial ends, upgrades to pro annual plan on 2020-09-27.

* Customer 11 starts with free trial plan on 2020-11-19 and churns at the end of the free trial plan on 2020-11-26.

* Customer 13 starts with free trial plan on 2020-12-15 and when the trial ends, subscribes to a basic monthly plan on 2020-12-22, then upgrades to a pro monthly plan on 2021-03-29.

* Customer 15 starts with a free trial plan on 2020-03-17 and when the trial ends, upgrades to the pro monthly plan on 2020-03-24, then churns one month later on 2020-04-29.

* Customer 16 starts with a free trial plan on 2020-05-31 and when the trial ends, subscribes to a basic monthly plan on 2020-06-07, then upgrades to a pro annual plan on 2020-10-21.

* Customer 18 starts with a free trial plan on 2020-07-06 and when the trial ends, upgrades to pro monthly plan on 2020-07-13.

* Customer 19 starts with a free trial plan on 2020-06-22, upgrades to pro monthly on 2020-06-29, then upgrades to pro annual plan on 2020-08-29.

```

