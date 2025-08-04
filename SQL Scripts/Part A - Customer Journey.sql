-- A. Customer Journey

/*
Based on the sample of 8 customers from the subscriptions table, 
we'll analyze each customer’s onboarding journey. We'll look at how they started, 
if and when they upgraded or downgraded, and whether they churned.
*/

-- Build a dataset showing the journey of the 8 selected customers
-- We'll join plans and subscriptions, filtering only the relevant customers

SELECT 
    s.customer_id,
    p.plan_id,
    p.plan_name,
    s.start_date
FROM subscriptions AS s
JOIN plans AS p
  ON s.plan_id = p.plan_id
WHERE s.customer_id IN (1, 2, 11, 13, 15, 16, 18, 19)
ORDER BY s.customer_id, s.start_date;

-- Summary of each customer's journey based on the above results

/*
Customer 1: Started with a free trial on 2020-08-01 and upgraded to the basic monthly plan on 2020-08-08.

Customer 2: Started with a free trial on 2020-09-20 and upgraded to the pro annual plan on 2020-09-27.

Customer 11: Began a free trial on 2020-11-19 and cancelled (churned) at the end of the trial on 2020-11-26.

Customer 13: Started a trial on 2020-12-15, upgraded to basic monthly on 2020-12-22, then moved to pro monthly on 2021-03-29.

Customer 15: Started a trial on 2020-03-17, upgraded to pro monthly on 2020-03-24, and churned on 2020-04-29.

Customer 16: Started a trial on 2020-05-31, upgraded to basic monthly on 2020-06-07, then moved to pro annual on 2020-10-21.

Customer 18: Started with a trial on 2020-07-06 and upgraded to pro monthly on 2020-07-13.

Customer 19: Started a trial on 2020-06-22, upgraded to pro monthly on 2020-06-29, then moved to pro annual on 2020-08-29.
*/

